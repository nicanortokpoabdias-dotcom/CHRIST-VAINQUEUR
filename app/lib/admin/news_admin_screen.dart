import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/news_article.dart';
import '../services/storage_service.dart';
import 'widgets/admin_field.dart';

class NewsAdminScreen extends StatefulWidget {
  const NewsAdminScreen({super.key});

  @override
  State<NewsAdminScreen> createState() => _NewsAdminScreenState();
}

class _NewsAdminScreenState extends State<NewsAdminScreen> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _category = TextEditingController(text: 'Annonce');
  DateTime _date = DateTime.now();
  File? _pickedImage;
  String? _existingImageUrl;
  String? _editingId;
  bool _saving = false;
  double? _uploadProgress;

  void _resetForm() {
    _title.clear();
    _content.clear();
    _category.text = 'Annonce';
    setState(() {
      _date = DateTime.now();
      _pickedImage = null;
      _existingImageUrl = null;
      _editingId = null;
    });
  }

  void _edit(String id, NewsArticle article) {
    _title.text = article.title;
    _content.text = article.content;
    _category.text = article.category;
    setState(() {
      _date = article.publishedAt;
      _pickedImage = null;
      _existingImageUrl = article.imageUrl;
      _editingId = id;
    });
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path != null) setState(() => _pickedImage = File(path));
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty || _content.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titre et contenu sont obligatoires.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      String? imageUrl = _existingImageUrl;
      if (_pickedImage != null) {
        imageUrl = await StorageService.instance.uploadFile(
          _pickedImage!,
          'news',
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
      }
      final data = {
        'title': _title.text.trim(),
        'content': _content.text.trim(),
        'category': _category.text.trim().isEmpty ? 'Annonce' : _category.text.trim(),
        'publishedAt': Timestamp.fromDate(_date),
        'imageUrl': imageUrl,
      };
      final collection = FirebaseFirestore.instance.collection('news');
      if (_editingId != null) {
        await collection.doc(_editingId).set(data, SetOptions(merge: true));
      } else {
        await collection.add(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingId != null ? 'Actualité mise à jour.' : 'Actualité publiée.')),
      );
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() { _saving = false; _uploadProgress = null; });
    }
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer cette actualité ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('news').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('news').orderBy('publishedAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_editingId != null ? "Modifier l'actualité" : 'Publier une actualité',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    AdminTextField(controller: _title, label: 'Titre'),
                    AdminTextField(controller: _content, label: 'Contenu', maxLines: 4),
                    AdminTextField(controller: _category, label: 'Catégorie'),
                    AdminDateTimeField(value: _date, onChanged: (d) => setState(() => _date = d), label: 'Date de publication'),
                    AdminFilePickerField(
                      label: 'Image (optionnelle)',
                      fileName: _pickedImage?.path.split(Platform.pathSeparator).last ??
                          (_existingImageUrl != null ? 'Image actuelle conservée' : null),
                      onPick: _pickImage,
                      uploadProgress: _saving ? _uploadProgress : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _saving ? null : _submit,
                            child: Text(_saving ? 'Publication…' : (_editingId != null ? 'Mettre à jour' : 'Publier')),
                          ),
                        ),
                        if (_editingId != null) ...[
                          const SizedBox(width: 8),
                          TextButton(onPressed: _saving ? null : _resetForm, child: const Text('Annuler')),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (docs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Rien de publié pour le moment.')),
              ),
            for (final doc in docs)
              _NewsTile(
                article: NewsArticle.fromFirestore(doc),
                onEdit: () => _edit(doc.id, NewsArticle.fromFirestore(doc)),
                onDelete: () => _delete(doc.id),
              ),
          ],
        );
      },
    );
  }
}

class _NewsTile extends StatelessWidget {
  const _NewsTile({required this.article, required this.onEdit, required this.onDelete});

  final NewsArticle article;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: article.imageUrl != null
            ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(article.imageUrl!, width: 48, height: 48, fit: BoxFit.cover))
            : const CircleAvatar(child: Icon(Icons.newspaper_outlined)),
        title: Text(article.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(article.content, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

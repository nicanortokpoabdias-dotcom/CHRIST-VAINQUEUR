import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/video_item.dart';
import 'widgets/admin_field.dart';

class VideosAdminScreen extends StatefulWidget {
  const VideosAdminScreen({super.key});

  @override
  State<VideosAdminScreen> createState() => _VideosAdminScreenState();
}

class _VideosAdminScreenState extends State<VideosAdminScreen> {
  final _title = TextEditingController();
  final _url = TextEditingController();
  DateTime _date = DateTime.now();
  String? _editingId;
  bool _saving = false;

  void _resetForm() {
    _title.clear();
    _url.clear();
    setState(() {
      _date = DateTime.now();
      _editingId = null;
    });
  }

  void _edit(String id, VideoItem video) {
    _title.text = video.title;
    _url.text = video.youtubeUrl;
    setState(() {
      _date = video.publishedAt;
      _editingId = id;
    });
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty || _url.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titre et lien YouTube sont obligatoires.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final data = {
        'title': _title.text.trim(),
        'youtubeUrl': _url.text.trim(),
        'publishedAt': Timestamp.fromDate(_date),
      };
      final collection = FirebaseFirestore.instance.collection('videos');
      if (_editingId != null) {
        await collection.doc(_editingId).set(data, SetOptions(merge: true));
      } else {
        await collection.add(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingId != null ? 'Vidéo mise à jour.' : 'Vidéo publiée.')),
      );
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer cette vidéo ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('videos').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('videos').orderBy('publishedAt', descending: true).snapshots(),
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
                    Text(_editingId != null ? 'Modifier la vidéo' : 'Publier une vidéo',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Collez un lien YouTube (vidéo, short ou lien court youtu.be).',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 12),
                    AdminTextField(controller: _title, label: 'Titre'),
                    AdminTextField(controller: _url, label: 'Lien YouTube', keyboardType: TextInputType.url),
                    AdminDateTimeField(value: _date, onChanged: (d) => setState(() => _date = d), label: 'Date de publication'),
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
              _VideoTile(
                video: VideoItem.fromFirestore(doc),
                onEdit: () => _edit(doc.id, VideoItem.fromFirestore(doc)),
                onDelete: () => _delete(doc.id),
              ),
          ],
        );
      },
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.video, required this.onEdit, required this.onDelete});

  final VideoItem video;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final thumb = video.thumbnailUrl;
    return Card(
      child: ListTile(
        leading: thumb != null
            ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(thumb, width: 48, height: 48, fit: BoxFit.cover))
            : const CircleAvatar(child: Icon(Icons.play_circle_outline_rounded)),
        title: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(video.youtubeUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
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

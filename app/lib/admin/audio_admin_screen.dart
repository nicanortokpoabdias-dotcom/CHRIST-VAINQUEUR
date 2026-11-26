import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/audio_message.dart';
import '../services/storage_service.dart';
import 'widgets/admin_field.dart';

class AudioAdminScreen extends StatefulWidget {
  const AudioAdminScreen({super.key});

  @override
  State<AudioAdminScreen> createState() => _AudioAdminScreenState();
}

class _AudioAdminScreenState extends State<AudioAdminScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime _date = DateTime.now();
  File? _pickedAudio;
  String? _existingAudioUrl;
  String? _editingId;
  bool _saving = false;
  double? _uploadProgress;

  void _resetForm() {
    _title.clear();
    _description.clear();
    setState(() {
      _date = DateTime.now();
      _pickedAudio = null;
      _existingAudioUrl = null;
      _editingId = null;
    });
  }

  void _edit(String id, AudioMessage audio) {
    _title.text = audio.title;
    _description.text = audio.description;
    setState(() {
      _date = audio.recordedAt;
      _pickedAudio = null;
      _existingAudioUrl = audio.audioUrl;
      _editingId = id;
    });
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    final path = result?.files.single.path;
    if (path != null) setState(() => _pickedAudio = File(path));
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le titre est obligatoire.')));
      return;
    }
    if (_pickedAudio == null && _existingAudioUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choisissez un fichier mp3.')));
      return;
    }
    setState(() => _saving = true);
    try {
      String audioUrl = _existingAudioUrl ?? '';
      if (_pickedAudio != null) {
        audioUrl = await StorageService.instance.uploadFile(
          _pickedAudio!,
          'audio',
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
      }
      final data = {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'recordedAt': Timestamp.fromDate(_date),
        'audioUrl': audioUrl,
      };
      final collection = FirebaseFirestore.instance.collection('audioMessages');
      if (_editingId != null) {
        await collection.doc(_editingId).set(data, SetOptions(merge: true));
      } else {
        await collection.add(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingId != null ? 'Enregistrement mis à jour.' : 'Séance publiée.')),
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
        title: const Text('Supprimer cet enregistrement ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('audioMessages').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('audioMessages').orderBy('recordedAt', descending: true).snapshots(),
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
                    Text(_editingId != null ? "Modifier l'enregistrement" : 'Publier une séance de prière',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Le fichier mp3 sera écoutable et téléchargeable dans l\'app.',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 12),
                    AdminTextField(controller: _title, label: 'Titre', ),
                    AdminTextField(controller: _description, label: 'Description (optionnelle)', maxLines: 2),
                    AdminDateTimeField(value: _date, onChanged: (d) => setState(() => _date = d), label: "Date de l'enregistrement"),
                    AdminFilePickerField(
                      label: 'Choisir le fichier mp3',
                      fileName: _pickedAudio?.path.split(Platform.pathSeparator).last ??
                          (_existingAudioUrl != null ? 'Fichier actuel conservé' : null),
                      onPick: _pickAudio,
                      uploadProgress: _saving ? _uploadProgress : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _saving ? null : _submit,
                            child: Text(_saving ? 'Envoi…' : (_editingId != null ? 'Mettre à jour' : 'Publier')),
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
              _AudioTile(
                audio: AudioMessage.fromFirestore(doc),
                onEdit: () => _edit(doc.id, AudioMessage.fromFirestore(doc)),
                onDelete: () => _delete(doc.id),
              ),
          ],
        );
      },
    );
  }
}

class _AudioTile extends StatelessWidget {
  const _AudioTile({required this.audio, required this.onEdit, required this.onDelete});

  final AudioMessage audio;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.headphones_outlined)),
        title: Text(audio.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(audio.description, maxLines: 1, overflow: TextOverflow.ellipsis),
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

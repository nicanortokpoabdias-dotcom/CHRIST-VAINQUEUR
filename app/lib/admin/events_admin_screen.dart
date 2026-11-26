import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/prayer_event.dart';
import '../services/storage_service.dart';
import 'widgets/admin_field.dart';

class EventsAdminScreen extends StatefulWidget {
  const EventsAdminScreen({super.key});

  @override
  State<EventsAdminScreen> createState() => _EventsAdminScreenState();
}

class _EventsAdminScreenState extends State<EventsAdminScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController(text: 'Centre de Prière Christ Vainqueur');
  DateTime _date = DateTime.now();
  bool _recurring = false;
  File? _pickedPoster;
  String? _existingPosterUrl;
  String? _editingId;
  bool _saving = false;
  double? _uploadProgress;

  void _resetForm() {
    _title.clear();
    _description.clear();
    _location.text = 'Centre de Prière Christ Vainqueur';
    setState(() {
      _date = DateTime.now();
      _recurring = false;
      _pickedPoster = null;
      _existingPosterUrl = null;
      _editingId = null;
    });
  }

  void _edit(String id, PrayerEvent event) {
    _title.text = event.title;
    _description.text = event.description;
    _location.text = event.location;
    setState(() {
      _date = event.startAt;
      _recurring = event.isRecurringWeekly;
      _pickedPoster = null;
      _existingPosterUrl = event.posterUrl;
      _editingId = id;
    });
  }

  Future<void> _pickPoster() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path != null) setState(() => _pickedPoster = File(path));
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty || _description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titre et description sont obligatoires.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      String? posterUrl = _existingPosterUrl;
      if (_pickedPoster != null) {
        posterUrl = await StorageService.instance.uploadFile(
          _pickedPoster!,
          'posters',
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
      }
      final data = {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'location': _location.text.trim(),
        'startAt': Timestamp.fromDate(_date),
        'isRecurringWeekly': _recurring,
        'posterUrl': posterUrl,
      };
      final collection = FirebaseFirestore.instance.collection('events');
      if (_editingId != null) {
        await collection.doc(_editingId).set(data, SetOptions(merge: true));
      } else {
        await collection.add(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingId != null ? 'Événement mis à jour.' : 'Événement publié.')),
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
        title: const Text('Supprimer cet événement ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('events').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('events').orderBy('startAt', descending: true).snapshots(),
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
                    Text(_editingId != null ? "Modifier l'événement" : 'Publier un événement',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    AdminTextField(controller: _title, label: 'Titre'),
                    AdminTextField(controller: _description, label: 'Description', maxLines: 3),
                    AdminTextField(controller: _location, label: 'Lieu'),
                    AdminDateTimeField(value: _date, onChanged: (d) => setState(() => _date = d), label: 'Date & heure'),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Événement hebdomadaire récurrent'),
                      value: _recurring,
                      onChanged: (v) => setState(() => _recurring = v ?? false),
                    ),
                    AdminFilePickerField(
                      label: 'Affiche (optionnelle)',
                      fileName: _pickedPoster?.path.split(Platform.pathSeparator).last ??
                          (_existingPosterUrl != null ? 'Affiche actuelle conservée' : null),
                      onPick: _pickPoster,
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
              _EventTile(
                event: PrayerEvent.fromFirestore(doc),
                onEdit: () => _edit(doc.id, PrayerEvent.fromFirestore(doc)),
                onDelete: () => _delete(doc.id),
              ),
          ],
        );
      },
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.onEdit, required this.onDelete});

  final PrayerEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: event.posterUrl != null
            ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(event.posterUrl!, width: 48, height: 48, fit: BoxFit.cover))
            : const CircleAvatar(child: Icon(Icons.calendar_month_outlined)),
        title: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(event.location, maxLines: 1, overflow: TextOverflow.ellipsis),
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

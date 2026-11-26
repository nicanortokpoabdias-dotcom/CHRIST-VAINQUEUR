import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/daily_verse.dart';
import 'widgets/admin_field.dart';

class VerseAdminScreen extends StatefulWidget {
  const VerseAdminScreen({super.key});

  @override
  State<VerseAdminScreen> createState() => _VerseAdminScreenState();
}

class _VerseAdminScreenState extends State<VerseAdminScreen> {
  final _reference = TextEditingController();
  final _text = TextEditingController();
  final _meditation = TextEditingController();
  DateTime _date = DateTime.now();
  String? _editingId;
  bool _saving = false;

  void _resetForm() {
    _reference.clear();
    _text.clear();
    _meditation.clear();
    setState(() {
      _date = DateTime.now();
      _editingId = null;
    });
  }

  void _edit(String id, DailyVerse verse) {
    _reference.text = verse.reference;
    _text.text = verse.text;
    _meditation.text = verse.meditation ?? '';
    setState(() {
      _date = verse.date;
      _editingId = id;
    });
  }

  Future<void> _submit() async {
    if (_reference.text.trim().isEmpty || _text.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Référence et texte sont obligatoires.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final data = {
        'reference': _reference.text.trim(),
        'text': _text.text.trim(),
        'meditation': _meditation.text.trim().isEmpty ? null : _meditation.text.trim(),
        'date': Timestamp.fromDate(_date),
      };
      final collection = FirebaseFirestore.instance.collection('dailyVerse');
      if (_editingId != null) {
        await collection.doc(_editingId).set(data, SetOptions(merge: true));
      } else {
        await collection.add(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingId != null ? 'Verset mis à jour.' : 'Verset publié.')),
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
        title: const Text('Supprimer ce verset ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('dailyVerse').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('dailyVerse').orderBy('date', descending: true).snapshots(),
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
                    Text(_editingId != null ? 'Modifier le verset' : 'Publier le verset du jour',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Le plus récent (date passée ou aujourd\'hui) est affiché en tête de l\'accueil.',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 12),
                    AdminTextField(controller: _reference, label: 'Référence (ex. Philippiens 4:13)'),
                    AdminTextField(controller: _text, label: 'Texte du verset', maxLines: 3),
                    AdminTextField(controller: _meditation, label: 'Méditation (optionnelle)', maxLines: 2),
                    AdminDateTimeField(value: _date, onChanged: (d) => setState(() => _date = d), label: 'Date'),
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
              _VerseTile(
                verse: DailyVerse.fromFirestore(doc),
                onEdit: () => _edit(doc.id, DailyVerse.fromFirestore(doc)),
                onDelete: () => _delete(doc.id),
              ),
          ],
        );
      },
    );
  }
}

class _VerseTile extends StatelessWidget {
  const _VerseTile({required this.verse, required this.onEdit, required this.onDelete});

  final DailyVerse verse;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.auto_stories_outlined)),
        title: Text(verse.reference, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(verse.text, maxLines: 2, overflow: TextOverflow.ellipsis),
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

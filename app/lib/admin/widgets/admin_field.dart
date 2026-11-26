import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Champ texte standard des formulaires d'administration.
class AdminTextField extends StatelessWidget {
  const AdminTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

/// Sélecteur date + heure, affiché comme un champ cliquable.
class AdminDateTimeField extends StatelessWidget {
  const AdminDateTimeField({super.key, required this.value, required this.onChanged, this.label = 'Date'});

  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final String label;

  Future<void> _pick(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (time == null) return;
    onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('EEEE d MMMM y, HH:mm', 'fr_FR').format(value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _pick(context),
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Row(
            children: [
              Expanded(child: Text(formatted)),
              const Icon(Icons.calendar_today_outlined, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ligne de sélection de fichier (image ou audio), avec aperçu du nom choisi
/// et barre de progression pendant l'envoi.
class AdminFilePickerField extends StatelessWidget {
  const AdminFilePickerField({
    super.key,
    required this.label,
    required this.fileName,
    required this.onPick,
    this.uploadProgress,
  });

  final String label;
  final String? fileName;
  final VoidCallback onPick;
  final double? uploadProgress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(fileName ?? label),
          ),
          if (uploadProgress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: uploadProgress == 0 ? null : uploadProgress),
            ),
          ],
        ],
      ),
    );
  }
}

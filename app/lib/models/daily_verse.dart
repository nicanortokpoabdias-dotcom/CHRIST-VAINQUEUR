import 'package:cloud_firestore/cloud_firestore.dart';

class DailyVerse {
  final String reference;
  final String text;
  final String? meditation;
  final DateTime date;

  const DailyVerse({
    required this.reference,
    required this.text,
    required this.date,
    this.meditation,
  });

  factory DailyVerse.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return DailyVerse(
      reference: data['reference'] as String? ?? '',
      text: data['text'] as String? ?? '',
      meditation: data['meditation'] as String?,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static DailyVerse fallback() => DailyVerse(
        reference: 'Philippiens 4:13',
        text: "Je puis tout par celui qui me fortifie.",
        date: DateTime.now(),
      );
}

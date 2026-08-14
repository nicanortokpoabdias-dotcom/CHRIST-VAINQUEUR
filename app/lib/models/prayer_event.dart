import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerEvent {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startAt;
  final bool isRecurringWeekly;
  final String? posterUrl;

  const PrayerEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startAt,
    this.isRecurringWeekly = false,
    this.posterUrl,
  });

  factory PrayerEvent.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return PrayerEvent(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      location: data['location'] as String? ?? 'Centre de Prière Christ Vainqueur',
      startAt: (data['startAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRecurringWeekly: data['isRecurringWeekly'] as bool? ?? false,
      posterUrl: data['posterUrl'] as String?,
    );
  }
}

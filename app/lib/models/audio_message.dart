import 'package:cloud_firestore/cloud_firestore.dart';

class AudioMessage {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final DateTime recordedAt;

  const AudioMessage({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.recordedAt,
  });

  factory AudioMessage.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return AudioMessage(
      id: doc.id,
      title: data['title'] as String? ?? 'Séance de prière',
      description: data['description'] as String? ?? '',
      audioUrl: data['audioUrl'] as String? ?? '',
      recordedAt: (data['recordedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class VideoItem {
  final String id;
  final String title;
  final String youtubeUrl;
  final DateTime publishedAt;

  const VideoItem({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    required this.publishedAt,
  });

  /// Extrait l'identifiant de la vidéo depuis une URL YouTube classique,
  /// courte (youtu.be) ou "shorts".
  String? get youtubeId {
    final uri = Uri.tryParse(youtubeUrl);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.pathSegments.contains('shorts')) {
      final index = uri.pathSegments.indexOf('shorts');
      return uri.pathSegments.length > index + 1 ? uri.pathSegments[index + 1] : null;
    }
    return uri.queryParameters['v'];
  }

  String? get thumbnailUrl {
    final id = youtubeId;
    if (id == null) return null;
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  factory VideoItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return VideoItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      youtubeUrl: data['youtubeUrl'] as String? ?? '',
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

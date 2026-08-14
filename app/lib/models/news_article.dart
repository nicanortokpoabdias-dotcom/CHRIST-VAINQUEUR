import 'package:cloud_firestore/cloud_firestore.dart';

class NewsArticle {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime publishedAt;
  final String category;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
    required this.category,
    this.imageUrl,
  });

  factory NewsArticle.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return NewsArticle(
      id: doc.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      category: data['category'] as String? ?? 'Actualité',
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

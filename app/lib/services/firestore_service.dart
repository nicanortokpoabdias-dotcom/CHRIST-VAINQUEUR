import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/daily_verse.dart';
import '../models/news_article.dart';
import '../models/prayer_event.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<NewsArticle>> watchNews() {
    return _db
        .collection('news')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(NewsArticle.fromFirestore).toList());
  }

  Stream<List<PrayerEvent>> watchUpcomingEvents() {
    final startOfToday = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return _db
        .collection('events')
        .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
        .orderBy('startAt')
        .snapshots()
        .map((snap) => snap.docs.map(PrayerEvent.fromFirestore).toList());
  }

  Stream<DailyVerse> watchDailyVerse() {
    return _db
        .collection('dailyVerse')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return DailyVerse.fallback();
      return DailyVerse.fromFirestore(snap.docs.first);
    });
  }
}

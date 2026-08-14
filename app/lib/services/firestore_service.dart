import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/daily_verse.dart';
import '../models/news_article.dart';
import '../models/prayer_event.dart';

/// Convertit les erreurs du flux (Firebase non configuré, réseau, permissions)
/// en une valeur de repli plutôt que de faire planter l'UI.
StreamTransformer<T, T> _fallbackOnError<T>(T fallback) {
  return StreamTransformer.fromHandlers(
    handleError: (error, stackTrace, sink) {
      debugPrint('Firestore indisponible, utilisation du contenu de repli: $error');
      sink.add(fallback);
    },
  );
}

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  Stream<List<NewsArticle>> watchNews() {
    try {
      return FirebaseFirestore.instance
          .collection('news')
          .orderBy('publishedAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(NewsArticle.fromFirestore).toList())
          .transform(_fallbackOnError(const <NewsArticle>[]));
    } catch (error) {
      debugPrint('Firestore indisponible: $error');
      return Stream.value(const <NewsArticle>[]);
    }
  }

  Stream<List<PrayerEvent>> watchUpcomingEvents() {
    try {
      final startOfToday = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      return FirebaseFirestore.instance
          .collection('events')
          .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .orderBy('startAt')
          .snapshots()
          .map((snap) => snap.docs.map(PrayerEvent.fromFirestore).toList())
          .transform(_fallbackOnError(const <PrayerEvent>[]));
    } catch (error) {
      debugPrint('Firestore indisponible: $error');
      return Stream.value(const <PrayerEvent>[]);
    }
  }

  Stream<DailyVerse> watchDailyVerse() {
    try {
      return FirebaseFirestore.instance
          .collection('dailyVerse')
          .orderBy('date', descending: true)
          .limit(1)
          .snapshots()
          .map((snap) => snap.docs.isEmpty ? DailyVerse.fallback() : DailyVerse.fromFirestore(snap.docs.first))
          .transform(_fallbackOnError(DailyVerse.fallback()));
    } catch (error) {
      debugPrint('Firestore indisponible: $error');
      return Stream.value(DailyVerse.fallback());
    }
  }
}

import 'package:flutter/material.dart';

import '../models/daily_verse.dart';
import '../models/news_article.dart';
import '../services/firestore_service.dart';
import '../widgets/news_card.dart';
import '../widgets/verse_banner.dart';
import 'news_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Christ Vainqueur')),
      body: CustomScrollView(
        slivers: [
            SliverToBoxAdapter(
              child: StreamBuilder<DailyVerse>(
                stream: FirestoreService.instance.watchDailyVerse(),
                builder: (context, snapshot) {
                  final verse = snapshot.data ?? DailyVerse.fallback();
                  return VerseBanner(verse: verse);
                },
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text(
                  'Actualités',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            StreamBuilder<List<NewsArticle>>(
              stream: FirestoreService.instance.watchNews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                final articles = snapshot.data ?? const [];
                if (articles.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          "Aucune actualité pour le moment.\nRevenez bientôt !",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return NewsCard(
                      article: article,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NewsDetailScreen(article: article),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

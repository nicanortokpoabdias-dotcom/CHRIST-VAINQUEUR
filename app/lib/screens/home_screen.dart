import 'package:flutter/material.dart';

import '../models/daily_verse.dart';
import '../models/news_article.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/news_card.dart';
import '../widgets/social_links_row.dart';
import '../widgets/verse_banner.dart';
import 'news_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.gradientHero),
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Image.asset(
                        'assets/images/logo_transparent.png',
                        width: 44,
                        height: 44,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _greeting,
                            style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w500),
                          ),
                          const Text(
                            'Christ Vainqueur',
                            style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<DailyVerse>(
              stream: FirestoreService.instance.watchDailyVerse(),
              builder: (context, snapshot) {
                final verse = snapshot.data ?? DailyVerse.fallback();
                return VerseBanner(verse: verse);
              },
            ),
          ),
          const SliverToBoxAdapter(child: SocialLinksRow()),
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
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.newspaper_outlined, size: 40, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          const Text(
                            "Aucune actualité pour le moment.\nRevenez bientôt !",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverList.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return FadeSlideIn(
                    delay: Duration(milliseconds: 60 * index),
                    child: NewsCard(
                      article: article,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NewsDetailScreen(article: article),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }
}

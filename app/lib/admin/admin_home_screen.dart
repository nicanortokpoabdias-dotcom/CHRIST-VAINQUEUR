import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_admin_screen.dart';
import 'events_admin_screen.dart';
import 'news_admin_screen.dart';
import 'verse_admin_screen.dart';
import 'videos_admin_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _lock(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cv_admin_unlocked');
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administration'),
          actions: [
            IconButton(
              tooltip: 'Verrouiller',
              icon: const Icon(Icons.lock_outline_rounded),
              onPressed: () => _lock(context),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.newspaper_outlined), text: 'Actualités'),
              Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Programme'),
              Tab(icon: Icon(Icons.headphones_outlined), text: 'Prières'),
              Tab(icon: Icon(Icons.play_circle_outline_rounded), text: 'Vidéos'),
              Tab(icon: Icon(Icons.auto_stories_outlined), text: 'Verset'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NewsAdminScreen(),
            EventsAdminScreen(),
            AudioAdminScreen(),
            VideosAdminScreen(),
            VerseAdminScreen(),
          ],
        ),
      ),
    );
  }
}

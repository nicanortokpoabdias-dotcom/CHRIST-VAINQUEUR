import 'package:flutter/material.dart';

import '../widgets/mini_player_bar.dart';
import '../widgets/modern_bottom_nav.dart';
import 'audio_screen.dart';
import 'events_screen.dart';
import 'home_screen.dart';
import 'videos_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const _screens = [HomeScreen(), EventsScreen(), AudioScreen(), VideosScreen()];

  static const _items = [
    NavItem(Icons.newspaper_outlined, Icons.newspaper, 'Actualités'),
    NavItem(Icons.calendar_month_outlined, Icons.calendar_month, 'Programme'),
    NavItem(Icons.headphones_outlined, Icons.headphones, 'Prières'),
    NavItem(Icons.play_circle_outline_rounded, Icons.play_circle_rounded, 'Vidéos'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerBar(),
          ModernBottomNav(
            index: _index,
            items: _items,
            onTap: (i) => setState(() => _index = i),
          ),
        ],
      ),
    );
  }
}

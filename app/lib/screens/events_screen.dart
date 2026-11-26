import 'package:flutter/material.dart';

import '../models/prayer_event.dart';
import '../services/firestore_service.dart';
import '../widgets/event_card.dart';
import '../widgets/fade_slide_in.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programme')),
      body: StreamBuilder<List<PrayerEvent>>(
        stream: FirestoreService.instance.watchUpcomingEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data ?? const [];
          if (events.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy_rounded, size: 40, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    const Text(
                      "Aucun événement programmé pour le moment.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
            itemCount: events.length,
            itemBuilder: (context, index) => FadeSlideIn(
              delay: Duration(milliseconds: 60 * index),
              child: EventCard(event: events[index]),
            ),
          );
        },
      ),
    );
  }
}

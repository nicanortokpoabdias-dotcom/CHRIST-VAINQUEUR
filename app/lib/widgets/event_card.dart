import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/prayer_event.dart';
import '../screens/poster_viewer_screen.dart';
import '../theme/app_theme.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final PrayerEvent event;

  @override
  Widget build(BuildContext context) {
    final hasPoster = event.posterUrl != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: hasPoster
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PosterViewerScreen(
                      imageUrl: event.posterUrl!,
                      title: event.title,
                    ),
                  ),
                )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasPoster)
              AspectRatio(
                aspectRatio: 16 / 10,
                child: CachedNetworkImage(
                  imageUrl: event.posterUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(color: AppColors.background),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.background,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('d', 'fr_FR').format(event.startAt),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          DateFormat('MMM', 'fr_FR').format(event.startAt).toUpperCase(),
                          style: const TextStyle(color: AppColors.gold, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.description,
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat("HH:mm", 'fr_FR').format(event.startAt),
                              style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

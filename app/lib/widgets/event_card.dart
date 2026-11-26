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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
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
                  placeholder: (_, _) => Container(color: AppColors.placeholder),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.placeholder,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientHero,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
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
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.description,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat("HH:mm", 'fr_FR').format(event.startAt),
                              style: TextStyle(fontSize: 12.5, color: Colors.grey[500]),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: TextStyle(fontSize: 12.5, color: Colors.grey[500]),
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

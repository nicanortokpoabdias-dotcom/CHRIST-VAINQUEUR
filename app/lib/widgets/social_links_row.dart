import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

class SocialLinksRow extends StatelessWidget {
  const SocialLinksRow({super.key});

  static final _links = [
    (
      label: 'YouTube',
      icon: Icons.play_circle_fill,
      color: const Color(0xFFFF0000),
      url: 'https://www.youtube.com/@christvainqueur3138',
    ),
    (
      label: 'TikTok',
      icon: Icons.music_note,
      color: Colors.black,
      url: 'https://www.tiktok.com/@christ.vainqueur29',
    ),
  ];

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: _links
            .map(
              (link) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton.icon(
                    onPressed: () => _open(link.url),
                    icon: Icon(link.icon, color: link.color, size: 20),
                    label: Text(link.label),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

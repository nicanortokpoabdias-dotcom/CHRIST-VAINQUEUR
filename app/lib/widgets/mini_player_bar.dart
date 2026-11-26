import 'package:flutter/material.dart';

import '../services/audio_player_service.dart';
import '../theme/app_theme.dart';

/// Barre flottante persistante montrant la piste audio en cours, visible
/// au-dessus de la navigation sur tous les onglets.
class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AudioPlayerService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final current = service.current;
        if (current == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppColors.gradientHero,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: const Icon(Icons.graphic_eq_rounded, color: AppColors.gold, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  current.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
              ),
              StreamBuilder<Duration>(
                stream: service.player.positionStream,
                builder: (context, snapshot) {
                  final total = service.player.duration;
                  final pos = snapshot.data ?? Duration.zero;
                  final progress = (total == null || total.inMilliseconds == 0)
                      ? 0.0
                      : (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
                  return SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      value: progress == 0 ? null : progress,
                      strokeWidth: 2.2,
                      color: AppColors.gold,
                      backgroundColor: Colors.white24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => service.toggle(current),
                child: Icon(
                  service.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

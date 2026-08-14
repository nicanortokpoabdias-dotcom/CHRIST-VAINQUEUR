import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/audio_message.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final _player = AudioPlayer();
  String? _playingId;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(AudioMessage message) async {
    if (_playingId == message.id) {
      await _player.pause();
      setState(() => _playingId = null);
      return;
    }
    try {
      await _player.setUrl(message.audioUrl);
      setState(() => _playingId = message.id);
      await _player.play();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de lire cet audio pour le moment.")),
      );
    }
  }

  Future<void> _download(AudioMessage message) async {
    final uri = Uri.parse(message.audioUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Prières & prédications')),
      body: StreamBuilder<List<AudioMessage>>(
        stream: FirestoreService.instance.watchAudioMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final messages = snapshot.data ?? const [];
          if (messages.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  "Aucun enregistrement pour le moment.\nRevenez après la prochaine séance.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: messages.length,
            itemBuilder: (context, index) => _AudioTile(
              message: messages[index],
              isPlaying: _playingId == messages[index].id,
              player: _player,
              onTogglePlay: () => _togglePlay(messages[index]),
              onDownload: () => _download(messages[index]),
            ),
          );
        },
      ),
    );
  }
}

class _AudioTile extends StatelessWidget {
  const _AudioTile({
    required this.message,
    required this.isPlaying,
    required this.player,
    required this.onTogglePlay,
    required this.onDownload,
  });

  final AudioMessage message;
  final bool isPlaying;
  final AudioPlayer player;
  final VoidCallback onTogglePlay;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onTogglePlay,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                    ),
                    const SizedBox(height: 3),
                    if (message.description.isNotEmpty)
                      Text(
                        message.description,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat("d MMMM yyyy", 'fr_FR').format(message.recordedAt),
                      style: TextStyle(color: Colors.grey[400], fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDownload,
                icon: const Icon(Icons.download_rounded),
                color: AppColors.gold,
                tooltip: 'Télécharger',
              ),
            ],
          ),
          if (isPlaying) ...[
            const SizedBox(height: 12),
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final total = player.duration ?? Duration.zero;
                final progress = total.inMilliseconds == 0
                    ? 0.0
                    : (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: AppColors.background,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDuration(position)} / ${_formatDuration(total)}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

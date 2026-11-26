import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/audio_message.dart';

/// Lecteur audio unique partagé par toute l'app, pour permettre un
/// mini-lecteur persistant visible sur tous les onglets (comme Spotify).
class AudioPlayerService extends ChangeNotifier {
  AudioPlayerService._() {
    _player.playerStateStream.listen((_) => notifyListeners());
  }

  static final AudioPlayerService instance = AudioPlayerService._();

  final AudioPlayer _player = AudioPlayer();
  AudioMessage? _current;

  AudioMessage? get current => _current;
  AudioPlayer get player => _player;
  bool get isPlaying => _player.playing;
  bool isCurrent(AudioMessage message) => _current?.id == message.id;

  Future<void> toggle(AudioMessage message) async {
    if (isCurrent(message)) {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
      notifyListeners();
      return;
    }

    _current = message;
    notifyListeners();
    try {
      await _player.setUrl(message.audioUrl);
      await _player.play();
    } catch (_) {
      _current = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _current = null;
    notifyListeners();
  }
}

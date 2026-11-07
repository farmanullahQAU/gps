import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Sound feedback manager for scanning and critical app interactions.
class SoundEffectService {
  static final SoundEffectService instance = SoundEffectService._internal();
  factory SoundEffectService() => instance;
  SoundEffectService._internal();

  AudioPlayer? _player;
  bool _muted = false;

  bool get isMuted => _muted;

  void setMuted(bool muted) {
    _muted = muted;
  }

  void toggleMute() {
    _muted = !_muted;
  }

  AudioPlayer get _audioPlayer {
    if (_player == null) {
      _player = AudioPlayer();
      _player!.setReleaseMode(ReleaseMode.stop);
      _player!.setPlayerMode(PlayerMode.lowLatency);
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ),
      );
    }
    return _player!;
  }

  /// Play crisp, positive chime when a student's QR is scanned and recorded.
  Future<void> playSuccess() async {
    HapticFeedback.lightImpact();
    if (_muted) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/scan_success.wav'), volume: 1.0);
    } catch (e) {
      debugPrint('SoundEffectService playSuccess error: $e');
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Play low warning/error buzz when a scan fails (wrong class, invalid QR, expired).
  Future<void> playError() async {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 140), () => HapticFeedback.heavyImpact());
    if (_muted) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/scan_error.wav'), volume: 1.0);
    } catch (e) {
      debugPrint('SoundEffectService playError error: $e');
      SystemSound.play(SystemSoundType.alert);
    }
  }

  /// Play short warning tone (e.g. card already scanned today).
  Future<void> playWarning() async {
    HapticFeedback.selectionClick();
    if (_muted) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/scan_warning.wav'), volume: 0.9);
    } catch (e) {
      debugPrint('SoundEffectService playWarning error: $e');
      SystemSound.play(SystemSoundType.click);
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}

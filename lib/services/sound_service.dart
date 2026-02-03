import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer(); // For looping sounds
  String? _currentSound;
  bool _soundEnabled = true;

  Future<void> playBettingSound() async {
    if (!_soundEnabled) return;
    
    // Check if betting sound is already playing
    if (_currentSound == 'betting') {
      debugPrint('ℹ️ Betting sound already playing, skip restart');
      return;
    }

    await _stopCurrentSound();
    try {
      await _player.play(AssetSource('sounds/betting.mp3'));
      _currentSound = 'betting';
      debugPrint('✅ Betting sound started');
    } catch (e) {
      debugPrint('❌ Betting sound not found: $e');
    }
  }

  Future<void> playRaceSound() async {
    // QUAN TRỌNG: Kiểm tra TRƯỚC để tránh phát lại
    if (_currentSound == 'race') {
      debugPrint('⚠️ Race sound already playing, skip');
      return;
    }
    
    if (!_soundEnabled) {
      debugPrint('⚠️ Sound disabled, skip race sound');
      return;
    }
    
    await _stopCurrentSound();    
    try {
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.play(AssetSource('sounds/race.mp3'));
      _currentSound = 'race';
      debugPrint('✅ Race sound started');
    } catch (e) {
      debugPrint('❌ Race sound not found: $e');
      _playFallbackRaceSound();
    }
  }

  void _playFallbackRaceSound() {
    debugPrint('🔊 Playing fallback race sound (galloping pattern)');
  }

  Future<void> playWinSound() async {
    if (!_soundEnabled) return;
    // Stop background music completely
    await _backgroundPlayer.stop();
    try {
      await _player.play(AssetSource('sounds/win.mp3'));
      _currentSound = 'win';
      debugPrint('✅ Win sound started');
    } catch (e) {
      debugPrint('❌ Win sound not found: $e');
    }
  }

  Future<void> playLoseSound() async {
    if (!_soundEnabled) return;
    // Stop background music completely
    await _backgroundPlayer.stop();
    try {
      await _player.play(AssetSource('sounds/lose.mp3'));
      _currentSound = 'lose';
      debugPrint('✅ Lose sound started');
    } catch (e) {
      debugPrint('❌ Lose sound not found: $e');
    }
  }

  Future<void> playStartClickSound() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/start_click.mp3'));
      _currentSound = 'start_click';
      debugPrint('✅ Start click sound started');
    } catch (e) {
      debugPrint('❌ Start click sound not found: $e');
    }
  }

  Future<void> playSummarySound() async {
    if (!_soundEnabled) return;
    await _stopCurrentSound();
    try {
      await _player.play(AssetSource('sounds/betting.mp3'));
      _currentSound = 'summary';
      debugPrint('✅ Summary sound started');
    } catch (e) {
      debugPrint('❌ Summary sound not found: $e');
    }
  }

  Future<void> playCountdownSound() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/countdown.mp3'));
      _currentSound = 'countdown';
      debugPrint('✅ Countdown sound started');
    } catch (e) {
      debugPrint('❌ Countdown sound not found: $e');
    }
  }

  Future<void> stopRaceSound() async {
    if (_currentSound == 'race') {
      debugPrint('🛑 Stopping race sound');
      await _backgroundPlayer.stop();
      _currentSound = null;
    }
  }

  Future<void> _stopCurrentSound() async {
    if (_currentSound != null) {
      debugPrint('🛑 Stopping sound: $_currentSound');
      await _player.stop();
      await _backgroundPlayer.stop();
      _currentSound = null;
    }
  }

  Future<void> stop() async {
    await _stopCurrentSound();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    debugPrint('🔊 Sound ${enabled ? "ENABLED" : "DISABLED"}');
    if (!enabled) {
      await stop();
    }
  }

  bool get isSoundEnabled => _soundEnabled;

  void dispose() {
    _player.dispose();
    _backgroundPlayer.dispose();
  }
}
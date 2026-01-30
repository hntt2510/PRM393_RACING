import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer(); // For looping sounds
  String? _currentSound;
  bool _soundEnabled = true;

  Future<void> playBettingSound() async {
    await _stopCurrentSound();
    try {
      await _player.play(AssetSource('sounds/betting.mp3'));
      _currentSound = 'betting';
    } catch (e) {
      // Sound file not found, continue silently
      print('Betting sound not found: $e');
    }
  }

  Future<void> playRaceSound() async {
    await _stopCurrentSound();
    try {
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop); // Loop race sound
      await _backgroundPlayer.play(AssetSource('sounds/race.mp3'));
      _currentSound = 'race';
    } catch (e) {
      print('Race sound not found: $e');
      // Fallback: Generate a simple tone for race sound
      _playFallbackRaceSound();
    }
  }

  // Fallback sound generation (simple beep pattern)
  void _playFallbackRaceSound() {
    // This is a placeholder - in a real app you'd use a proper sound generator
    // For now, we'll just log that sound is playing
    print('Playing fallback race sound (galloping pattern)');
  }

  Future<void> playWinSound() async {
    await _stopCurrentSound();
    try {
      await _player.play(AssetSource('sounds/win.mp3'));
      _currentSound = 'win';
    } catch (e) {
      print('Win sound not found: $e');
    }
  }

  Future<void> playLoseSound() async {
    await _stopCurrentSound();
    try {
      await _player.play(AssetSource('sounds/lose.mp3'));
      _currentSound = 'lose';
    } catch (e) {
      print('Lose sound not found: $e');
    }
  }

  Future<void> playSummarySound() async {
    await _stopCurrentSound();
    try {
      await _player.play(AssetSource('sounds/summary.mp3'));
      _currentSound = 'summary';
    } catch (e) {
      print('Summary sound not found: $e');
    }
  }

  Future<void> _stopCurrentSound() async {
    if (_currentSound != null) {
      await _player.stop();
      await _backgroundPlayer.stop();
      _currentSound = null;
    }
  }

  Future<void> stop() async {
    await _stopCurrentSound();
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) {
      stop();
    }
  }

  bool get isSoundEnabled => _soundEnabled;

  void dispose() {
    _player.dispose();
    _backgroundPlayer.dispose();
  }
}

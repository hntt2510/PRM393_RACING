import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/horse.dart';
import '../services/sound_service.dart';
import '../widgets/horse_widget.dart';
import 'result_screen.dart';

class RaceScreen extends StatefulWidget {
  final GameState gameState;
  final List<Horse> horses;

  const RaceScreen({super.key, required this.gameState, required this.horses});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> with TickerProviderStateMixin {
  final SoundService _soundService = SoundService();
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<Horse> _racingHorses;
  int? _winnerId;
  bool _raceFinished = false;
  int _countdown = 3;
  Timer? _countdownTimer;
  bool _soundStopped = false; // Track if sound has been stopped before finish

  @override
void initState() {
  super.initState();
  _racingHorses = widget.horses.map((h) => h.copyWith()).toList();

  // Initialize random speeds for each horse
  final random = Random();
  for (var horse in _racingHorses) {
    horse.speed = 0.5 + random.nextDouble() * 1.0;
  }

  // Create animation controllers...
  _controllers = List.generate(_racingHorses.length, (index) {
    final baseDuration = 4000;
    final duration = (baseDuration / _racingHorses[index].speed).round();
    return AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duration),
    );
  });

  // Create animations...
  _animations = _controllers.map((controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }).toList();

  _soundService.playRaceSound();

  
  // ✅ TIMEOUT: Dừng race sound sau 10 giây nếu chưa kết thúc
  Future.delayed(const Duration(seconds: 10), () {
    if (mounted && !_raceFinished) {
      debugPrint('⏰ Race timeout - stopping sound');
      _soundService.stop();
    }
  });
  
  _startCountdown();
}

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 1) {
            _countdown--;
          } else {
            _countdown = 0;
            timer.cancel();
            _startRace();
          }
        });
      }
    });
  }

  void _startRace() {
    // Nhạc race vẫn đang chạy từ lúc countdown, không cần phát lại

    // Start all animations with slight delay variations
    final random = Random();
    for (int i = 0; i < _controllers.length; i++) {
      final controller = _controllers[i];
      final animation = _animations[i];
      
      _controllers[i].addListener(() {
        if (mounted) {
          // Check if we should stop sound 1 second before finish
          if (!_soundStopped && !_raceFinished) {
            final animationValue = animation.value;
            final duration = controller.duration!.inMilliseconds;
            final remainingTime = (1.0 - animationValue) * duration;
            
            // Stop sound when less than 1 second remaining
            if (remainingTime <= 1000) {
              _soundStopped = true;
              _soundService.stopRaceSound();
              debugPrint('🔇 Stopping race sound 1 second before finish');
            }
          }
          
          setState(() {
            _racingHorses[i].position = animation.value;
          });
        }
      });

      _controllers[i].addStatusListener((status) {
        if (status == AnimationStatus.completed && !_raceFinished) {
          _raceFinished = true;
          _winnerId = _racingHorses[i].id;
          _finishRace();
        }
      });

      // Start with slight delay
      Future.delayed(Duration(milliseconds: random.nextInt(200)), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  void _finishRace() {
  // Dừng chỉ race sound, không dừng toàn bộ
  _soundService.stopRaceSound();
  
  // Tạo updatedState để kiểm tra thắng/thua
  final updatedState = widget.gameState.copyWith(winnerId: _winnerId);
  
  // Chuyển sang màn hình kết quả sau 2 giây
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      if (updatedState.hasWon) {
        updatedState.addWin();
      } else {
        updatedState.addLoss();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(gameState: updatedState),
        ),
      );
    }
  });
}

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    _soundService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Tracks occupying full space
              LayoutBuilder(
                builder: (context, constraints) {
                  final laneHeight =
                      constraints.maxHeight / (_racingHorses.length + 0.5);
                  final screenWidth = constraints.maxWidth;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ...List.generate(_racingHorses.length, (index) {
                        final horse = _racingHorses[index];
                        final topPosition = laneHeight * (index + 0.25);

                        return Positioned(
                          top: topPosition,
                          left: 0,
                          right: 0,
                          height: laneHeight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              // Semi-transparent dark track for better contrast with background image
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Track texture/lines - simpler white dashed lines
                                ...List.generate(20, (lineIndex) {
                                  return Positioned(
                                    left: (screenWidth / 20) * lineIndex,
                                    top: 10,
                                    bottom: 10,
                                    child: Container(
                                      width: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                      ),
                                    ),
                                  );
                                }),

                                // Enhanced Checkered Finish line
                                Positioned(
                                  right: 50,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 40,
                                    decoration: BoxDecoration(
                                      border: Border.symmetric(
                                        horizontal: BorderSide(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: CustomPaint(
                                      painter: CheckeredPainter(),
                                    ),
                                  ),
                                ),

                                // Horse
                                Positioned(
                                  left:
                                      (screenWidth - 160) *
                                      horse.position.clamp(0.0, 1.0),
                                  top: 0,
                                  bottom: 0,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: HorseWidget(
                                      horse: horse,
                                      size: laneHeight * 0.9,
                                      isRacing:
                                          _countdown == 0 && !_raceFinished,
                                      isWinner:
                                          _raceFinished &&
                                          _winnerId == horse.id,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),

              // Countdown Overlay with improved animation
              if (_countdown > 0)
                Container(
                  color: Colors.black87, // Darker overlay for focus
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                      child: Text(
                        '$_countdown',
                        key: ValueKey<int>(_countdown),
                        style: const TextStyle(
                          fontSize: 180,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          shadows: [
                            Shadow(
                              blurRadius: 30,
                              color: Colors.blueAccent,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // "GO!" Overlay
              if (_countdown == 0 &&
                  !_raceFinished &&
                  _racingHorses[0].position < 0.05)
                Positioned.fill(
                  child: Center(
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value * 1.5,
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: const Text(
                              'GO!',
                              style: TextStyle(
                                fontSize: 120,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Colors.greenAccent,
                                shadows: [
                                  Shadow(
                                    blurRadius: 20,
                                    color: Colors.black,
                                    offset: Offset(5, 5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Re-added CheckeredPainter
class CheckeredPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint blackPaint = Paint()..color = Colors.black;
    final Paint whitePaint = Paint()..color = Colors.white;
    const double squareSize = 10.0;

    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        if (((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, squareSize, squareSize),
            blackPaint,
          );
        } else {
          canvas.drawRect(
            Rect.fromLTWH(x, y, squareSize, squareSize),
            whitePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
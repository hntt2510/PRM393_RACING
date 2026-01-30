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

  const RaceScreen({
    super.key,
    required this.gameState,
    required this.horses,
  });

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen>
    with TickerProviderStateMixin {
  final SoundService _soundService = SoundService();
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<Horse> _racingHorses;
  int? _winnerId;
  bool _raceFinished = false;

  @override
  void initState() {
    super.initState();
    _racingHorses = widget.horses.map((h) => h.copyWith()).toList();
    
    // Initialize random speeds for each horse
    final random = Random();
    for (var horse in _racingHorses) {
      horse.speed = 0.5 + random.nextDouble() * 1.0; // 0.5x to 1.5x speed
    }

    // Create animation controllers with speed-based duration
    _controllers = List.generate(
      _racingHorses.length,
      (index) {
        // Base duration divided by speed (faster horse = shorter duration)
        final baseDuration = 4000; // 4 seconds base
        final duration = (baseDuration / _racingHorses[index].speed).round();
        return AnimationController(
          vsync: this,
          duration: Duration(milliseconds: duration),
        );
      },
    );

    // Create animations with smooth curves for natural movement
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic, // Smooth acceleration curve cho chuyển động tự nhiên
        ),
      );
    }).toList();

    // Start race
    _startRace();
    _soundService.playRaceSound();
  }

  void _startRace() {
    // Start all animations with slight delay variations
    final random = Random();
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        if (mounted) {
          setState(() {
            _racingHorses[i].position = _animations[i].value;
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
      Future.delayed(
        Duration(milliseconds: random.nextInt(200)),
        () {
          if (mounted) {
            _controllers[i].forward();
          }
        },
      );
    }
  }

  void _finishRace() {
    _soundService.stop();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final updatedState = widget.gameState.copyWith(winnerId: _winnerId);
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade300,
              Colors.green.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'GO!',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none, // Cho phép overflow nhưng sẽ xử lý trong widget
                  children: [
                    // Track lanes
                    ...List.generate(_racingHorses.length, (index) {
                      final horse = _racingHorses[index];
                      final screenWidth = MediaQuery.of(context).size.width;
                      final laneHeight = MediaQuery.of(context).size.height /
                          (_racingHorses.length + 1);
                      final topPosition = laneHeight * (index + 0.5);

                      return Positioned(
                        top: topPosition - 60,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.brown.shade500,
                                Colors.brown.shade400,
                                Colors.brown.shade300,
                                Colors.brown.shade400,
                                Colors.brown.shade500,
                              ],
                              stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                            ),
                            border: Border(
                              top: BorderSide(
                                color: Colors.brown.shade900,
                                width: 4,
                              ),
                              bottom: BorderSide(
                                color: Colors.brown.shade900,
                                width: 4,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
<<<<<<< HEAD
                              // Grass texture effect trên và dưới
=======
                              // Track lines để tạo hiệu ứng chuyển động
                              ...List.generate(10, (lineIndex) {
                                return Positioned(
                                  left: (screenWidth / 10) * lineIndex,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 2,
                                    color: Colors.brown.shade400.withValues(alpha: 0.5),
                                  ),
                                );
                              }),
                              // Finish line
>>>>>>> 219f1b72f0a1ef75edabce4282e7a7d65c87f9aa
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade700.withOpacity(0.4),
                                        Colors.green.shade500.withOpacity(0.3),
                                        Colors.green.shade400.withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                height: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade400.withOpacity(0.2),
                                        Colors.green.shade500.withOpacity(0.3),
                                        Colors.green.shade700.withOpacity(0.4),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Track lines để tạo hiệu ứng chuyển động với gradient đẹp hơn
                              ...List.generate(20, (lineIndex) {
                                return Positioned(
                                  left: (screenWidth / 20) * lineIndex,
                                  top: 8,
                                  bottom: 8,
                                  child: Container(
                                    width: 4,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withOpacity(0.8),
                                          Colors.white.withOpacity(0.4),
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.4),
                                          Colors.white.withOpacity(0.8),
                                        ],
                                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              // Finish line với design đẹp và không đè ngựa
                              Positioned(
                                right: 0,
                                top: 8,
                                bottom: 8,
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.red.shade900,
                                        Colors.red.shade700,
                                        Colors.red.shade600,
                                        Colors.red.shade700,
                                        Colors.red.shade900,
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.6),
                                        blurRadius: 15,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.flag,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'FINISH',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 3,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black,
                                              blurRadius: 6,
                                              offset: Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Horse với Lottie animation - đặt ở giữa track với khoảng cách đủ
                              Positioned(
                                left: (screenWidth - 120) * horse.position.clamp(0.0, 1.0),
                                top: 10,
                                child: Transform.translate(
                                  offset: Offset(0, 0),
                                  child: HorseWidget(
                                    horse: horse,
                                    size: 100,
                                    isRacing: !_raceFinished,
                                    isWinner: _raceFinished && _winnerId == horse.id,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

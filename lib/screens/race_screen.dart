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
                  children: [
                    // Track lanes
                    ...List.generate(_racingHorses.length, (index) {
                      final horse = _racingHorses[index];
                      final screenWidth = MediaQuery.of(context).size.width;
                      final laneHeight = MediaQuery.of(context).size.height /
                          (_racingHorses.length + 1);
                      final topPosition = laneHeight * (index + 0.5);

                      return Positioned(
                        top: topPosition - 40,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.brown.shade300,
                            border: Border(
                              top: BorderSide(color: Colors.brown.shade700, width: 2),
                              bottom: BorderSide(color: Colors.brown.shade700, width: 2),
                            ),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none, // Cho phép ngựa di chuyển tự do
                            children: [
                              // Track lines để tạo hiệu ứng chuyển động
                              ...List.generate(10, (lineIndex) {
                                return Positioned(
                                  left: (screenWidth / 10) * lineIndex,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 2,
                                    color: Colors.brown.shade400.withOpacity(0.5),
                                  ),
                                );
                              }),
                              // Finish line
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade700,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'FINISH',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Horse - gắn chặt vào track với animation mượt
                              Positioned(
                                left: (screenWidth - 60) * horse.position.clamp(0.0, 1.0),
                                top: 10,
                                child: Transform.translate(
                                  offset: Offset(0, 0),
                                  child: HorseWidget(horse: horse, size: 60),
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

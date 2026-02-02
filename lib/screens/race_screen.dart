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
    _controllers = List.generate(_racingHorses.length, (index) {
      // Base duration divided by speed (faster horse = shorter duration)
      final baseDuration = 4000; // 4 seconds base
      final duration = (baseDuration / _racingHorses[index].speed).round();
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: duration),
      );
    });

    // Create animations with smooth curves for natural movement
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves
              .easeOutCubic, // Smooth acceleration curve cho chuyển động tự nhiên
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
      Future.delayed(Duration(milliseconds: random.nextInt(200)), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
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
                        final topPosition =
                            laneHeight * (index + 0.25); // Start a bit lower

                        return Positioned(
                          top: topPosition,
                          left: 0,
                          right: 0,
                          height: laneHeight,
                          child: Container(
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
                                  width: 2,
                                ),
                                bottom: BorderSide(
                                  color: Colors.brown.shade900,
                                  width: 2,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Track texture/lines
                                ...List.generate(20, (lineIndex) {
                                  return Positioned(
                                    left: (screenWidth / 20) * lineIndex,
                                    top: 4,
                                    bottom: 4,
                                    child: Container(
                                      width: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                  );
                                }),
                                // Finish line
                                Positioned(
                                  right: 40,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.white, Colors.black],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        tileMode: TileMode.repeated,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'FINISH',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          letterSpacing: 2,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 2,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.ltr,
                                      ),
                                    ),
                                  ),
                                ),
                                // Horse
                                Positioned(
                                  left:
                                      (screenWidth - 150) *
                                      horse.position.clamp(0.0, 1.0),
                                  top: 0,
                                  bottom: 0,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: HorseWidget(
                                      horse: horse,
                                      size: laneHeight * 0.9, // Dynamic size
                                      isRacing: !_raceFinished,
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
              // "GO!" Overlay
              if (!_raceFinished)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'RACING!',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.yellowAccent,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(3.0, 3.0),
                          ),
                          Shadow(
                            blurRadius: 20.0,
                            color: Colors.red,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
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

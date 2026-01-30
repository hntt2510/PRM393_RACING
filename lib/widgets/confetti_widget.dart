import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiEffectWidget extends StatefulWidget {
  final bool isPlaying;

  const ConfettiEffectWidget({
    super.key,
    required this.isPlaying,
  });

  @override
  State<ConfettiEffectWidget> createState() => _ConfettiEffectWidgetState();
}

class _ConfettiEffectWidgetState extends State<ConfettiEffectWidget> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    if (widget.isPlaying) {
      _confettiController.play();
    }
  }

  @override
  void didUpdateWidget(ConfettiEffectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _confettiController.play();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _confettiController.stop();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: pi / 2, // Downward
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        gravity: 0.1,
        shouldLoop: false,
        colors: const [
          Colors.blue,
          Colors.yellow,
          Colors.pink,
          Colors.orange,
          Colors.green,
          Colors.purple,
        ],
      ),
    );
  }
}

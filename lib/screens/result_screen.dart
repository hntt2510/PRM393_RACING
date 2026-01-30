import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/horse.dart';
import '../services/sound_service.dart';
import '../widgets/horse_widget.dart';
import '../widgets/confetti_widget.dart';
import 'betting_screen.dart';
import 'summary_screen.dart';

class ResultScreen extends StatefulWidget {
  final GameState gameState;

  const ResultScreen({
    super.key,
    required this.gameState,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final SoundService _soundService = SoundService();
  late Horse _winnerHorse;
  late bool _hasWon;

  @override
  void initState() {
    super.initState();
    _hasWon = widget.gameState.hasWon;
    
    // Find winner horse
    final winnerId = widget.gameState.winnerId ?? 1;
    final horses = [
      Horse(id: 1, name: 'Horse 1', color: Colors.brown),
      Horse(id: 2, name: 'Horse 2', color: Colors.white),
      Horse(id: 3, name: 'Horse 3', color: Colors.black),
    ];
    _winnerHorse = horses.firstWhere((h) => h.id == winnerId);

    // Play appropriate sound
    if (_hasWon) {
      _soundService.playWinSound();
    } else {
      _soundService.playLoseSound();
    }
  }

  void _playAgain() {
    _soundService.stop();
    final resetState = widget.gameState.copyWith();
    resetState.resetBets();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BettingScreen(gameState: resetState),
      ),
    );
  }

  void _goToSummary() {
    _soundService.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(gameState: widget.gameState),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          ),
          if (_hasWon) const ConfettiEffectWidget(isPlaying: true),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Race Results',
                    style: TextStyle(
                      fontSize: 32,
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
                  const SizedBox(height: 8),
                  Text(
                    '${_winnerHorse.name} Wins!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Wreath decoration
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green,
                            width: 8,
                          ),
                        ),
                      ),
                      HorseWidget(
                        horse: _winnerHorse,
                        isWinner: true,
                        size: 120,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Card(
                    color: Colors.white.withValues(alpha: 0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            _hasWon ? '🎉 Congratulations! 🎉' : 'Better luck next time!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _hasWon ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _hasWon ? 'Your Bet:' : 'You Bet On:',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _hasWon
                                    ? widget.gameState.bets[_winnerHorse.id]?.toStringAsFixed(0) ?? '0'
                                    : widget.gameState.totalBetAmount.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Payout:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.gameState.payout.toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _hasWon ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _playAgain,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'PLAY AGAIN',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _goToSummary,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'SUMMARY',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

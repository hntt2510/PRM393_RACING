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

  const ResultScreen({super.key, required this.gameState});

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
      Horse(id: 1, name: 'Thunder', color: Colors.brown),
      Horse(
        id: 2,
        name: 'Lightning',
        color: const Color(0xFF42A5F5),
      ), // Blue 400
      Horse(id: 3, name: 'Shadow', color: const Color(0xFF424242)), // Grey 800
      Horse(id: 4, name: 'Blaze', color: const Color(0xFFFB8C00)), // Orange 600
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (_hasWon) const ConfettiEffectWidget(isPlaying: true),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // LEFT SIDE: Winner Visuals
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const Text(
                        //   'Race Results',
                        //   style: TextStyle(
                        //     fontSize: 32,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.white,
                        //     shadows: [
                        //       Shadow(
                        //         blurRadius: 10.0,
                        //         color: Colors.black,
                        //         offset: Offset(2.0, 2.0),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        const SizedBox(height: 16),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Wreath decoration
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.green,
                                  width: 8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            HorseWidget(
                              horse: _winnerHorse,
                              isWinner: true,
                              isRacing: false,
                              size: 100,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_winnerHorse.name} Wins!',
                          style: const TextStyle(
                            fontSize: 24,
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // RIGHT SIDE: Stats and Buttons
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _hasWon
                                      ? '🎉 Congratulations! 🎉'
                                      : 'Better luck next time!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _hasWon ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _hasWon ? 'Your Bet:' : 'You Bet On:',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _hasWon
                                          ? widget
                                                    .gameState
                                                    .bets[_winnerHorse.id]
                                                    ?.toStringAsFixed(0) ??
                                                '0'
                                          : widget.gameState.totalBetAmount
                                                .toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Payout:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.gameState.payout.toStringAsFixed(
                                        0,
                                      ),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _hasWon
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
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
                                      fontSize: 16,
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
                                      fontSize: 16,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

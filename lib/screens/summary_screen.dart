import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/sound_service.dart';
import 'betting_screen.dart';

class SummaryScreen extends StatefulWidget {
  final GameState gameState;

  const SummaryScreen({super.key, required this.gameState});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    _soundService.playSummarySound();
  }

  void _goToMainMenu() {
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // LEFT SIDE: Title and Decoration
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Game Summary',
                        style: TextStyle(
                          fontSize: 40,
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
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.monetization_on,
                              color: Colors.amber.shade700,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // RIGHT SIDE: Stats Card and Button
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            _buildStatRow(
                              'Total Bets:',
                              widget.gameState.totalBets.toStringAsFixed(0),
                              Colors.blue,
                            ),
                            const Divider(height: 20),
                            _buildStatRow(
                              'Wins:',
                              widget.gameState.totalWins.toString(),
                              Colors.green,
                            ),
                            const Divider(height: 20),
                            _buildStatRow(
                              'Losses:',
                              widget.gameState.totalLosses.toString(),
                              Colors.red,
                            ),
                            const Divider(height: 20),
                            _buildStatRow(
                              'Final Balance:',
                              widget.gameState.balance.toStringAsFixed(0),
                              Colors.amber.shade700,
                              isLarge: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _goToMainMenu,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home, color: Colors.amber.shade300),
                              const SizedBox(width: 8),
                              const Text(
                                'MAIN MENU',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color valueColor, {
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 20 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 22 : 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

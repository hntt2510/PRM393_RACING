import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/sound_service.dart';
import 'betting_screen.dart';

class SummaryScreen extends StatefulWidget {
  final GameState gameState;

  const SummaryScreen({
    super.key,
    required this.gameState,
  });

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.amber.shade300,
              Colors.orange.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Game Summary',
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
                const SizedBox(height: 40),
                // Scroll banner with statistics
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
                      // Gold coins decoration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.monetization_on,
                              color: Colors.amber.shade700,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildStatRow(
                        'Total Bets:',
                        widget.gameState.totalBets.toStringAsFixed(0),
                        Colors.blue,
                      ),
                      const Divider(height: 30),
                      _buildStatRow(
                        'Wins:',
                        widget.gameState.totalWins.toString(),
                        Colors.green,
                      ),
                      const Divider(height: 30),
                      _buildStatRow(
                        'Losses:',
                        widget.gameState.totalLosses.toString(),
                        Colors.red,
                      ),
                      const Divider(height: 30),
                      _buildStatRow(
                        'Final Balance:',
                        widget.gameState.balance.toStringAsFixed(0),
                        Colors.amber.shade700,
                        isLarge: true,
                      ),
                      const SizedBox(height: 20),
                      // More gold coins
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.monetization_on,
                              color: Colors.amber.shade700,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
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
                        Icon(
                          Icons.monetization_on,
                          color: Colors.amber.shade300,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'MAIN MENU',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.monetization_on,
                          color: Colors.amber.shade300,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor,
      {bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 22 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

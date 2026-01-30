import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/horse.dart';
import '../services/sound_service.dart';
import '../widgets/horse_widget.dart';
import 'race_screen.dart';

class BettingScreen extends StatefulWidget {
  final GameState gameState;

  const BettingScreen({
    super.key,
    required this.gameState,
  });

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  final List<TextEditingController> _betControllers = [];
  final SoundService _soundService = SoundService();
  late GameState _gameState;
  final List<Horse> _horses = [
    Horse(id: 1, name: 'Horse 1', color: Colors.brown),
    Horse(id: 2, name: 'Horse 2', color: Colors.white),
    Horse(id: 3, name: 'Horse 3', color: Colors.black),
  ];

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState;
    for (int i = 0; i < _horses.length; i++) {
      _betControllers.add(TextEditingController(
        text: _gameState.bets[_horses[i].id]?.toString() ?? '',
      ));
    }
    _soundService.playBettingSound();
  }

  @override
  void dispose() {
    for (var controller in _betControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double _getTotalBet() {
    double total = 0.0;
    for (int i = 0; i < _betControllers.length; i++) {
      final value = double.tryParse(_betControllers[i].text) ?? 0.0;
      total += value;
    }
    return total;
  }

  void _startRace() {
    final totalBet = _getTotalBet();
    if (totalBet > _gameState.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tổng tiền cược vượt quá số dư!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (totalBet == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đặt cược ít nhất một con ngựa!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Update bets
    final newBets = <int, double>{};
    for (int i = 0; i < _betControllers.length; i++) {
      final bet = double.tryParse(_betControllers[i].text) ?? 0.0;
      if (bet > 0) {
        newBets[_horses[i].id] = bet;
      }
    }

    final updatedState = _gameState.copyWith(bets: newBets);
    _soundService.stop();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RaceScreen(
          gameState: updatedState,
          horses: _horses,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalBet = _getTotalBet();
    final remainingBalance = _gameState.balance - totalBet;

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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Place Your Bets!',
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
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _horses.length,
                    itemBuilder: (context, index) {
                      final horse = _horses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              HorseWidget(horse: horse, size: 80),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      horse.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text(
                                          'Bet: ',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: _betControllers[index],
                                            keyboardType:
                                                TextInputType.number,
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                            ),
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.check_circle,
                                          color: (double.tryParse(
                                                      _betControllers[index]
                                                          .text) ??
                                                  0.0) >
                                                  0
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Bet:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${totalBet.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Balance:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${remainingBalance.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: remainingBalance >= 0
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _startRace,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'START RACE',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
}

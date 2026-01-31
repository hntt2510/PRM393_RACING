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
    Horse(id: 1, name: 'Thunder', color: Colors.brown),
    Horse(id: 2, name: 'Lightning', color: const Color(0xFF42A5F5)), // Blue 400
    Horse(id: 3, name: 'Shadow', color: const Color(0xFF424242)), // Grey 800
    Horse(id: 4, name: 'Blaze', color: const Color(0xFFFB8C00)), // Orange 600
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

    // Update bets và trừ tiền cược ngay lập tức
    final newBets = <int, double>{};
    for (int i = 0; i < _betControllers.length; i++) {
      final bet = double.tryParse(_betControllers[i].text) ?? 0.0;
      if (bet > 0) {
        newBets[_horses[i].id] = bet;
      }
    }

    // QUAN TRỌNG: Trừ tiền cược khỏi balance ngay khi bắt đầu race
    // Tiền này sẽ KHÔNG được hoàn lại, dù thắng hay thua
    // Nếu thắng, chỉ cộng thêm tiền thưởng (payout) vào
    final newBalance = _gameState.balance - totalBet;
    final updatedState = _gameState.copyWith(
      bets: newBets,
      balance: newBalance,
    );
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber.shade300,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
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
                    const SizedBox(width: 12),
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber.shade300,
                      size: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _horses.length,
                    itemBuilder: (context, index) {
                      final horse = _horses[index];
                      final hasBet = (double.tryParse(
                                  _betControllers[index].text) ??
                              0.0) >
                          0;
                      final betAmount = double.tryParse(
                              _betControllers[index].text) ??
                          0.0;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: hasBet
                                ? [
                                    horse.color.withOpacity(0.4),
                                    horse.color.withOpacity(0.2),
                                    horse.color.withOpacity(0.1),
                                  ]
                                : [
                                    Colors.white,
                                    Colors.grey.shade50,
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: hasBet
                                  ? horse.color.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              spreadRadius: 3,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: hasBet
                                ? horse.color.withOpacity(0.6)
                                : Colors.grey.shade300,
                            width: hasBet ? 3 : 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Horse number badge với design đẹp hơn
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      horse.color,
                                      horse.color.withOpacity(0.8),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: horse.color.withOpacity(0.6),
                                      blurRadius: 10,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '#${horse.id}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 4,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Horse animation với kích thước vừa phải
                              SizedBox(
                                width: 90,
                                height: 90,
                                child: HorseWidget(
                                  horse: horse,
                                  size: 80,
                                  isRacing: false,
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Thông tin và input
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Tên ngựa và badge bet
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            horse.name,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: hasBet
                                                  ? horse.color
                                                  : Colors.grey.shade800,
                                              letterSpacing: 0.5,
                                              shadows: hasBet
                                                  ? [
                                                      Shadow(
                                                        color: horse.color
                                                            .withOpacity(0.3),
                                                        blurRadius: 8,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        if (hasBet)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.green.shade600,
                                                  Colors.green.shade400,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.green
                                                      .withOpacity(0.4),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  betAmount.toStringAsFixed(0),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Input field với design đẹp hơn
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: horse.color.withOpacity(0.2),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _betControllers[index],
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: horse.color,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Nhập số tiền cược',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 16,
                                          ),
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(8),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: horse.color.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.account_balance_wallet,
                                              color: horse.color,
                                              size: 24,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: BorderSide(
                                              color: horse.color.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: BorderSide(
                                              color: horse.color.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: BorderSide(
                                              color: horse.color,
                                              width: 3,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 16),
                                        ),
                                        onChanged: (_) => setState(() {}),
                                      ),
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
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.95),
                        Colors.blue.shade50.withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.casino,
                                  color: Colors.blue.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Total Bet:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${totalBet.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, thickness: 2),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: remainingBalance >= 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Balance:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: remainingBalance >= 0
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${remainingBalance.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: remainingBalance >= 0
                                      ? Colors.green.shade900
                                      : Colors.red.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade600,
                        Colors.green.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _startRace,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'START RACE',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.emoji_events,
                          size: 28,
                          color: Colors.amber,
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
}

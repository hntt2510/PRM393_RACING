class GameState {
  double balance;
  Map<int, double> bets; // horseId -> betAmount
  int? winnerId;
  int totalWins;
  int totalLosses;
  double totalBets;

  GameState({
    this.balance = 1000.0,
    Map<int, double>? bets,
    this.winnerId,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.totalBets = 0.0,
  }) : bets = bets ?? {};

  double get totalBetAmount {
    return bets.values.fold(0.0, (sum, bet) => sum + bet);
  }

  bool get hasWon {
    if (winnerId == null) return false;
    return bets.containsKey(winnerId) && bets[winnerId]! > 0;
  }

  double get payout {
    if (!hasWon || winnerId == null) return 0.0;
    // Payout = tiền cược con thắng * 2 (đã bao gồm tiền thưởng, KHÔNG bao gồm tiền cược gốc)
    // Ví dụ: cược 100 → thắng được 200 (tiền cược 100 đã bị trừ rồi, chỉ cộng 200 vào)
    return bets[winnerId]! * 2.0;
  }

  void resetBets() {
    bets.clear();
    winnerId = null;
  }

  void addWin() {
    totalWins++;
    totalBets += totalBetAmount;
    // Tiền cược đã được trừ khi bắt đầu race (trong betting_screen)
    // Giờ chỉ cộng tiền thưởng vào (KHÔNG hoàn lại tiền cược)
    // Ví dụ: cược 100 → đã trừ 100 → thắng cộng 200 → tổng lời: +100
    balance += payout;
  }

  void addLoss() {
    totalLosses++;
    totalBets += totalBetAmount;
    // Tiền cược đã được trừ khi bắt đầu race, không cần làm gì thêm
  }

  GameState copyWith({
    double? balance,
    Map<int, double>? bets,
    int? winnerId,
    int? totalWins,
    int? totalLosses,
    double? totalBets,
  }) {
    return GameState(
      balance: balance ?? this.balance,
      bets: bets ?? Map.from(this.bets),
      winnerId: winnerId ?? this.winnerId,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      totalBets: totalBets ?? this.totalBets,
    );
  }
}

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
    return bets[winnerId]! * 2.0; // 2x payout
  }

  void resetBets() {
    bets.clear();
    winnerId = null;
  }

  void addWin() {
    totalWins++;
    totalBets += totalBetAmount;
    if (winnerId != null && bets.containsKey(winnerId)) {
      // Subtract bet amount first, then add payout (net gain = bet amount)
      balance -= bets[winnerId]!;
      balance += payout;
    }
  }

  void addLoss() {
    totalLosses++;
    totalBets += totalBetAmount;
    balance -= totalBetAmount;
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

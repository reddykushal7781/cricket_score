class Player {
  final int? id;
  final String name;
  final int matchesPlayed;
  final int runsScored;
  final int ballsFaced;
  final int wicketsTaken;
  final int ballsBowled;
  final int runsConceded;
  final int catches;
  final int highestScore;

  Player({
    this.id,
    required this.name,
    this.matchesPlayed = 0,
    this.runsScored = 0,
    this.ballsFaced = 0,
    this.wicketsTaken = 0,
    this.ballsBowled = 0,
    this.runsConceded = 0,
    this.catches = 0,
    this.highestScore = 0,
  });

  Player copyWith({
    int? id,
    String? name,
    int? matchesPlayed,
    int? runsScored,
    int? ballsFaced,
    int? wicketsTaken,
    int? ballsBowled,
    int? runsConceded,
    int? catches,
    int? highestScore,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      runsScored: runsScored ?? this.runsScored,
      ballsFaced: ballsFaced ?? this.ballsFaced,
      wicketsTaken: wicketsTaken ?? this.wicketsTaken,
      ballsBowled: ballsBowled ?? this.ballsBowled,
      runsConceded: runsConceded ?? this.runsConceded,
      catches: catches ?? this.catches,
      highestScore: highestScore ?? this.highestScore,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'matches_played': matchesPlayed,
      'runs_scored': runsScored,
      'balls_faced': ballsFaced,
      'wickets_taken': wicketsTaken,
      'balls_bowled': ballsBowled,
      'runs_conceded': runsConceded,
      'catches': catches,
      'highest_score': highestScore,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as int?,
      name: map['name'] as String,
      matchesPlayed: map['matches_played'] as int? ?? 0,
      runsScored: map['runs_scored'] as int? ?? 0,
      ballsFaced: map['balls_faced'] as int? ?? 0,
      wicketsTaken: map['wickets_taken'] as int? ?? 0,
      ballsBowled: map['balls_bowled'] as int? ?? 0,
      runsConceded: map['runs_conceded'] as int? ?? 0,
      catches: map['catches'] as int? ?? 0,
      highestScore: map['highest_score'] as int? ?? 0,
    );
  }

  // Helper getters for dynamic calculations
  double get battingStrikeRate {
    if (ballsFaced == 0) return 0.0;
    return (runsScored / ballsFaced) * 100.0;
  }

  double get battingAverage {
    if (matchesPlayed == 0) return 0.0;
    return runsScored / matchesPlayed;
  }

  double get bowlingEconomy {
    if (ballsBowled == 0) return 0.0;
    double overs = ballsBowled / 6.0;
    return runsConceded / overs;
  }

  double get bowlingAverage {
    if (wicketsTaken == 0) return 0.0;
    return runsConceded / wicketsTaken;
  }
}

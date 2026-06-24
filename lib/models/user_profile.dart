class UserProfile {
  final String email;
  final String name;
  final String avatarUrl;
  final String role;
  final String battingStyle;
  final String bowlingStyle;
  final BattingStats battingStats;
  final BowlingStats bowlingStats;
  final FieldingStats fieldingStats;

  UserProfile({
    required this.email,
    required this.name,
    required this.avatarUrl,
    required this.role,
    required this.battingStyle,
    required this.bowlingStyle,
    required this.battingStats,
    required this.bowlingStats,
    required this.fieldingStats,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    return UserProfile(
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      role: json['role'] as String,
      battingStyle: json['battingStyle'] as String,
      bowlingStyle: json['bowlingStyle'] as String,
      battingStats:
          BattingStats.fromJson(stats['batting'] as Map<String, dynamic>),
      bowlingStats:
          BowlingStats.fromJson(stats['bowling'] as Map<String, dynamic>),
      fieldingStats:
          FieldingStats.fromJson(stats['fielding'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role,
      'battingStyle': battingStyle,
      'bowlingStyle': bowlingStyle,
      'stats': {
        'batting': battingStats.toJson(),
        'bowling': bowlingStats.toJson(),
        'fielding': fieldingStats.toJson(),
      },
    };
  }
}

class BattingStats {
  final int matches;
  final int innings;
  final int runs;
  final int ballsFaced;
  final double average;
  final double strikeRate;
  final String highestScore;
  final int notOuts;
  final int fifties;
  final int hundreds;
  final int fours;
  final int sixes;

  BattingStats({
    required this.matches,
    required this.innings,
    required this.runs,
    required this.ballsFaced,
    required this.average,
    required this.strikeRate,
    required this.highestScore,
    required this.notOuts,
    required this.fifties,
    required this.hundreds,
    required this.fours,
    required this.sixes,
  });

  factory BattingStats.fromJson(Map<String, dynamic> json) {
    return BattingStats(
      matches: json['matches'] as int,
      innings: json['innings'] as int,
      runs: json['runs'] as int,
      ballsFaced: json['ballsFaced'] as int,
      average: (json['average'] as num).toDouble(),
      strikeRate: (json['strikeRate'] as num).toDouble(),
      highestScore: json['highestScore'] as String,
      notOuts: json['notOuts'] as int,
      fifties: json['fifties'] as int,
      hundreds: json['hundreds'] as int,
      fours: json['fours'] as int,
      sixes: json['sixes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matches': matches,
      'innings': innings,
      'runs': runs,
      'ballsFaced': ballsFaced,
      'average': average,
      'strikeRate': strikeRate,
      'highestScore': highestScore,
      'notOuts': notOuts,
      'fifties': fifties,
      'hundreds': hundreds,
      'fours': fours,
      'sixes': sixes,
    };
  }
}

class BowlingStats {
  final int matches;
  final int innings;
  final int wickets;
  final int runsConceded;
  final int ballsBowled;
  final double economy;
  final double average;
  final double strikeRate;
  final String bestBowling;
  final int threeWickets;
  final int fiveWickets;

  BowlingStats({
    required this.matches,
    required this.innings,
    required this.wickets,
    required this.runsConceded,
    required this.ballsBowled,
    required this.economy,
    required this.average,
    required this.strikeRate,
    required this.bestBowling,
    required this.threeWickets,
    required this.fiveWickets,
  });

  factory BowlingStats.fromJson(Map<String, dynamic> json) {
    return BowlingStats(
      matches: json['matches'] as int,
      innings: json['innings'] as int,
      wickets: json['wickets'] as int,
      runsConceded: json['runsConceded'] as int,
      ballsBowled: json['ballsBowled'] as int,
      economy: (json['economy'] as num).toDouble(),
      average: (json['average'] as num).toDouble(),
      strikeRate: (json['strikeRate'] as num).toDouble(),
      bestBowling: json['bestBowling'] as String,
      threeWickets: json['threeWickets'] as int,
      fiveWickets: json['fiveWickets'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matches': matches,
      'innings': innings,
      'wickets': wickets,
      'runsConceded': runsConceded,
      'ballsBowled': ballsBowled,
      'economy': economy,
      'average': average,
      'strikeRate': strikeRate,
      'bestBowling': bestBowling,
      'threeWickets': threeWickets,
      'fiveWickets': fiveWickets,
    };
  }
}

class FieldingStats {
  final int catches;
  final int stumpings;
  final int runOuts;

  FieldingStats({
    required this.catches,
    required this.stumpings,
    required this.runOuts,
  });

  factory FieldingStats.fromJson(Map<String, dynamic> json) {
    return FieldingStats(
      catches: json['catches'] as int,
      stumpings: json['stumpings'] as int,
      runOuts: json['runOuts'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catches': catches,
      'stumpings': stumpings,
      'runOuts': runOuts,
    };
  }
}

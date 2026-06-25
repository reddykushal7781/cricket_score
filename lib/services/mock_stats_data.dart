import '../models/user_profile.dart';

class DayStats {
  final String date;
  final int matchesPlayed;
  final List<TopBatsman> topBatsmen;
  final List<TopBowler> topBowlers;
  final List<TopDotBallBowler> topDotBowlers;

  DayStats({
    required this.date,
    required this.matchesPlayed,
    required this.topBatsmen,
    required this.topBowlers,
    required this.topDotBowlers,
  });
}

class TopBatsman {
  final String name;
  final int runs;
  final int balls;
  final double strikeRate;

  TopBatsman({
    required this.name,
    required this.runs,
    required this.balls,
    required this.strikeRate,
  });
}

class TopBowler {
  final String name;
  final int wickets;
  final int runsConceded;
  final double overs;

  TopBowler({
    required this.name,
    required this.wickets,
    required this.runsConceded,
    required this.overs,
  });
}

class TopDotBallBowler {
  final String name;
  final int dotBalls;
  final double overs;

  TopDotBallBowler({
    required this.name,
    required this.dotBalls,
    required this.overs,
  });
}

class MockStatsData {
  static final List<UserProfile> mockPlayers = [
    UserProfile(
      username: "virat_kohli",
      name: "Virat Kohli",
      avatarUrl:
          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80",
      role: "Top-order Batsman",
      battingStyle: "Right-hand bat",
      bowlingStyle: "Right-arm medium",
      battingStats: BattingStats(
        matches: 124,
        innings: 118,
        runs: 5412,
        ballsFaced: 3820,
        average: 49.20,
        strikeRate: 141.67,
        highestScore: "122*",
        notOuts: 18,
        fifties: 38,
        hundreds: 6,
        fours: 492,
        sixes: 152,
      ),
      bowlingStats: BowlingStats(
        matches: 124,
        innings: 15,
        wickets: 4,
        runsConceded: 165,
        ballsBowled: 120,
        economy: 8.25,
        average: 41.25,
        strikeRate: 30.0,
        bestBowling: "1/11",
        threeWickets: 0,
        fiveWickets: 0,
      ),
      fieldingStats: FieldingStats(
        catches: 68,
        stumpings: 0,
        runOuts: 14,
      ),
    ),
    UserProfile(
      username: "jasprit_bumrah",
      name: "Jasprit Bumrah",
      avatarUrl:
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80",
      role: "Bowler",
      battingStyle: "Right-hand bat",
      bowlingStyle: "Right-arm fast",
      battingStats: BattingStats(
        matches: 98,
        innings: 42,
        runs: 198,
        ballsFaced: 232,
        average: 6.19,
        strikeRate: 85.34,
        highestScore: "27",
        notOuts: 10,
        fifties: 0,
        hundreds: 0,
        fours: 18,
        sixes: 4,
      ),
      bowlingStats: BowlingStats(
        matches: 98,
        innings: 96,
        wickets: 156,
        runsConceded: 2240,
        ballsBowled: 2304,
        economy: 5.83,
        average: 14.36,
        strikeRate: 14.77,
        bestBowling: "6/19",
        threeWickets: 14,
        fiveWickets: 4,
      ),
      fieldingStats: FieldingStats(
        catches: 24,
        stumpings: 0,
        runOuts: 6,
      ),
    ),
    UserProfile(
      username: "rohit_sharma",
      name: "Rohit Sharma",
      avatarUrl:
          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80",
      role: "Opening Batsman",
      battingStyle: "Right-hand bat",
      bowlingStyle: "Right-arm offbreak",
      battingStats: BattingStats(
        matches: 115,
        innings: 110,
        runs: 4125,
        ballsFaced: 2950,
        average: 41.25,
        strikeRate: 139.83,
        highestScore: "118",
        notOuts: 10,
        fifties: 29,
        hundreds: 4,
        fours: 410,
        sixes: 182,
      ),
      bowlingStats: BowlingStats(
        matches: 115,
        innings: 8,
        wickets: 2,
        runsConceded: 72,
        ballsBowled: 54,
        economy: 8.00,
        average: 36.00,
        strikeRate: 27.00,
        bestBowling: "1/8",
        threeWickets: 0,
        fiveWickets: 0,
      ),
      fieldingStats: FieldingStats(
        catches: 42,
        stumpings: 0,
        runOuts: 8,
      ),
    ),
    UserProfile(
      username: "hardik_pandya",
      name: "Hardik Pandya",
      avatarUrl:
          "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80",
      role: "All-Rounder",
      battingStyle: "Right-hand bat",
      bowlingStyle: "Right-arm medium-fast",
      battingStats: BattingStats(
        matches: 82,
        innings: 74,
        runs: 1640,
        ballsFaced: 1120,
        average: 27.33,
        strikeRate: 146.43,
        highestScore: "82*",
        notOuts: 14,
        fifties: 9,
        hundreds: 0,
        fours: 134,
        sixes: 78,
      ),
      bowlingStats: BowlingStats(
        matches: 82,
        innings: 70,
        wickets: 74,
        runsConceded: 1658,
        ballsBowled: 1488,
        economy: 6.69,
        average: 22.41,
        strikeRate: 20.11,
        bestBowling: "4/18",
        threeWickets: 6,
        fiveWickets: 0,
      ),
      fieldingStats: FieldingStats(
        catches: 36,
        stumpings: 0,
        runOuts: 10,
      ),
    ),
    UserProfile(
      username: "ravindra_jadeja",
      name: "Ravindra Jadeja",
      avatarUrl:
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80",
      role: "All-Rounder",
      battingStyle: "Left-hand bat",
      bowlingStyle: "Left-arm orthodox spin",
      battingStats: BattingStats(
        matches: 108,
        innings: 92,
        runs: 2150,
        ballsFaced: 1680,
        average: 30.71,
        strikeRate: 127.98,
        highestScore: "77*",
        notOuts: 22,
        fifties: 12,
        hundreds: 0,
        fours: 198,
        sixes: 58,
      ),
      bowlingStats: BowlingStats(
        matches: 108,
        innings: 105,
        wickets: 112,
        runsConceded: 2744,
        ballsBowled: 2436,
        economy: 6.76,
        average: 24.50,
        strikeRate: 21.75,
        bestBowling: "5/21",
        threeWickets: 9,
        fiveWickets: 2,
      ),
      fieldingStats: FieldingStats(
        catches: 75,
        stumpings: 0,
        runOuts: 21,
      ),
    ),
    UserProfile(
      username: "kl_rahul",
      name: "KL Rahul",
      avatarUrl:
          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80",
      role: "Wicketkeeper Batsman",
      battingStyle: "Right-hand bat",
      bowlingStyle: "None",
      battingStats: BattingStats(
        matches: 78,
        innings: 75,
        runs: 2418,
        ballsFaced: 1850,
        average: 35.56,
        strikeRate: 130.70,
        highestScore: "110*",
        notOuts: 7,
        fifties: 18,
        hundreds: 2,
        fours: 228,
        sixes: 74,
      ),
      bowlingStats: BowlingStats(
        matches: 78,
        innings: 0,
        wickets: 0,
        runsConceded: 0,
        ballsBowled: 0,
        economy: 0.0,
        average: 0.0,
        strikeRate: 0.0,
        bestBowling: "N/A",
        threeWickets: 0,
        fiveWickets: 0,
      ),
      fieldingStats: FieldingStats(
        catches: 52,
        stumpings: 12,
        runOuts: 5,
      ),
    ),
    UserProfile(
      username: "yuzvendra_chahal",
      name: "Yuzvendra Chahal",
      avatarUrl:
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80",
      role: "Bowler",
      battingStyle: "Right-hand bat",
      bowlingStyle: "Right-arm legbreak",
      battingStats: BattingStats(
        matches: 80,
        innings: 20,
        runs: 45,
        ballsFaced: 80,
        average: 4.50,
        strikeRate: 56.25,
        highestScore: "8*",
        notOuts: 10,
        fifties: 0,
        hundreds: 0,
        fours: 2,
        sixes: 0,
      ),
      bowlingStats: BowlingStats(
        matches: 80,
        innings: 78,
        wickets: 121,
        runsConceded: 2420,
        ballsBowled: 1824,
        economy: 7.96,
        average: 20.00,
        strikeRate: 15.07,
        bestBowling: "6/25",
        threeWickets: 11,
        fiveWickets: 3,
      ),
      fieldingStats: FieldingStats(
        catches: 18,
        stumpings: 0,
        runOuts: 4,
      ),
    ),
    UserProfile(
      username: "rishabh_pant",
      name: "Rishabh Pant",
      avatarUrl:
          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80",
      role: "Wicketkeeper Batsman",
      battingStyle: "Left-hand bat",
      bowlingStyle: "None",
      battingStats: BattingStats(
        matches: 66,
        innings: 64,
        runs: 1980,
        ballsFaced: 1360,
        average: 34.14,
        strikeRate: 145.59,
        highestScore: "97",
        notOuts: 6,
        fifties: 14,
        hundreds: 0,
        fours: 184,
        sixes: 92,
      ),
      bowlingStats: BowlingStats(
        matches: 66,
        innings: 0,
        wickets: 0,
        runsConceded: 0,
        ballsBowled: 0,
        economy: 0.0,
        average: 0.0,
        strikeRate: 0.0,
        bestBowling: "N/A",
        threeWickets: 0,
        fiveWickets: 0,
      ),
      fieldingStats: FieldingStats(
        catches: 48,
        stumpings: 18,
        runOuts: 7,
      ),
    )
  ];

  static final List<DayStats> mockDailyStats = [
    DayStats(
      date: "June 24, 2026",
      matchesPlayed: 3,
      topBatsmen: [
        TopBatsman(
            name: "Virat Kohli", runs: 85, balls: 48, strikeRate: 177.08),
        TopBatsman(name: "KL Rahul", runs: 64, balls: 42, strikeRate: 152.38),
        TopBatsman(
            name: "Rishabh Pant", runs: 58, balls: 30, strikeRate: 193.33),
        TopBatsman(
            name: "Rohit Sharma", runs: 42, balls: 24, strikeRate: 175.00),
        TopBatsman(
            name: "Hardik Pandya", runs: 37, balls: 16, strikeRate: 231.25),
      ],
      topBowlers: [
        TopBowler(
            name: "Jasprit Bumrah", wickets: 4, runsConceded: 14, overs: 4.0),
        TopBowler(
            name: "Yuzvendra Chahal", wickets: 3, runsConceded: 22, overs: 4.0),
        TopBowler(
            name: "Ravindra Jadeja", wickets: 2, runsConceded: 18, overs: 4.0),
        TopBowler(
            name: "Hardik Pandya", wickets: 2, runsConceded: 25, overs: 3.0),
        TopBowler(
            name: "Virat Kohli", wickets: 1, runsConceded: 12, overs: 1.0),
      ],
      topDotBowlers: [
        TopDotBallBowler(name: "Jasprit Bumrah", dotBalls: 16, overs: 4.0),
        TopDotBallBowler(name: "Ravindra Jadeja", dotBalls: 12, overs: 4.0),
        TopDotBallBowler(name: "Yuzvendra Chahal", dotBalls: 10, overs: 4.0),
        TopDotBallBowler(name: "Hardik Pandya", dotBalls: 8, overs: 3.0),
        TopDotBallBowler(name: "Virat Kohli", dotBalls: 2, overs: 1.0),
      ],
    ),
    DayStats(
      date: "June 23, 2026",
      matchesPlayed: 2,
      topBatsmen: [
        TopBatsman(
            name: "Rohit Sharma", runs: 94, balls: 52, strikeRate: 180.77),
        TopBatsman(
            name: "Hardik Pandya", runs: 70, balls: 34, strikeRate: 205.88),
        TopBatsman(
            name: "Virat Kohli", runs: 48, balls: 36, strikeRate: 133.33),
        TopBatsman(
            name: "Rishabh Pant", runs: 32, balls: 18, strikeRate: 177.78),
        TopBatsman(name: "KL Rahul", runs: 28, balls: 22, strikeRate: 127.27),
      ],
      topBowlers: [
        TopBowler(
            name: "Yuzvendra Chahal", wickets: 4, runsConceded: 18, overs: 4.0),
        TopBowler(
            name: "Jasprit Bumrah", wickets: 3, runsConceded: 11, overs: 4.0),
        TopBowler(
            name: "Ravindra Jadeja", wickets: 2, runsConceded: 26, overs: 4.0),
        TopBowler(
            name: "Hardik Pandya", wickets: 1, runsConceded: 19, overs: 4.0),
        TopBowler(
            name: "Rohit Sharma", wickets: 0, runsConceded: 10, overs: 1.0),
      ],
      topDotBowlers: [
        TopDotBallBowler(name: "Jasprit Bumrah", dotBalls: 18, overs: 4.0),
        TopDotBallBowler(name: "Yuzvendra Chahal", dotBalls: 14, overs: 4.0),
        TopDotBallBowler(name: "Ravindra Jadeja", dotBalls: 9, overs: 4.0),
        TopDotBallBowler(name: "Hardik Pandya", dotBalls: 8, overs: 4.0),
        TopDotBallBowler(name: "Rohit Sharma", dotBalls: 2, overs: 1.0),
      ],
    ),
    DayStats(
      date: "June 21, 2026",
      matchesPlayed: 3,
      topBatsmen: [
        TopBatsman(
            name: "Rishabh Pant", runs: 76, balls: 41, strikeRate: 185.37),
        TopBatsman(
            name: "Virat Kohli", runs: 59, balls: 44, strikeRate: 134.09),
        TopBatsman(name: "KL Rahul", runs: 55, balls: 38, strikeRate: 144.74),
        TopBatsman(
            name: "Ravindra Jadeja", runs: 43, balls: 22, strikeRate: 195.45),
        TopBatsman(
            name: "Rohit Sharma", runs: 30, balls: 19, strikeRate: 157.89),
      ],
      topBowlers: [
        TopBowler(
            name: "Jasprit Bumrah", wickets: 5, runsConceded: 15, overs: 4.0),
        TopBowler(
            name: "Hardik Pandya", wickets: 3, runsConceded: 21, overs: 4.0),
        TopBowler(
            name: "Yuzvendra Chahal", wickets: 2, runsConceded: 32, overs: 4.0),
        TopBowler(
            name: "Ravindra Jadeja", wickets: 1, runsConceded: 20, overs: 4.0),
        TopBowler(
            name: "Virat Kohli", wickets: 0, runsConceded: 15, overs: 1.0),
      ],
      topDotBowlers: [
        TopDotBallBowler(name: "Jasprit Bumrah", dotBalls: 17, overs: 4.0),
        TopDotBallBowler(name: "Hardik Pandya", dotBalls: 11, overs: 4.0),
        TopDotBallBowler(name: "Ravindra Jadeja", dotBalls: 10, overs: 4.0),
        TopDotBallBowler(name: "Yuzvendra Chahal", dotBalls: 7, overs: 4.0),
        TopDotBallBowler(name: "Virat Kohli", dotBalls: 1, overs: 1.0),
      ],
    ),
    DayStats(
      date: "June 20, 2026",
      matchesPlayed: 1,
      topBatsmen: [
        TopBatsman(name: "KL Rahul", runs: 82, balls: 55, strikeRate: 149.09),
        TopBatsman(
            name: "Virat Kohli", runs: 45, balls: 32, strikeRate: 140.63),
        TopBatsman(
            name: "Rohit Sharma", runs: 33, balls: 20, strikeRate: 165.00),
        TopBatsman(
            name: "Hardik Pandya", runs: 28, balls: 15, strikeRate: 186.67),
        TopBatsman(
            name: "Rishabh Pant", runs: 24, balls: 14, strikeRate: 171.43),
      ],
      topBowlers: [
        TopBowler(
            name: "Ravindra Jadeja", wickets: 3, runsConceded: 18, overs: 4.0),
        TopBowler(
            name: "Jasprit Bumrah", wickets: 2, runsConceded: 9, overs: 4.0),
        TopBowler(
            name: "Yuzvendra Chahal", wickets: 2, runsConceded: 25, overs: 4.0),
        TopBowler(
            name: "Hardik Pandya", wickets: 1, runsConceded: 22, overs: 4.0),
        TopBowler(name: "Virat Kohli", wickets: 0, runsConceded: 8, overs: 1.0),
      ],
      topDotBowlers: [
        TopDotBallBowler(name: "Jasprit Bumrah", dotBalls: 19, overs: 4.0),
        TopDotBallBowler(name: "Ravindra Jadeja", dotBalls: 12, overs: 4.0),
        TopDotBallBowler(name: "Hardik Pandya", dotBalls: 9, overs: 4.0),
        TopDotBallBowler(name: "Yuzvendra Chahal", dotBalls: 8, overs: 4.0),
        TopDotBallBowler(name: "Virat Kohli", dotBalls: 3, overs: 1.0),
      ],
    ),
    DayStats(
      date: "June 18, 2026",
      matchesPlayed: 2,
      topBatsmen: [
        TopBatsman(
            name: "Virat Kohli", runs: 104, balls: 60, strikeRate: 173.33),
        TopBatsman(
            name: "Rohit Sharma", runs: 58, balls: 36, strikeRate: 161.11),
        TopBatsman(name: "KL Rahul", runs: 44, balls: 32, strikeRate: 137.50),
        TopBatsman(
            name: "Rishabh Pant", runs: 39, balls: 21, strikeRate: 185.71),
        TopBatsman(
            name: "Hardik Pandya", runs: 30, balls: 14, strikeRate: 214.29),
      ],
      topBowlers: [
        TopBowler(
            name: "Jasprit Bumrah", wickets: 4, runsConceded: 16, overs: 4.0),
        TopBowler(
            name: "Yuzvendra Chahal", wickets: 3, runsConceded: 30, overs: 4.0),
        TopBowler(
            name: "Ravindra Jadeja", wickets: 2, runsConceded: 21, overs: 4.0),
        TopBowler(
            name: "Hardik Pandya", wickets: 1, runsConceded: 26, overs: 4.0),
        TopBowler(
            name: "Virat Kohli", wickets: 0, runsConceded: 14, overs: 1.0),
      ],
      topDotBowlers: [
        TopDotBallBowler(name: "Jasprit Bumrah", dotBalls: 15, overs: 4.0),
        TopDotBallBowler(name: "Ravindra Jadeja", dotBalls: 11, overs: 4.0),
        TopDotBallBowler(name: "Yuzvendra Chahal", dotBalls: 8, overs: 4.0),
        TopDotBallBowler(name: "Hardik Pandya", dotBalls: 6, overs: 4.0),
        TopDotBallBowler(name: "Virat Kohli", dotBalls: 2, overs: 1.0),
      ],
    ),
    DayStats(
      date: "June 17, 2026",
      matchesPlayed: 4,
      topBatsmen: [
        TopBatsman(
            name: "Hardik Pandya", runs: 88, balls: 40, strikeRate: 220.00),
        TopBatsman(
            name: "Virat Kohli", runs: 74, balls: 50, strikeRate: 148.00),
        TopBatsman(
            name: "Rohit Sharma", runs: 61, balls: 35, strikeRate: 174.29),
        TopBatsman(
            name: "Rishabh Pant", runs: 49, balls: 28, strikeRate: 175.00),
        TopBatsman(name: "KL Rahul", runs: 41, balls: 31, strikeRate: 132.26),
      ],
      topBowlers: [
        TopBowler(
            name: "Yuzvendra Chahal", wickets: 5, runsConceded: 24, overs: 4.0),
        TopBowler(
            name: "Jasprit Bumrah", wickets: 3, runsConceded: 18, overs: 4.0),
        TopBowler(
            name: "Ravindra Jadeja", wickets: 2, runsConceded: 22, overs: 4.0),
        TopBowler(
            name: "Hardik Pandya", wickets: 2, runsConceded: 30, overs: 4.0),
        TopBowler(
            name: "Virat Kohli", wickets: 0, runsConceded: 11, overs: 1.0),
      ],
      topDotBowlers: [
        TopDotBallBowler(name: "Yuzvendra Chahal", dotBalls: 15, overs: 4.0),
        TopDotBallBowler(name: "Jasprit Bumrah", dotBalls: 14, overs: 4.0),
        TopDotBallBowler(name: "Ravindra Jadeja", dotBalls: 11, overs: 4.0),
        TopDotBallBowler(name: "Hardik Pandya", dotBalls: 9, overs: 4.0),
        TopDotBallBowler(name: "Virat Kohli", dotBalls: 3, overs: 1.0),
      ],
    ),
    DayStats(
      date: "June 16, 2026",
      matchesPlayed: 2,
      topBatsmen: [
        TopBatsman(name: "KL Rahul", runs: 71, balls: 45, strikeRate: 157.78),
        TopBatsman(
            name: "Rohit Sharma", runs: 65, balls: 38, strikeRate: 171.05),
        TopBatsman(
            name: "Rishabh Pant", runs: 43, balls: 24, strikeRate: 179.17),
        TopBatsman(
            name: "Virat Kohli", runs: 37, balls: 28, strikeRate: 132.14),
        TopBatsman(
            name: "Ravindra Jadeja", runs: 29, balls: 15, strikeRate: 193.33),
      ],
      topBowlers: [
        TopBowler(
            name: "Jasprit Bumrah", wickets: 4, runsConceded: 10, overs: 4.0),
        TopBowler(
            name: "Ravindra Jadeja", wickets: 3, runsConceded: 15, overs: 4.0),
        TopBowler(
            name: "Yuzvendra Chahal", wickets: 2, runsConceded: 28, overs: 4.0),
        TopBowler(
            name: "Hardik Pandya", wickets: 1, runsConceded: 24, overs: 3.0),
        TopBowler(name: "Virat Kohli", wickets: 0, runsConceded: 7, overs: 1.0),
      ],
      topDotBowlers: [
        TopDotBallBowler(name: "Jasprit Bumrah", dotBalls: 18, overs: 4.0),
        TopDotBallBowler(name: "Ravindra Jadeja", dotBalls: 14, overs: 4.0),
        TopDotBallBowler(name: "Hardik Pandya", dotBalls: 8, overs: 3.0),
        TopDotBallBowler(name: "Yuzvendra Chahal", dotBalls: 7, overs: 4.0),
        TopDotBallBowler(name: "Virat Kohli", dotBalls: 2, overs: 1.0),
      ],
    ),
    DayStats(
      date: "June 15, 2026",
      matchesPlayed: 1,
      topBatsmen: [
        TopBatsman(
            name: "Virat Kohli", runs: 90, balls: 55, strikeRate: 163.64),
        TopBatsman(
            name: "Rohit Sharma", runs: 45, balls: 28, strikeRate: 160.71),
        TopBatsman(
            name: "Hardik Pandya", runs: 38, balls: 20, strikeRate: 190.00),
        TopBatsman(
            name: "Rishabh Pant", runs: 31, balls: 18, strikeRate: 172.22),
        TopBatsman(name: "KL Rahul", runs: 24, balls: 19, strikeRate: 126.32),
      ],
      topBowlers: [
        TopBowler(
            name: "Hardik Pandya", wickets: 4, runsConceded: 18, overs: 4.0),
        TopBowler(
            name: "Jasprit Bumrah", wickets: 3, runsConceded: 12, overs: 4.0),
        TopBowler(
            name: "Yuzvendra Chahal", wickets: 1, runsConceded: 22, overs: 4.0),
        TopBowler(
            name: "Ravindra Jadeja", wickets: 1, runsConceded: 24, overs: 4.0),
        TopBowler(name: "Virat Kohli", wickets: 0, runsConceded: 9, overs: 1.0),
      ],
      topDotBowlers: [
        TopDotBallBowler(name: "Jasprit Bumrah", dotBalls: 17, overs: 4.0),
        TopDotBallBowler(name: "Hardik Pandya", dotBalls: 13, overs: 4.0),
        TopDotBallBowler(name: "Ravindra Jadeja", dotBalls: 10, overs: 4.0),
        TopDotBallBowler(name: "Yuzvendra Chahal", dotBalls: 9, overs: 4.0),
        TopDotBallBowler(name: "Virat Kohli", dotBalls: 2, overs: 1.0),
      ],
    ),
    DayStats(
      date: "June 14, 2026",
      matchesPlayed: 3,
      topBatsmen: [
        TopBatsman(
            name: "Rohit Sharma", runs: 82, balls: 46, strikeRate: 178.26),
        TopBatsman(
            name: "Rishabh Pant", runs: 69, balls: 38, strikeRate: 181.58),
        TopBatsman(
            name: "Virat Kohli", runs: 51, balls: 39, strikeRate: 130.77),
        TopBatsman(name: "KL Rahul", runs: 46, balls: 35, strikeRate: 131.43),
        TopBatsman(
            name: "Hardik Pandya", runs: 22, balls: 11, strikeRate: 200.00),
      ],
      topBowlers: [
        TopBowler(
            name: "Jasprit Bumrah", wickets: 4, runsConceded: 15, overs: 4.0),
        TopBowler(
            name: "Ravindra Jadeja", wickets: 3, runsConceded: 20, overs: 4.0),
        TopBowler(
            name: "Yuzvendra Chahal", wickets: 2, runsConceded: 25, overs: 4.0),
        TopBowler(
            name: "Hardik Pandya", wickets: 1, runsConceded: 18, overs: 3.0),
        TopBowler(
            name: "Virat Kohli", wickets: 0, runsConceded: 10, overs: 1.0),
      ],
      topDotBowlers: [
        TopDotBallBowler(name: "Jasprit Bumrah", dotBalls: 16, overs: 4.0),
        TopDotBallBowler(name: "Ravindra Jadeja", dotBalls: 12, overs: 4.0),
        TopDotBallBowler(name: "Yuzvendra Chahal", dotBalls: 10, overs: 4.0),
        TopDotBallBowler(name: "Hardik Pandya", dotBalls: 8, overs: 3.0),
        TopDotBallBowler(name: "Virat Kohli", dotBalls: 2, overs: 1.0),
      ],
    ),
    DayStats(
      date: "June 12, 2026",
      matchesPlayed: 2,
      topBatsmen: [
        TopBatsman(
            name: "Virat Kohli", runs: 77, balls: 48, strikeRate: 160.42),
        TopBatsman(name: "KL Rahul", runs: 69, balls: 44, strikeRate: 156.82),
        TopBatsman(
            name: "Rishabh Pant", runs: 40, balls: 22, strikeRate: 181.82),
        TopBatsman(
            name: "Rohit Sharma", runs: 36, balls: 21, strikeRate: 171.43),
        TopBatsman(
            name: "Hardik Pandya", runs: 34, balls: 17, strikeRate: 200.00),
      ],
      topBowlers: [
        TopBowler(
            name: "Yuzvendra Chahal", wickets: 4, runsConceded: 20, overs: 4.0),
        TopBowler(
            name: "Jasprit Bumrah", wickets: 3, runsConceded: 14, overs: 4.0),
        TopBowler(
            name: "Ravindra Jadeja", wickets: 2, runsConceded: 16, overs: 4.0),
        TopBowler(
            name: "Hardik Pandya", wickets: 1, runsConceded: 22, overs: 3.0),
        TopBowler(name: "Virat Kohli", wickets: 0, runsConceded: 6, overs: 1.0),
      ],
      topDotBowlers: [
        TopDotBallBowler(name: "Jasprit Bumrah", dotBalls: 18, overs: 4.0),
        TopDotBallBowler(name: "Ravindra Jadeja", dotBalls: 13, overs: 4.0),
        TopDotBallBowler(name: "Yuzvendra Chahal", dotBalls: 11, overs: 4.0),
        TopDotBallBowler(name: "Hardik Pandya", dotBalls: 7, overs: 3.0),
        TopDotBallBowler(name: "Virat Kohli", dotBalls: 3, overs: 1.0),
      ],
    ),
  ];
}

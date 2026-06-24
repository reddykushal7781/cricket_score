class CricketMatch {
  final int? id;
  final String teamAName;
  final String teamBName;
  final int oversCount;
  final int playersPerTeam;
  final int teamAScore;
  final int teamBScore;
  final int teamAWickets;
  final int teamBWickets;
  final int teamABalls;
  final int teamBBalls;
  final String? winner;
  final bool isCompleted;
  final String date;

  CricketMatch({
    this.id,
    required this.teamAName,
    required this.teamBName,
    required this.oversCount,
    required this.playersPerTeam,
    this.teamAScore = 0,
    this.teamBScore = 0,
    this.teamAWickets = 0,
    this.teamBWickets = 0,
    this.teamABalls = 0,
    this.teamBBalls = 0,
    this.winner,
    this.isCompleted = false,
    required this.date,
  });

  CricketMatch copyWith({
    int? id,
    String? teamAName,
    String? teamBName,
    int? oversCount,
    int? playersPerTeam,
    int? teamAScore,
    int? teamBScore,
    int? teamAWickets,
    int? teamBWickets,
    int? teamABalls,
    int? teamBBalls,
    String? winner,
    bool? isCompleted,
    String? date,
  }) {
    return CricketMatch(
      id: id ?? this.id,
      teamAName: teamAName ?? this.teamAName,
      teamBName: teamBName ?? this.teamBName,
      oversCount: oversCount ?? this.oversCount,
      playersPerTeam: playersPerTeam ?? this.playersPerTeam,
      teamAScore: teamAScore ?? this.teamAScore,
      teamBScore: teamBScore ?? this.teamBScore,
      teamAWickets: teamAWickets ?? this.teamAWickets,
      teamBWickets: teamBWickets ?? this.teamBWickets,
      teamABalls: teamABalls ?? this.teamABalls,
      teamBBalls: teamBBalls ?? this.teamBBalls,
      winner: winner ?? this.winner,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'team_a_name': teamAName,
      'team_b_name': teamBName,
      'overs_count': oversCount,
      'players_per_team': playersPerTeam,
      'team_a_score': teamAScore,
      'team_b_score': teamBScore,
      'team_a_wickets': teamAWickets,
      'team_b_wickets': teamBWickets,
      'team_a_balls': teamABalls,
      'team_b_balls': teamBBalls,
      'winner': winner,
      'is_completed': isCompleted ? 1 : 0,
      'date': date,
    };
  }

  factory CricketMatch.fromMap(Map<String, dynamic> map) {
    return CricketMatch(
      id: map['id'] as int?,
      teamAName: map['team_a_name'] as String,
      teamBName: map['team_b_name'] as String,
      oversCount: map['overs_count'] as int,
      playersPerTeam: map['players_per_team'] as int,
      teamAScore: map['team_a_score'] as int? ?? 0,
      teamBScore: map['team_b_score'] as int? ?? 0,
      teamAWickets: map['team_a_wickets'] as int? ?? 0,
      teamBWickets: map['team_b_wickets'] as int? ?? 0,
      teamABalls: map['team_a_balls'] as int? ?? 0,
      teamBBalls: map['team_b_balls'] as int? ?? 0,
      winner: map['winner'] as String?,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      date: map['date'] as String,
    );
  }
}

class BallEvent {
  final int? id;
  final int matchId;
  final int inningsIndex; // 0 for Team A, 1 for Team B
  final int ballIndex; // Total ball index in innings
  final int overNumber; // 0-indexed over
  final int ballNumber; // 1-indexed ball in current over
  final int batsmanId;
  final String batsmanName;
  final int bowlerId;
  final String bowlerName;
  final int runs; // Runs scored from the bat
  final bool isWicket;
  final String? wicketType; // 'bowled', 'caught', 'lbw', 'run out', etc.
  final int? dismissedPlayerId;
  final int? fielderId; // Player ID of the catcher/runout fielder
  final String? fielderName;
  final int extraRuns; // Extra runs awarded
  final String extraType; // 'wide', 'noball', 'bye', 'legbye', 'none'

  BallEvent({
    this.id,
    required this.matchId,
    required this.inningsIndex,
    required this.ballIndex,
    required this.overNumber,
    required this.ballNumber,
    required this.batsmanId,
    required this.batsmanName,
    required this.bowlerId,
    required this.bowlerName,
    required this.runs,
    required this.isWicket,
    this.wicketType,
    this.dismissedPlayerId,
    this.fielderId,
    this.fielderName,
    this.extraRuns = 0,
    this.extraType = 'none',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'match_id': matchId,
      'innings_index': inningsIndex,
      'ball_index': ballIndex,
      'over_number': overNumber,
      'ball_number': ballNumber,
      'batsman_id': batsmanId,
      'batsman_name': batsmanName,
      'bowler_id': bowlerId,
      'bowler_name': bowlerName,
      'runs': runs,
      'is_wicket': isWicket ? 1 : 0,
      'wicket_type': wicketType,
      'dismissed_player_id': dismissedPlayerId,
      'fielder_id': fielderId,
      'fielder_name': fielderName,
      'extra_runs': extraRuns,
      'extra_type': extraType,
    };
  }

  factory BallEvent.fromMap(Map<String, dynamic> map) {
    return BallEvent(
      id: map['id'] as int?,
      matchId: map['match_id'] as int,
      inningsIndex: map['innings_index'] as int,
      ballIndex: map['ball_index'] as int,
      overNumber: map['over_number'] as int,
      ballNumber: map['ball_number'] as int,
      batsmanId: map['batsman_id'] as int,
      batsmanName: map['batsman_name'] as String? ?? 'Unknown',
      bowlerId: map['bowler_id'] as int,
      bowlerName: map['bowler_name'] as String? ?? 'Unknown',
      runs: map['runs'] as int,
      isWicket: (map['is_wicket'] as int? ?? 0) == 1,
      wicketType: map['wicket_type'] as String?,
      dismissedPlayerId: map['dismissed_player_id'] as int?,
      fielderId: map['fielder_id'] as int?,
      fielderName: map['fielder_name'] as String?,
      extraRuns: map['extra_runs'] as int? ?? 0,
      extraType: map['extra_type'] as String? ?? 'none',
    );
  }
}

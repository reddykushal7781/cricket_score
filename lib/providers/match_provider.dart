import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/match.dart';
import '../services/database_helper.dart';

class BattingScorecard {
  final int playerId;
  final String name;
  int runs = 0;
  int ballsFaced = 0;
  int fours = 0;
  int sixes = 0;
  bool isOut = false;
  String dismissalType = '';
  String dismissedBy = '';

  BattingScorecard({required this.playerId, required this.name});
}

class BowlingScorecard {
  final int playerId;
  final String name;
  int ballsBowled = 0;
  int runsConceded = 0;
  int wickets = 0;
  int maidens = 0;

  BowlingScorecard({required this.playerId, required this.name});

  double get economy {
    if (ballsBowled == 0) return 0.0;
    return (runsConceded / (ballsBowled / 6.0));
  }
}

class MatchProvider extends ChangeNotifier {
  int? _activeMatchId;
  CricketMatch? _currentMatch;
  List<Player> _teamAPlayers = [];
  List<Player> _teamBPlayers = [];
  
  int _inningsIndex = 0; // 0 for Team A batting, 1 for Team B batting
  int _totalScore = 0;
  int _wickets = 0;
  int _ballsBowled = 0; // Legal balls in current innings
  int _extraRuns = 0;
  int _firstInningsScore = 0;
  
  Map<String, int> _extrasDetails = {
    'wide': 0,
    'noball': 0,
    'bye': 0,
    'legbye': 0,
  };

  List<BallEvent> _ballEvents = [];
  
  Player? _striker;
  Player? _nonStriker;
  Player? _currentBowler;

  Map<int, BattingScorecard> _batsmenScorecards = {};
  Map<int, BowlingScorecard> _bowlerScorecards = {};
  List<int> _dismissedPlayerIds = [];
  List<Player> _yetToBatPlayers = [];

  // Getters
  int? get activeMatchId => _activeMatchId;
  CricketMatch? get currentMatch => _currentMatch;
  List<Player> get teamAPlayers => _teamAPlayers;
  List<Player> get teamBPlayers => _teamBPlayers;
  int get inningsIndex => _inningsIndex;
  int get totalScore => _totalScore;
  int get wickets => _wickets;
  int get ballsBowled => _ballsBowled;
  int get extraRuns => _extraRuns;
  int get firstInningsScore => _firstInningsScore;
  Map<String, int> get extrasDetails => _extrasDetails;
  List<BallEvent> get ballEvents => _ballEvents;
  Player? get striker => _striker;
  Player? get nonStriker => _nonStriker;
  Player? get currentBowler => _currentBowler;
  List<int> get dismissedPlayerIds => _dismissedPlayerIds;
  List<Player> get yetToBatPlayers => _yetToBatPlayers;
  Map<int, BattingScorecard> get batsmenScorecards => _batsmenScorecards;
  Map<int, BowlingScorecard> get bowlerScorecards => _bowlerScorecards;

  bool get isMatchOver {
    if (_currentMatch == null) return false;
    return _currentMatch!.isCompleted;
  }

  String get overString {
    int overs = _ballsBowled ~/ 6;
    int balls = _ballsBowled % 6;
    return '$overs.$balls';
  }

  double get runRate {
    if (_ballsBowled == 0) return 0.0;
    return (_totalScore / (_ballsBowled / 6.0));
  }

  double get requiredRunRate {
    if (_currentMatch == null || _inningsIndex == 0) return 0.0;
    int remainingBalls = (_currentMatch!.oversCount * 6) - _ballsBowled;
    if (remainingBalls <= 0) return 0.0;
    int runsNeeded = (_firstInningsScore + 1) - _totalScore;
    if (runsNeeded <= 0) return 0.0;
    return (runsNeeded / (remainingBalls / 6.0));
  }

  int get targetScore {
    if (_inningsIndex == 0) return 0;
    return _firstInningsScore + 1;
  }

  List<Player> get battingTeamList {
    return _inningsIndex == 0 ? _teamAPlayers : _teamBPlayers;
  }

  List<Player> get bowlingTeamList {
    return _inningsIndex == 0 ? _teamBPlayers : _teamAPlayers;
  }

  // --- Match Setup Actions ---
  Future<void> startMatch({
    required CricketMatch match,
    required List<Player> teamA,
    required List<Player> teamB,
  }) async {
    int matchId = 1;
    try {
      matchId = await DatabaseHelper.instance.createMatch(match, teamA, teamB);
    } catch (e) {
      debugPrint('SQLite Error (startMatch): $e. Using local simulation id.');
    }
    _activeMatchId = matchId;
    _currentMatch = match.copyWith(id: matchId);
    _teamAPlayers = teamA;
    _teamBPlayers = teamB;
    
    _resetLiveState();
    notifyListeners();
  }

  Future<bool> tryResumeActiveMatch() async {
    try {
      final activeMatch = await DatabaseHelper.instance.getActiveMatch();
      if (activeMatch == null) return false;

      final teamA = await DatabaseHelper.instance.getMatchPlayers(activeMatch.id!, 0);
      final teamB = await DatabaseHelper.instance.getMatchPlayers(activeMatch.id!, 1);
      final events = await DatabaseHelper.instance.getBallEventsForMatch(activeMatch.id!);

      _activeMatchId = activeMatch.id;
      _currentMatch = activeMatch;
      _teamAPlayers = teamA;
      _teamBPlayers = teamB;

      _resetLiveState();
      
      for (var event in events) {
        _applyBallEventInMemory(event);
      }

      _ballEvents = events;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('SQLite Error (tryResumeActiveMatch): $e');
      return false;
    }
  }

  void _resetLiveState() {
    _inningsIndex = 0;
    _totalScore = 0;
    _wickets = 0;
    _ballsBowled = 0;
    _extraRuns = 0;
    _firstInningsScore = 0;
    _extrasDetails = {'wide': 0, 'noball': 0, 'bye': 0, 'legbye': 0};
    _ballEvents = [];
    _striker = null;
    _nonStriker = null;
    _currentBowler = null;
    _batsmenScorecards = {};
    _bowlerScorecards = {};
    _dismissedPlayerIds = [];
    _yetToBatPlayers = List.from(battingTeamList);
  }

  // --- Selectors ---
  void selectStriker(Player player) {
    _striker = player;
    _yetToBatPlayers.removeWhere((p) => p.id == player.id);
    if (!_batsmenScorecards.containsKey(player.id)) {
      _batsmenScorecards[player.id!] = BattingScorecard(playerId: player.id!, name: player.name);
    }
    notifyListeners();
  }

  void selectNonStriker(Player player) {
    _nonStriker = player;
    _yetToBatPlayers.removeWhere((p) => p.id == player.id);
    if (!_batsmenScorecards.containsKey(player.id)) {
      _batsmenScorecards[player.id!] = BattingScorecard(playerId: player.id!, name: player.name);
    }
    notifyListeners();
  }

  void selectBowler(Player player) {
    _currentBowler = player;
    if (!_bowlerScorecards.containsKey(player.id)) {
      _bowlerScorecards[player.id!] = BowlingScorecard(playerId: player.id!, name: player.name);
    }
    notifyListeners();
  }

  // --- Scoring Input ---
  Future<void> recordBall({
    required int runs,
    required String extraType, // 'none', 'wide', 'noball', 'bye', 'legbye'
    required bool isWicket,
    String? wicketType, // 'bowled', 'caught', 'lbw', 'run out', 'stumped', etc.
    int? dismissedPlayerId,
    int? fielderId,
    String? fielderName,
  }) async {
    if (_currentMatch == null || _striker == null || _currentBowler == null) return;

    int extraVal = 0;
    if (extraType == 'wide' || extraType == 'noball') {
      extraVal = 1;
    }

    final newEvent = BallEvent(
      matchId: _currentMatch!.id!,
      inningsIndex: _inningsIndex,
      ballIndex: _ballEvents.length,
      overNumber: _ballsBowled ~/ 6,
      ballNumber: (_ballsBowled % 6) + 1,
      batsmanId: _striker!.id!,
      batsmanName: _striker!.name,
      bowlerId: _currentBowler!.id!,
      bowlerName: _currentBowler!.name,
      runs: runs,
      isWicket: isWicket,
      wicketType: wicketType,
      dismissedPlayerId: dismissedPlayerId ?? (isWicket && wicketType != 'run out' ? _striker!.id : null),
      fielderId: fielderId,
      fielderName: fielderName,
      extraRuns: extraVal,
      extraType: extraType,
    );

    // Save to database
    try {
      await DatabaseHelper.instance.insertBallEvent(newEvent);
    } catch (e) {
      debugPrint('SQLite Error (insertBallEvent): $e');
    }
    _ballEvents.add(newEvent);

    // Apply event
    _applyBallEventInMemory(newEvent);

    // Update active score in DB
    int currentTeamAScore = _inningsIndex == 0 ? _totalScore : _firstInningsScore;
    int currentTeamBScore = _inningsIndex == 1 ? _totalScore : 0;
    int currentTeamAWickets = _inningsIndex == 0 ? _wickets : _currentMatch!.teamAWickets;
    int currentTeamBWickets = _inningsIndex == 1 ? _wickets : 0;
    int currentTeamABalls = _inningsIndex == 0 ? _ballsBowled : _currentMatch!.teamABalls;
    int currentTeamBBalls = _inningsIndex == 1 ? _ballsBowled : 0;

    try {
      await DatabaseHelper.instance.updateMatchScore(
        _currentMatch!.id!,
        teamAScore: currentTeamAScore,
        teamBScore: currentTeamBScore,
        teamAWickets: currentTeamAWickets,
        teamBWickets: currentTeamBWickets,
        teamABalls: currentTeamABalls,
        teamBBalls: currentTeamBBalls,
      );
    } catch (e) {
      debugPrint('SQLite Error (updateMatchScore): $e');
    }

    // Check for Innings Rollover or Match Completion
    bool inningsEnded = false;
    bool matchCompleted = false;

    int maxBalls = _currentMatch!.oversCount * 6;
    int totalBatsmen = _currentMatch!.playersPerTeam;

    if (_wickets >= totalBatsmen - 1 || _ballsBowled >= maxBalls) {
      inningsEnded = true;
    }

    // Special condition: In the second innings, if Team B has scored more than target
    if (_inningsIndex == 1 && _totalScore >= targetScore) {
      inningsEnded = true;
      matchCompleted = true;
    }

    if (inningsEnded) {
      if (_inningsIndex == 0) {
        // Roll over to second innings
        _firstInningsScore = _totalScore;
        _currentMatch = _currentMatch!.copyWith(
          teamAScore: _totalScore,
          teamAWickets: _wickets,
          teamABalls: _ballsBowled,
        );
        
        // Save current match state in DB
        try {
          await DatabaseHelper.instance.updateMatchScore(
            _currentMatch!.id!,
            teamAScore: _firstInningsScore,
            teamBScore: 0,
            teamAWickets: _wickets,
            teamBWickets: 0,
            teamABalls: _ballsBowled,
            teamBBalls: 0,
          );
        } catch (e) {
          debugPrint('SQLite Error (updateMatchScore Innings 1): $e');
        }

        // Transition settings
        _inningsIndex = 1;
        _totalScore = 0;
        _wickets = 0;
        _ballsBowled = 0;
        _extraRuns = 0;
        _extrasDetails = {'wide': 0, 'noball': 0, 'bye': 0, 'legbye': 0};
        _striker = null;
        _nonStriker = null;
        _currentBowler = null;
        _batsmenScorecards = {};
        _bowlerScorecards = {};
        _dismissedPlayerIds = [];
        _yetToBatPlayers = List.from(battingTeamList);
      } else {
        // Second innings ends -> Match completed
        matchCompleted = true;
      }
    }

    if (matchCompleted) {
      String winnerStr;
      if (_firstInningsScore > _totalScore) {
        winnerStr = _currentMatch!.teamAName;
      } else if (_totalScore > _firstInningsScore) {
        winnerStr = _currentMatch!.teamBName;
      } else {
        winnerStr = 'Tie';
      }

      _currentMatch = _currentMatch!.copyWith(
        teamBScore: _totalScore,
        teamBWickets: _wickets,
        teamBBalls: _ballsBowled,
        winner: winnerStr,
        isCompleted: true,
      );

      try {
        await DatabaseHelper.instance.updateMatchScore(
          _currentMatch!.id!,
          teamAScore: _firstInningsScore,
          teamBScore: _totalScore,
          teamAWickets: _currentMatch!.teamAWickets,
          teamBWickets: _wickets,
          teamABalls: _currentMatch!.teamABalls,
          teamBBalls: _ballsBowled,
        );

        await DatabaseHelper.instance.completeMatch(_currentMatch!.id!, winnerStr);

        // Compile and Save Career Stats
        await _saveCareerStatsToDB();
      } catch (e) {
        debugPrint('SQLite Error (completeMatch/saveCareerStats): $e');
      }
    }

    notifyListeners();
  }

  void _applyBallEventInMemory(BallEvent event) {
    bool isLegal = (event.extraType != 'wide' && event.extraType != 'noball');

    // 1. Team scores updates
    int ballTotalRuns = event.runs;
    if (event.extraType == 'wide' || event.extraType == 'noball') {
      ballTotalRuns += 1; // Penalty run
      _extraRuns += 1;
      _extrasDetails[event.extraType] = (_extrasDetails[event.extraType] ?? 0) + 1;
    } else if (event.extraType == 'bye' || event.extraType == 'legbye') {
      _extraRuns += event.runs;
      _extrasDetails[event.extraType] = (_extrasDetails[event.extraType] ?? 0) + event.runs;
    }
    
    _totalScore += ballTotalRuns;

    if (isLegal) {
      _ballsBowled += 1;
    }

    // 2. Scorecard updates
    if (!_batsmenScorecards.containsKey(event.batsmanId)) {
      _batsmenScorecards[event.batsmanId] = BattingScorecard(playerId: event.batsmanId, name: event.batsmanName);
    }
    final batCard = _batsmenScorecards[event.batsmanId]!;

    if (!_bowlerScorecards.containsKey(event.bowlerId)) {
      _bowlerScorecards[event.bowlerId] = BowlingScorecard(playerId: event.bowlerId, name: event.bowlerName);
    }
    final bowlCard = _bowlerScorecards[event.bowlerId]!;

    // Batsman stats
    if (event.extraType != 'wide') {
      batCard.ballsFaced += 1;
    }
    if (event.extraType == 'none' || event.extraType == 'noball') {
      batCard.runs += event.runs;
      if (event.runs == 4) batCard.fours += 1;
      if (event.runs == 6) batCard.sixes += 1;
    }

    // Bowler stats
    if (isLegal) {
      bowlCard.ballsBowled += 1;
    }
    
    int bowlerConceded = event.runs;
    if (event.extraType == 'wide' || event.extraType == 'noball') {
      bowlerConceded += 1;
    }
    if (event.extraType != 'bye' && event.extraType != 'legbye') {
      bowlCard.runsConceded += bowlerConceded;
    }

    // 3. Wicket logic
    if (event.isWicket) {
      _wickets += 1;
      final targetDismissedId = event.dismissedPlayerId ?? event.batsmanId;
      _dismissedPlayerIds.add(targetDismissedId);

      if (_batsmenScorecards.containsKey(targetDismissedId)) {
        _batsmenScorecards[targetDismissedId]!.isOut = true;
        _batsmenScorecards[targetDismissedId]!.dismissalType = event.wicketType ?? 'out';
        _batsmenScorecards[targetDismissedId]!.dismissedBy = event.bowlerName;
      }

      if (event.wicketType != 'run out') {
        bowlCard.wickets += 1;
      }

      if (targetDismissedId == _striker?.id) {
        _striker = null;
      } else if (targetDismissedId == _nonStriker?.id) {
        _nonStriker = null;
      }
    }

    // 4. Strike Rotation
    int runsForStrikeRotation = event.runs;
    if (event.extraType == 'wide' || event.extraType == 'noball') {
      runsForStrikeRotation = event.runs;
    }
    if (runsForStrikeRotation % 2 == 1 && !event.isWicket) {
      _rotateStrike();
    }

    // 5. Over Completion Rotate Strike
    if (isLegal && _ballsBowled % 6 == 0 && _ballsBowled > 0) {
      _rotateStrike();
      _currentBowler = null;
    }
  }

  void _rotateStrike() {
    final temp = _striker;
    _striker = _nonStriker;
    _nonStriker = temp;
  }

  void swapStrikerAndNonStriker() {
    _rotateStrike();
    notifyListeners();
  }

  // --- Undo last action ---
  Future<void> undoLastBall() async {
    if (_currentMatch == null || _ballEvents.isEmpty) return;

    // Delete from database
    try {
      await DatabaseHelper.instance.deleteLastBallEvent(_currentMatch!.id!);
    } catch (e) {
      debugPrint('SQLite Error (deleteLastBallEvent): $e');
    }
    _ballEvents.removeLast();

    // Rebuild complete state from scratch
    _rebuildMatchState();

    // Save current match state in DB
    int currentTeamAScore = _inningsIndex == 0 ? _totalScore : _firstInningsScore;
    int currentTeamBScore = _inningsIndex == 1 ? _totalScore : 0;
    int currentTeamAWickets = _inningsIndex == 0 ? _wickets : _currentMatch!.teamAWickets;
    int currentTeamBWickets = _inningsIndex == 1 ? _wickets : 0;
    int currentTeamABalls = _inningsIndex == 0 ? _ballsBowled : _currentMatch!.teamABalls;
    int currentTeamBBalls = _inningsIndex == 1 ? _ballsBowled : 0;

    try {
      await DatabaseHelper.instance.updateMatchScore(
        _currentMatch!.id!,
        teamAScore: currentTeamAScore,
        teamBScore: currentTeamBScore,
        teamAWickets: currentTeamAWickets,
        teamBWickets: currentTeamBWickets,
        teamABalls: currentTeamABalls,
        teamBBalls: currentTeamBBalls,
      );
    } catch (e) {
      debugPrint('SQLite Error (updateMatchScore during undo): $e');
    }

    notifyListeners();
  }

  void _rebuildMatchState() {
    final matchId = _activeMatchId;
    final match = _currentMatch;
    final teamA = _teamAPlayers;
    final teamB = _teamBPlayers;
    final savedEvents = List<BallEvent>.from(_ballEvents);

    _resetLiveState();
    
    _activeMatchId = matchId;
    _currentMatch = match;
    _teamAPlayers = teamA;
    _teamBPlayers = teamB;
    _yetToBatPlayers = List.from(battingTeamList);

    for (var event in savedEvents) {
      if (event.inningsIndex != _inningsIndex) {
        _firstInningsScore = _totalScore;
        _inningsIndex = 1;
        _totalScore = 0;
        _wickets = 0;
        _ballsBowled = 0;
        _extraRuns = 0;
        _extrasDetails = {'wide': 0, 'noball': 0, 'bye': 0, 'legbye': 0};
        _striker = null;
        _nonStriker = null;
        _currentBowler = null;
        _batsmenScorecards = {};
        _bowlerScorecards = {};
        _dismissedPlayerIds = [];
        _yetToBatPlayers = List.from(battingTeamList);
      }

      if (_striker == null || _striker!.id != event.batsmanId) {
        final matchingPlayer = battingTeamList.firstWhere((p) => p.id == event.batsmanId, 
          orElse: () => Player(id: event.batsmanId, name: event.batsmanName)
        );
        _striker = matchingPlayer;
        _yetToBatPlayers.removeWhere((p) => p.id == matchingPlayer.id);
      }

      if (_currentBowler == null || _currentBowler!.id != event.bowlerId) {
        final matchingBowler = bowlingTeamList.firstWhere((p) => p.id == event.bowlerId,
          orElse: () => Player(id: event.bowlerId, name: event.bowlerName)
        );
        _currentBowler = matchingBowler;
      }

      _applyBallEventInMemory(event);
    }

    _ballEvents = savedEvents;
  }

  // --- Career stats compilation ---
  Future<void> _saveCareerStatsToDB() async {
    final List<Player> updatedPlayers = [];
    final allMatchPlayers = [..._teamAPlayers, ..._teamBPlayers];
    final Set<int> processedPlayerIds = {};

    for (var matchPlayer in allMatchPlayers) {
      if (matchPlayer.id == null) continue;
      if (processedPlayerIds.contains(matchPlayer.id)) continue;
      processedPlayerIds.add(matchPlayer.id!);

      Player freshPlayer;
      try {
        freshPlayer = await DatabaseHelper.instance.getOrCreatePlayer(matchPlayer.name);
      } catch (e) {
        freshPlayer = matchPlayer;
      }

      int runsInMatch = 0;
      int ballsFacedInMatch = 0;
      int ballsBowledInMatch = 0;
      int runsConcededInMatch = 0;
      int wicketsInMatch = 0;
      int catchesInMatch = 0;

      for (var event in _ballEvents) {
        // Batting stats
        if (event.batsmanId == freshPlayer.id) {
          if (event.extraType != 'wide') {
            ballsFacedInMatch++;
          }
          if (event.extraType == 'none' || event.extraType == 'noball') {
            runsInMatch += event.runs;
          }
        }

        // Bowling stats
        if (event.bowlerId == freshPlayer.id) {
          bool isLegal = (event.extraType != 'wide' && event.extraType != 'noball');
          if (isLegal) {
            ballsBowledInMatch++;
          }

          int bowlerConceded = event.runs;
          if (event.extraType == 'wide' || event.extraType == 'noball') {
            bowlerConceded += 1;
          }
          if (event.extraType != 'bye' && event.extraType != 'legbye') {
            runsConcededInMatch += bowlerConceded;
          }

          if (event.isWicket && event.wicketType != 'run out') {
            wicketsInMatch++;
          }
        }

        // Fielding stats
        if (event.fielderId == freshPlayer.id && event.wicketType == 'caught') {
          catchesInMatch++;
        }
      }

      final updatedPlayer = freshPlayer.copyWith(
        matchesPlayed: freshPlayer.matchesPlayed + 1,
        runsScored: freshPlayer.runsScored + runsInMatch,
        ballsFaced: freshPlayer.ballsFaced + ballsFacedInMatch,
        wicketsTaken: freshPlayer.wicketsTaken + wicketsInMatch,
        ballsBowled: freshPlayer.ballsBowled + ballsBowledInMatch,
        runsConceded: freshPlayer.runsConceded + runsConcededInMatch,
        catches: freshPlayer.catches + catchesInMatch,
        highestScore: runsInMatch > freshPlayer.highestScore ? runsInMatch : freshPlayer.highestScore,
      );

      updatedPlayers.add(updatedPlayer);
    }

    try {
      await DatabaseHelper.instance.saveCareerStats(updatedPlayers);
    } catch (e) {
      debugPrint('SQLite Error (saveCareerStats): $e');
    }
  }

  Map<String, dynamic> compileMatchJson() {
    if (_currentMatch == null) return {};

    final List<Map<String, Map<String, dynamic>>> inningsBatsmen = [{}, {}];
    final List<Map<String, Map<String, dynamic>>> inningsBowlers = [{}, {}];
    final List<Map<String, int>> inningsExtras = [
      {'wide': 0, 'noball': 0, 'bye': 0, 'legbye': 0, 'total': 0},
      {'wide': 0, 'noball': 0, 'bye': 0, 'legbye': 0, 'total': 0}
    ];

    for (var p in _teamAPlayers) {
      inningsBatsmen[0][p.name] = {
        'playerId': p.id ?? 0,
        'name': p.name,
        'runs': 0,
        'ballsFaced': 0,
        'fours': 0,
        'sixes': 0,
        'isOut': false,
        'dismissalType': '',
        'dismissedBy': '',
        'fielderName': ''
      };
    }
    for (var p in _teamBPlayers) {
      inningsBowlers[0][p.name] = {
        'playerId': p.id ?? 0,
        'name': p.name,
        'ballsBowled': 0,
        'runsConceded': 0,
        'wickets': 0,
        'maidens': 0,
        'economy': 0.0
      };
    }

    for (var p in _teamBPlayers) {
      inningsBatsmen[1][p.name] = {
        'playerId': p.id ?? 0,
        'name': p.name,
        'runs': 0,
        'ballsFaced': 0,
        'fours': 0,
        'sixes': 0,
        'isOut': false,
        'dismissalType': '',
        'dismissedBy': '',
        'fielderName': ''
      };
    }
    for (var p in _teamAPlayers) {
      inningsBowlers[1][p.name] = {
        'playerId': p.id ?? 0,
        'name': p.name,
        'ballsBowled': 0,
        'runsConceded': 0,
        'wickets': 0,
        'maidens': 0,
        'economy': 0.0
      };
    }

    for (var event in _ballEvents) {
      final innIdx = event.inningsIndex;
      if (innIdx < 0 || innIdx > 1) continue;

      final batsmanName = event.batsmanName;
      final bowlerName = event.bowlerName;

      if (!inningsBatsmen[innIdx].containsKey(batsmanName)) {
        final pList = innIdx == 0 ? _teamAPlayers : _teamBPlayers;
        final p = pList.firstWhere((pl) => pl.name.toLowerCase() == batsmanName.toLowerCase(), orElse: () => Player(name: batsmanName));
        inningsBatsmen[innIdx][batsmanName] = {
          'playerId': p.id ?? 0,
          'name': batsmanName,
          'runs': 0,
          'ballsFaced': 0,
          'fours': 0,
          'sixes': 0,
          'isOut': false,
          'dismissalType': '',
          'dismissedBy': '',
          'fielderName': ''
        };
      }

      if (!inningsBowlers[innIdx].containsKey(bowlerName)) {
        final pList = innIdx == 0 ? _teamBPlayers : _teamAPlayers;
        final p = pList.firstWhere((pl) => pl.name.toLowerCase() == bowlerName.toLowerCase(), orElse: () => Player(name: bowlerName));
        inningsBowlers[innIdx][bowlerName] = {
          'playerId': p.id ?? 0,
          'name': bowlerName,
          'ballsBowled': 0,
          'runsConceded': 0,
          'wickets': 0,
          'maidens': 0,
          'economy': 0.0
        };
      }

      final bat = inningsBatsmen[innIdx][batsmanName]!;
      final bowl = inningsBowlers[innIdx][bowlerName]!;
      final ext = inningsExtras[innIdx];

      if (event.extraType != 'wide') {
        bat['ballsFaced'] = (bat['ballsFaced'] as int) + 1;
      }
      if (event.extraType == 'none' || event.extraType == 'noball') {
        bat['runs'] = (bat['runs'] as int) + event.runs;
        if (event.runs == 4) bat['fours'] = (bat['fours'] as int) + 1;
        if (event.runs == 6) bat['sixes'] = (bat['sixes'] as int) + 1;
      }

      if (isLegalBall(event.extraType)) {
        bowl['ballsBowled'] = (bowl['ballsBowled'] as int) + 1;
      }

      int bowlConceded = event.runs;
      if (event.extraType == 'wide' || event.extraType == 'noball') {
        bowlConceded += 1;
      }
      if (event.extraType != 'bye' && event.extraType != 'legbye') {
        bowl['runsConceded'] = (bowl['runsConceded'] as int) + bowlConceded;
      }

      if (event.isWicket) {
        final dismissedName = event.dismissedPlayerId == event.batsmanId ? batsmanName : (event.fielderName ?? batsmanName);
        if (inningsBatsmen[innIdx].containsKey(dismissedName)) {
          final dismissedBat = inningsBatsmen[innIdx][dismissedName]!;
          dismissedBat['isOut'] = true;
          dismissedBat['dismissalType'] = event.wicketType ?? 'out';
          dismissedBat['dismissedBy'] = bowlerName;
          dismissedBat['fielderName'] = event.fielderName ?? '';
        }

        if (event.wicketType != 'run out') {
          bowl['wickets'] = (bowl['wickets'] as int) + 1;
        }
      }

      if (event.extraType == 'wide' || event.extraType == 'noball') {
        ext[event.extraType] = (ext[event.extraType] ?? 0) + 1;
        ext['total'] = (ext['total'] ?? 0) + 1;
      } else if (event.extraType == 'bye' || event.extraType == 'legbye') {
        ext[event.extraType] = (ext[event.extraType] ?? 0) + event.runs;
        ext['total'] = (ext['total'] ?? 0) + event.runs;
      }
    }

    for (int i = 0; i < 2; i++) {
      inningsBowlers[i].forEach((name, data) {
        final balls = data['ballsBowled'] as int;
        final conceded = data['runsConceded'] as int;
        if (balls > 0) {
          data['economy'] = conceded / (balls / 6.0);
        }
      });
    }

    final teamABallsBowled = _inningsIndex == 1 ? _currentMatch!.teamABalls : _ballsBowled;
    final teamBBallsBowled = _inningsIndex == 1 ? _ballsBowled : 0;

    return {
      'matchId': _currentMatch!.id,
      'date': _currentMatch!.date,
      'teamAName': _currentMatch!.teamAName,
      'teamBName': _currentMatch!.teamBName,
      'oversCount': _currentMatch!.oversCount,
      'playersPerTeam': _currentMatch!.playersPerTeam,
      'winner': _currentMatch!.winner,
      'teamAScore': _inningsIndex == 1 ? _firstInningsScore : _totalScore,
      'teamAWickets': _inningsIndex == 1 ? _currentMatch!.teamAWickets : _wickets,
      'teamABallsBowled': teamABallsBowled,
      'teamBScore': _inningsIndex == 1 ? _totalScore : 0,
      'teamBWickets': _inningsIndex == 1 ? _wickets : 0,
      'teamBBallsBowled': teamBBallsBowled,
      'innings': [
        {
          'inningsIndex': 0,
          'battingTeam': _currentMatch!.teamAName,
          'bowlingTeam': _currentMatch!.teamBName,
          'totalRuns': _firstInningsScore > 0 ? _firstInningsScore : _totalScore,
          'wickets': _inningsIndex == 1 ? _currentMatch!.teamAWickets : _wickets,
          'ballsBowled': _inningsIndex == 1 ? _currentMatch!.teamABalls : _ballsBowled,
          'extras': inningsExtras[0],
          'battingScorecard': inningsBatsmen[0].values.where((bat) {
            return (bat['ballsFaced'] as int) > 0 || (bat['isOut'] as bool);
          }).toList(),
          'bowlingScorecard': inningsBowlers[0].values.where((bowl) {
            return (bowl['ballsBowled'] as int) > 0;
          }).toList(),
        },
        {
          'inningsIndex': 1,
          'battingTeam': _currentMatch!.teamBName,
          'bowlingTeam': _currentMatch!.teamAName,
          'totalRuns': _inningsIndex == 1 ? _totalScore : 0,
          'wickets': _inningsIndex == 1 ? _wickets : 0,
          'ballsBowled': _inningsIndex == 1 ? _ballsBowled : 0,
          'extras': inningsExtras[1],
          'battingScorecard': inningsBatsmen[1].values.where((bat) {
            final name = bat['name'] as String;
            final isAtCrease = (name == _striker?.name || name == _nonStriker?.name);
            return (bat['ballsFaced'] as int) > 0 || (bat['isOut'] as bool) || isAtCrease;
          }).toList(),
          'bowlingScorecard': inningsBowlers[1].values.where((bowl) {
            return (bowl['ballsBowled'] as int) > 0;
          }).toList(),
        }
      ],
      'ballEvents': _ballEvents.map((e) => {
        'inningsIndex': e.inningsIndex,
        'overNumber': e.overNumber,
        'ballNumber': e.ballNumber,
        'batsmanName': e.batsmanName,
        'bowlerName': e.bowlerName,
        'runs': e.runs,
        'isWicket': e.isWicket ? 1 : 0,
        'wicketType': e.wicketType ?? 'none',
        'fielderName': e.fielderName,
        'extraRuns': e.extraRuns,
        'extraType': e.extraType,
      }).toList(),
    };
  }

  bool isLegalBall(String extraType) {
    return extraType != 'wide' && extraType != 'noball';
  }

  void exitMatch() {
    _activeMatchId = null;
    _currentMatch = null;
    _teamAPlayers = [];
    _teamBPlayers = [];
    _resetLiveState();
    notifyListeners();
  }
}

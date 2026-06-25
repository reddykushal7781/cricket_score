import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/player.dart';
import '../models/match.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cricket_score.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Drop and recreate match_players table to change primary key
          await db.execute('DROP TABLE IF EXISTS match_players');
          await db.execute('''
            CREATE TABLE match_players (
              match_id INTEGER NOT NULL,
              player_id INTEGER NOT NULL,
              team_index INTEGER NOT NULL,
              PRIMARY KEY (match_id, player_id, team_index)
            )
          ''');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerNullableType = 'INTEGER';

    // Users table for authentication
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username TEXT UNIQUE NOT NULL,
        password $textType
      )
    ''');

    // Players table
    await db.execute('''
      CREATE TABLE players (
        id $idType,
        name TEXT UNIQUE NOT NULL,
        matches_played $integerType DEFAULT 0,
        runs_scored $integerType DEFAULT 0,
        balls_faced $integerType DEFAULT 0,
        wickets_taken $integerType DEFAULT 0,
        balls_bowled $integerType DEFAULT 0,
        runs_conceded $integerType DEFAULT 0,
        catches $integerType DEFAULT 0,
        highest_score $integerType DEFAULT 0
      )
    ''');

    // Matches table
    await db.execute('''
      CREATE TABLE matches (
        id $idType,
        team_a_name $textType,
        team_b_name $textType,
        overs_count $integerType,
        players_per_team $integerType,
        team_a_score $integerType DEFAULT 0,
        team_b_score $integerType DEFAULT 0,
        team_a_wickets $integerType DEFAULT 0,
        team_b_wickets $integerType DEFAULT 0,
        team_a_balls $integerType DEFAULT 0,
        team_b_balls $integerType DEFAULT 0,
        winner $textNullableType,
        is_completed $integerType DEFAULT 0,
        date $textType
      )
    ''');

    // Match Players relationship table
    await db.execute('''
      CREATE TABLE match_players (
        match_id $integerType,
        player_id $integerType,
        team_index $integerType,
        PRIMARY KEY (match_id, player_id, team_index)
      )
    ''');

    // Ball Events table for tracking match history
    await db.execute('''
      CREATE TABLE ball_events (
        id $idType,
        match_id $integerType,
        innings_index $integerType,
        ball_index $integerType,
        over_number $integerType,
        ball_number $integerType,
        batsman_id $integerType,
        batsman_name $textType,
        bowler_id $integerType,
        bowler_name $textType,
        runs $integerType,
        is_wicket $integerType,
        wicket_type $textNullableType,
        dismissed_player_id $integerNullableType,
        fielder_id $integerNullableType,
        fielder_name $textNullableType,
        extra_runs $integerType DEFAULT 0,
        extra_type $textType DEFAULT 'none'
      )
    ''');
  }

  // --- Auth Service Queries ---
  Future<int> registerUser(String username, String password) async {
    final db = await database;
    try {
      return await db.insert('users', {
        'username': username,
        'password': password,
      });
    } catch (_) {
      return -1; // Username already exists
    }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (results.isNotEmpty) return results.first;
    return null;
  }

  // --- Player Queries ---
  Future<List<Player>> searchPlayers(String nameQuery) async {
    final db = await database;
    final results = await db.query(
      'players',
      where: 'name LIKE ?',
      whereArgs: ['%$nameQuery%'],
      limit: 10,
    );
    return results.map((m) => Player.fromMap(m)).toList();
  }

  Future<Player> getOrCreatePlayer(String name) async {
    final db = await database;
    final results = await db.query(
      'players',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (results.isNotEmpty) {
      return Player.fromMap(results.first);
    } else {
      final id = await db.insert('players', {
        'name': name,
        'matches_played': 0,
        'runs_scored': 0,
        'balls_faced': 0,
        'wickets_taken': 0,
        'balls_bowled': 0,
        'runs_conceded': 0,
        'catches': 0,
        'highest_score': 0,
      });
      return Player(id: id, name: name);
    }
  }

  Future<List<Player>> getAllPlayers() async {
    final db = await database;
    final results = await db.query('players', orderBy: 'runs_scored DESC');
    return results.map((m) => Player.fromMap(m)).toList();
  }

  // --- Matches Queries ---
  Future<int> createMatch(CricketMatch match, List<Player> teamA, List<Player> teamB) async {
    final db = await database;
    final matchId = await db.insert('matches', match.toMap());

    // Insert team memberships
    final batch = db.batch();
    for (var player in teamA) {
      batch.insert('match_players', {
        'match_id': matchId,
        'player_id': player.id,
        'team_index': 0,
      });
    }
    for (var player in teamB) {
      batch.insert('match_players', {
        'match_id': matchId,
        'player_id': player.id,
        'team_index': 1,
      });
    }
    await batch.commit(noResult: true);

    return matchId;
  }

  Future<void> updateMatchScore(int matchId, {
    required int teamAScore,
    required int teamBScore,
    required int teamAWickets,
    required int teamBWickets,
    required int teamABalls,
    required int teamBBalls,
  }) async {
    final db = await database;
    await db.update(
      'matches',
      {
        'team_a_score': teamAScore,
        'team_b_score': teamBScore,
        'team_a_wickets': teamAWickets,
        'team_b_wickets': teamBWickets,
        'team_a_balls': teamABalls,
        'team_b_balls': teamBBalls,
      },
      where: 'id = ?',
      whereArgs: [matchId],
    );
  }

  Future<void> completeMatch(int matchId, String winner) async {
    final db = await database;
    await db.update(
      'matches',
      {
        'winner': winner,
        'is_completed': 1,
      },
      where: 'id = ?',
      whereArgs: [matchId],
    );
  }

  Future<void> deleteMatch(int matchId) async {
    final db = await database;
    await db.delete('matches', where: 'id = ?', whereArgs: [matchId]);
    await db.delete('match_players', where: 'match_id = ?', whereArgs: [matchId]);
    await db.delete('ball_events', where: 'match_id = ?', whereArgs: [matchId]);
  }

  Future<List<CricketMatch>> getCompletedMatches() async {
    final db = await database;
    final results = await db.query(
      'matches',
      where: 'is_completed = 1',
      orderBy: 'id DESC',
    );
    return results.map((m) => CricketMatch.fromMap(m)).toList();
  }

  Future<CricketMatch?> getActiveMatch() async {
    final db = await database;
    final results = await db.query(
      'matches',
      where: 'is_completed = 0',
      orderBy: 'id DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return CricketMatch.fromMap(results.first);
  }

  // --- Ball Events / Undo / Resume Queries ---
  Future<int> insertBallEvent(BallEvent event) async {
    final db = await database;
    return await db.insert('ball_events', event.toMap());
  }

  Future<void> deleteLastBallEvent(int matchId) async {
    final db = await database;
    // Find the latest ball event for this match
    final lastEvent = await db.query(
      'ball_events',
      where: 'match_id = ?',
      whereArgs: [matchId],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (lastEvent.isNotEmpty) {
      final id = lastEvent.first['id'];
      await db.delete(
        'ball_events',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<List<BallEvent>> getBallEventsForMatch(int matchId) async {
    final db = await database;
    final results = await db.query(
      'ball_events',
      where: 'match_id = ?',
      whereArgs: [matchId],
      orderBy: 'id ASC',
    );
    return results.map((m) => BallEvent.fromMap(m)).toList();
  }

  Future<List<Player>> getMatchPlayers(int matchId, int teamIndex) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT p.* FROM players p
      INNER JOIN match_players mp ON p.id = mp.player_id
      WHERE mp.match_id = ? AND mp.team_index = ?
    ''', [matchId, teamIndex]);
    return results.map((m) => Player.fromMap(m)).toList();
  }

  Future<List<CricketMatch>> getPlayerMatchesByName(String playerName) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT m.* FROM matches m
      INNER JOIN match_players mp ON m.id = mp.match_id
      INNER JOIN players p ON mp.player_id = p.id
      WHERE p.name = ?
      ORDER BY m.id DESC
    ''', [playerName]);
    return results.map((m) => CricketMatch.fromMap(m)).toList();
  }

  // --- Compile Stats on Innings / Match Completion ---
  Future<void> saveCareerStats(List<Player> updatedPlayers) async {
    final db = await database;
    final batch = db.batch();
    for (var player in updatedPlayers) {
      batch.update(
        'players',
        player.toMap(),
        where: 'id = ?',
        whereArgs: [player.id],
      );
    }
    await batch.commit(noResult: true);
  }
}

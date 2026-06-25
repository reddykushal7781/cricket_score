import 'package:flutter/material.dart';
import '../services/mock_stats_data.dart';
import '../services/api_service.dart';

class DayStatsDetailPage extends StatefulWidget {
  final DayStats dayStats;

  const DayStatsDetailPage({
    super.key,
    required this.dayStats,
  });

  @override
  State<DayStatsDetailPage> createState() => _DayStatsDetailPageState();
}

class _DayStatsDetailPageState extends State<DayStatsDetailPage> {
  late DayStats _currentDayStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentDayStats = widget.dayStats;
    _fetchPerformers();
  }

  Future<void> _fetchPerformers() async {
    setState(() => _isLoading = true);
    try {
      final performers = await ApiService.getStatsPerformers(_currentDayStats.date);
      if (mounted) {
        setState(() {
          _currentDayStats = _parsePerformers(_currentDayStats.date, _currentDayStats.matchesPlayed, performers);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching performers, using fallback stats data: $e');
      if (mounted) {
        setState(() {
          if (_currentDayStats.topBatsmen.isEmpty) {
            final mockMatch = MockStatsData.mockDailyStats.firstWhere(
              (d) => d.date == _currentDayStats.date,
              orElse: () => _currentDayStats,
            );
            _currentDayStats = mockMatch;
          }
          _isLoading = false;
        });
      }
    }
  }

  DayStats _parsePerformers(String date, int matchesPlayed, Map<String, dynamic> json) {
    final listBatsmen = json['topBatsmen'] as List<dynamic>? ?? [];
    final listBowlers = json['topBowlers'] as List<dynamic>? ?? [];
    final listDots = json['topDotBowlers'] as List<dynamic>? ?? [];

    return DayStats(
      date: date,
      matchesPlayed: matchesPlayed,
      topBatsmen: listBatsmen.map((b) => TopBatsman(
        name: b['name'] as String? ?? 'Player',
        runs: b['runs'] as int? ?? 0,
        balls: b['balls'] as int? ?? 0,
        strikeRate: (b['strikeRate'] as num? ?? 0.0).toDouble(),
      )).toList(),
      topBowlers: listBowlers.map((b) => TopBowler(
        name: b['name'] as String? ?? 'Player',
        wickets: b['wickets'] as int? ?? 0,
        runsConceded: b['runsConceded'] as int? ?? 0,
        overs: (b['overs'] as num? ?? 0.0).toDouble(),
      )).toList(),
      topDotBowlers: listDots.map((b) => TopDotBallBowler(
        name: b['name'] as String? ?? 'Player',
        dotBalls: b['dotBalls'] as int? ?? 0,
        overs: (b['overs'] as num? ?? 0.0).toDouble(),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gold/Amber accent color representing leaderboards and podium standings
    const leaderboardColor = Color(0xFFFFB300);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1115),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E222B),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentDayStats.date,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18),
              ),
              Text(
                '${_currentDayStats.matchesPlayed} Matches Played',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 12),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const TabBar(
            indicatorColor: leaderboardColor,
            labelColor: leaderboardColor,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3.0,
            tabs: [
              Tab(
                icon: Icon(Icons.sports_cricket, size: 20),
                text: 'TOP BATSMEN',
              ),
              Tab(
                icon: Icon(Icons.radar, size: 20),
                text: 'TOP BOWLERS',
              ),
              Tab(
                icon: Icon(Icons.blur_circular, size: 20),
                text: 'DOT BALLS',
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: leaderboardColor))
            : TabBarView(
                children: [
                  _buildBatsmenList(leaderboardColor),
                  _buildBowlersList(leaderboardColor),
                  _buildDotBowlersList(leaderboardColor),
                ],
              ),
      ),
    );
  }

  Widget _buildBatsmenList(Color accentColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _currentDayStats.topBatsmen.length,
      itemBuilder: (context, index) {
        final b = _currentDayStats.topBatsmen[index];
        final rank = index + 1;
        return _buildLeaderboardCard(
          rank: rank,
          name: b.name,
          primaryStat: '${b.runs} Runs',
          secondaryStat:
              '${b.balls} balls • SR: ${b.strikeRate.toStringAsFixed(1)}',
          accentColor: accentColor,
          icon: Icons.sports_cricket,
        );
      },
    );
  }

  Widget _buildBowlersList(Color accentColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _currentDayStats.topBowlers.length,
      itemBuilder: (context, index) {
        final b = _currentDayStats.topBowlers[index];
        final rank = index + 1;
        final economy =
            b.overs > 0 ? (b.runsConceded / b.overs).toStringAsFixed(2) : '-';
        return _buildLeaderboardCard(
          rank: rank,
          name: b.name,
          primaryStat: '${b.wickets} Wkts',
          secondaryStat:
              '${b.runsConceded} Runs • ${b.overs} Overs • Econ: $economy',
          accentColor: accentColor,
          icon: Icons.radar,
        );
      },
    );
  }

  Widget _buildDotBowlersList(Color accentColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _currentDayStats.topDotBowlers.length,
      itemBuilder: (context, index) {
        final b = _currentDayStats.topDotBowlers[index];
        final rank = index + 1;
        return _buildLeaderboardCard(
          rank: rank,
          name: b.name,
          primaryStat: '${b.dotBalls} Dots',
          secondaryStat: 'In ${b.overs} Overs bowled',
          accentColor: accentColor,
          icon: Icons.blur_circular,
        );
      },
    );
  }

  Widget _buildLeaderboardCard({
    required int rank,
    required String name,
    required String primaryStat,
    required String secondaryStat,
    required Color accentColor,
    required IconData icon,
  }) {
    final isPodium = rank <= 3;
    final Color rankBgColor = rank == 1
        ? const Color(0xFFFFD700) // Gold
        : rank == 2
            ? const Color(0xFFC0C0C0) // Silver
            : rank == 3
                ? const Color(0xFFCD7F32) // Bronze
                : const Color(0xFF161A22);

    final Color rankTextColor = rank <= 3 ? Colors.black : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank == 1
              ? const Color(0xFFFFD700).withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          width: rank == 1 ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rankBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rankTextColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (rank == 1) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.emoji_events, color: accentColor, size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  secondaryStat,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          // Primary Metric
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: rank == 1
                  ? const Color(0xFFFFD700).withOpacity(0.1)
                  : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: rank == 1
                    ? const Color(0xFFFFD700).withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
              ),
            ),
            child: Text(
              primaryStat,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rank == 1 ? const Color(0xFFFFD700) : Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

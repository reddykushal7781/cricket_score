import 'package:flutter/material.dart';
import '../services/mock_stats_data.dart';
import '../models/user_profile.dart';
import 'day_stats_detail_page.dart';
import 'player_profile_page.dart';
import '../services/api_service.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  int _selectedSubTab = 0; // 0 for Match Days, 1 for Player Search
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<DayStats> _dailyStats = [];
  List<UserProfile> _allPlayers = [];
  List<UserProfile> _filteredPlayers = [];
  bool _isLoading = true;

  static const neonGreen = Color(0xFF39FF14);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final daysJson = await ApiService.getStatsDays();
      final List<DayStats> days = [];
      
      // Fetch daily performers in parallel to populate the card's top performers directly from actual backend APIs
      await Future.wait(daysJson.map((d) async {
        final dateStr = d['date'] as String? ?? '';
        final matchesCount = d['matchesPlayed'] as int? ?? 0;
        try {
          final performers = await ApiService.getStatsPerformers(dateStr);
          final listBatsmen = performers['topBatsmen'] as List<dynamic>? ?? [];
          final listBowlers = performers['topBowlers'] as List<dynamic>? ?? [];
          final listDots = performers['topDotBowlers'] as List<dynamic>? ?? [];

          final day = DayStats(
            date: dateStr,
            matchesPlayed: matchesCount,
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
          days.add(day);
        } catch (e) {
          debugPrint('Error loading performers for $dateStr: $e');
          days.add(DayStats(
            date: dateStr,
            matchesPlayed: matchesCount,
            topBatsmen: [],
            topBowlers: [],
            topDotBowlers: [],
          ));
        }
      }));

      // Sort match days by date descending
      days.sort((a, b) => b.date.compareTo(a.date));

      final searchResults = await ApiService.searchPlayers('');
      final List<UserProfile> players = searchResults.map((item) {
        return UserProfile(
          username: (item['username'] ?? item['name']?.replaceAll(' ', '.')?.toLowerCase() ?? '') as String,
          name: item['name'] as String? ?? 'Player',
          avatarUrl: '',
          role: 'Player',
          battingStyle: 'Right-hand bat',
          bowlingStyle: 'Right-arm medium',
          battingStats: BattingStats(
            matches: 0, innings: 0, runs: 0, ballsFaced: 0, average: 0, strikeRate: 0,
            highestScore: '0', notOuts: 0, fifties: 0, hundreds: 0, fours: 0, sixes: 0,
          ),
          bowlingStats: BowlingStats(
            matches: 0, innings: 0, wickets: 0, runsConceded: 0, ballsBowled: 0,
            economy: 0, average: 0, strikeRate: 0, bestBowling: '-', threeWickets: 0, fiveWickets: 0,
          ),
          fieldingStats: FieldingStats(catches: 0, stumpings: 0, runOuts: 0),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _dailyStats = days;
          _allPlayers = players;
          _filteredPlayers = List.from(_allPlayers);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats from API, falling back to mock: $e');
      if (mounted) {
        setState(() {
          _dailyStats = MockStatsData.mockDailyStats;
          _allPlayers = MockStatsData.mockPlayers;
          _filteredPlayers = List.from(_allPlayers);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onSearchChanged(String query) async {
    setState(() {
      _searchQuery = query;
    });

    if (query.trim().isEmpty) {
      setState(() {
        _filteredPlayers = List.from(_allPlayers);
      });
      return;
    }

    try {
      final results = await ApiService.searchPlayers(query);
      final List<UserProfile> list = results.map((item) {
        return UserProfile(
          username: (item['username'] ?? item['name']?.replaceAll(' ', '.')?.toLowerCase() ?? '') as String,
          name: item['name'] as String? ?? 'Player',
          avatarUrl: '',
          role: 'Player',
          battingStyle: 'Right-hand bat',
          bowlingStyle: 'Right-arm medium',
          battingStats: BattingStats(
            matches: 0, innings: 0, runs: 0, ballsFaced: 0, average: 0, strikeRate: 0,
            highestScore: '0', notOuts: 0, fifties: 0, hundreds: 0, fours: 0, sixes: 0,
          ),
          bowlingStats: BowlingStats(
            matches: 0, innings: 0, wickets: 0, runsConceded: 0, ballsBowled: 0,
            economy: 0, average: 0, strikeRate: 0, bestBowling: '-', threeWickets: 0, fiveWickets: 0,
          ),
          fieldingStats: FieldingStats(catches: 0, stumpings: 0, runOuts: 0),
        );
      }).toList();

      if (mounted && _searchQuery == query) {
        setState(() {
          _filteredPlayers = list;
        });
      }
    } catch (e) {
      debugPrint('Error searching players from API: $e');
      if (mounted && _searchQuery == query) {
        setState(() {
          _filteredPlayers = _allPlayers
              .where((p) =>
                  p.name.toLowerCase().contains(query.toLowerCase()) ||
                  p.role.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      }
    }
  }

  Future<void> _navigateToPlayerProfile(String playerName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: neonGreen),
      ),
    );

    try {
      final profile = await ApiService.getPlayerProfile(playerName);
      if (!mounted) return;
      Navigator.of(context).pop(); 
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlayerProfilePage(
            playerProfile: profile,
            isCurrentUser: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); 
      debugPrint('Error fetching profile from API: $e');
      
      final localProfile = MockStatsData.mockPlayers.firstWhere(
        (p) => p.name.toLowerCase() == playerName.toLowerCase(),
        orElse: () => UserProfile(
          username: playerName.replaceAll(' ', '.').toLowerCase(),
          name: playerName,
          avatarUrl: '',
          role: 'Player',
          battingStyle: 'Right-hand bat',
          bowlingStyle: 'Right-arm medium',
          battingStats: BattingStats(
            matches: 0, innings: 0, runs: 0, ballsFaced: 0, average: 0, strikeRate: 0,
            highestScore: '0', notOuts: 0, fifties: 0, hundreds: 0, fours: 0, sixes: 0,
          ),
          bowlingStats: BowlingStats(
            matches: 0, innings: 0, wickets: 0, runsConceded: 0, ballsBowled: 0,
            economy: 0, average: 0, strikeRate: 0, bestBowling: '-', threeWickets: 0, fiveWickets: 0,
          ),
          fieldingStats: FieldingStats(catches: 0, stumpings: 0, runOuts: 0),
        ),
      );
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlayerProfilePage(
            playerProfile: localProfile,
            isCurrentUser: false,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: neonGreen))
          : Column(
              children: [
                _buildSubTabToggle(),
                Expanded(
                  child: _selectedSubTab == 0
                      ? _buildMatchDaysTab()
                      : _buildPlayerSearchTab(),
                ),
              ],
            ),
    );
  }

  Widget _buildSubTabToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF1E222B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSubTab = 0),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedSubTab == 0
                      ? neonGreen.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color:
                        _selectedSubTab == 0 ? neonGreen : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'MATCH DAYS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedSubTab == 0
                        ? neonGreen
                        : Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSubTab = 1),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedSubTab == 1
                      ? neonGreen.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color:
                        _selectedSubTab == 1 ? neonGreen : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'PLAYER SEARCH',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedSubTab == 1
                        ? neonGreen
                        : Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchDaysTab() {
    return _dailyStats.isEmpty
        ? const Center(
            child: Text(
              'No match days recorded yet.',
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            itemCount: _dailyStats.length,
            itemBuilder: (context, index) {
              final day = _dailyStats[index];
              return Card(
                color: const Color(0xFF1E222B),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DayStatsDetailPage(dayStats: day),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day.date,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${day.matchesPlayed} matches scored',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    color: const Color(0xFFFFB300)
                                        .withOpacity(0.8),
                                    size: 16),
                                const SizedBox(width: 4),
                                  Text(
                                    day.topBatsmen.isNotEmpty
                                        ? 'Top: ${day.topBatsmen.first.name}'
                                        : 'Tap to view daily top performances',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: neonGreen,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search player or role...',
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: neonGreen, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPlayerSearchTab() {
    return Column(
      children: [
        _buildSearchField(),
        Expanded(
          child: _filteredPlayers.isEmpty
              ? const Center(
                  child: Text(
                    'No matching players found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  itemCount: _filteredPlayers.length,
                  itemBuilder: (context, index) {
                    final player = _filteredPlayers[index];
                    return Card(
                      color: const Color(0xFF1E222B),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: InkWell(
                        onTap: () => _navigateToPlayerProfile(player.name),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF00E5FF).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFF00E5FF),
                                      width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 28,
                                  color: Color(0xFF00E5FF),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      player.role,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF00E5FF),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

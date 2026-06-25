import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/match.dart';
import '../services/database_helper.dart';
import 'previous_matches_tab.dart';
import '../services/api_service.dart';

class PlayerProfilePage extends StatelessWidget {
  final UserProfile playerProfile;
  final bool isCurrentUser;

  const PlayerProfilePage({
    super.key,
    required this.playerProfile,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    // Current user gets Neon Green, other players get Neon Blue to prevent confusion
    final themeColor =
        isCurrentUser ? const Color(0xFF39FF14) : const Color(0xFF00E5FF);
    final roleColor = isCurrentUser
        ? themeColor.withOpacity(0.15)
        : themeColor.withOpacity(0.12);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1115),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: const Color(0xFF1E222B),
                expandedHeight: 320.0,
                floating: false,
                pinned: true,
                title: Text(
                  isCurrentUser
                      ? 'Player Profile (You)'
                      : '${playerProfile.name} Stats',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.only(
                        top: 88.0, left: 16.0, right: 16.0, bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar & Name Card
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: themeColor, width: 2),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    playerProfile.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (playerProfile.username.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '@${playerProfile.username}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: roleColor,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color:
                                                  themeColor.withOpacity(0.3),
                                              width: 0.5),
                                        ),
                                        child: Text(
                                          playerProfile.role,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: themeColor,
                                          ),
                                        ),
                                      ),
                                      if (!isCurrentUser) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Team Member',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Style details
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161A22),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'BATTING STYLE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.5),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    playerProfile.battingStyle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              Column(
                                children: [
                                  Text(
                                    'BOWLING STYLE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.5),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    playerProfile.bowlingStyle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  indicatorColor: themeColor,
                  labelColor: themeColor,
                  unselectedLabelColor: Colors.white.withOpacity(0.6),
                  indicatorWeight: 3.0,
                  tabs: const [
                    Tab(text: 'OVERVIEW'),
                    Tab(text: 'BATTING'),
                    Tab(text: 'BOWLING'),
                    Tab(text: 'MATCHES'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildOverviewTab(themeColor),
              _buildBattingTab(),
              _buildBowlingTab(),
              PlayerMatchesTab(playerName: playerProfile.name),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(Color themeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Career Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildStatCard('Matches', '${playerProfile.battingStats.matches}',
                  Icons.sports_cricket, themeColor),
              _buildStatCard('Runs', '${playerProfile.battingStats.runs}',
                  Icons.timeline, themeColor),
              _buildStatCard('Wickets', '${playerProfile.bowlingStats.wickets}',
                  Icons.radar, themeColor),
              _buildStatCard(
                  'Batting Avg',
                  '${playerProfile.battingStats.average}',
                  Icons.trending_up,
                  themeColor),
              _buildStatCard(
                  'Highest Score',
                  playerProfile.battingStats.highestScore,
                  Icons.emoji_events,
                  themeColor),
              _buildStatCard(
                  'Best Bowling',
                  playerProfile.bowlingStats.bestBowling,
                  Icons.star,
                  themeColor),
              _buildStatCard(
                  'Bowling Avg',
                  '${playerProfile.bowlingStats.average}',
                  Icons.trending_down,
                  themeColor),
              _buildStatCard(
                  'Catches',
                  '${playerProfile.fieldingStats.catches}',
                  Icons.pan_tool,
                  themeColor),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Fielding & Extras',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E222B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFieldingItem(
                    'Catches', '${playerProfile.fieldingStats.catches}'),
                _buildFieldingItem(
                    'Stumpings', '${playerProfile.fieldingStats.stumpings}'),
                _buildFieldingItem(
                    'Run Outs', '${playerProfile.fieldingStats.runOuts}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E222B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: themeColor.withOpacity(0.8), size: 18),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldingItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBattingTab() {
    final b = playerProfile.battingStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Batting Career Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E222B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                _buildStatRow('Matches', '${b.matches}'),
                _buildStatRow('Innings', '${b.innings}'),
                _buildStatRow('Runs', '${b.runs}'),
                _buildStatRow('Balls Faced', '${b.ballsFaced}'),
                _buildStatRow('Average', '${b.average}'),
                _buildStatRow('Strike Rate', '${b.strikeRate}'),
                _buildStatRow('Highest Score', b.highestScore),
                _buildStatRow('Not Outs', '${b.notOuts}'),
                _buildStatRow('Fifties', '${b.fifties}'),
                _buildStatRow('Hundreds', '${b.hundreds}'),
                _buildStatRow('Fours (4s)', '${b.fours}'),
                _buildStatRow('Sixes (6s)', '${b.sixes}', showBorder: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBowlingTab() {
    final b = playerProfile.bowlingStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bowling Career Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E222B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                _buildStatRow('Matches', '${b.matches}'),
                _buildStatRow('Innings', '${b.innings}'),
                _buildStatRow('Wickets', '${b.wickets}'),
                _buildStatRow('Runs Conceded', '${b.runsConceded}'),
                _buildStatRow('Balls Bowled', '${b.ballsBowled}'),
                _buildStatRow('Economy Rate', '${b.economy}'),
                _buildStatRow('Average', '${b.average}'),
                _buildStatRow('Strike Rate', '${b.strikeRate}'),
                _buildStatRow('Best Bowling', b.bestBowling),
                _buildStatRow('3 Wicket Hauls', '${b.threeWickets}'),
                _buildStatRow('5 Wicket Hauls', '${b.fiveWickets}',
                    showBorder: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool showBorder = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget to display matches played by the player and their individual performance
class PlayerMatchesTab extends StatefulWidget {
  final String playerName;

  const PlayerMatchesTab({super.key, required this.playerName});

  @override
  State<PlayerMatchesTab> createState() => _PlayerMatchesTabState();
}

class _PlayerMatchesTabState extends State<PlayerMatchesTab> {
  List<Map<String, dynamic>> _matchesWithPerformance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayerMatches();
  }

  Future<void> _loadPlayerMatches() async {
    setState(() => _isLoading = true);
    final List<Map<String, dynamic>> temp = [];

    // 1. Fetch matches from the API
    try {
      final apiMatches = await ApiService.getPlayerMatches(widget.playerName);
      for (var item in apiMatches) {
        final match = CricketMatch(
          id: item['matchId'] as int?,
          teamAName: item['teamAName'] as String? ?? 'Team A',
          teamBName: item['teamBName'] as String? ?? 'Team B',
          oversCount: item['oversCount'] as int? ?? 5,
          playersPerTeam: item['playersPerTeam'] as int? ?? 11,
          teamAScore: item['teamAScore'] as int? ?? 0,
          teamBScore: item['teamBScore'] as int? ?? 0,
          teamAWickets: item['teamAWickets'] as int? ?? 0,
          teamBWickets: item['teamBWickets'] as int? ?? 0,
          winner: item['winner'] as String?,
          date: item['date'] as String? ?? '',
        );
        final perf = item['playerPerformance'] as Map<String, dynamic>? ?? {};
        temp.add({
          'match': match,
          'performance': {
            'batted': perf['batted'] as bool? ?? false,
            'runs': perf['runs'] as int? ?? 0,
            'balls': perf['balls'] as int? ?? 0,
            'fours': perf['fours'] as int? ?? 0,
            'sixes': perf['sixes'] as int? ?? 0,
            'isOut': perf['isOut'] as bool? ?? false,
            'dismissalType': perf['dismissalType'] as String? ?? '',
            'dismissedBy': perf['dismissedBy'] as String? ?? '',
            'bowled': perf['bowled'] as bool? ?? false,
            'wickets': perf['wickets'] as int? ?? 0,
            'runsConceded': perf['runsConceded'] as int? ?? 0,
            'ballsBowled': perf['ballsBowled'] as int? ?? 0,
          },
        });
      }
    } catch (e) {
      debugPrint('Error loading player matches from API: $e');
    }

    // 2. Fetch matches from local SQLite and merge
    try {
      final matches = await DatabaseHelper.instance.getPlayerMatchesByName(widget.playerName);
      for (var match in matches) {
        // Avoid duplicates already fetched from API
        bool exists = temp.any((item) {
          final CricketMatch m = item['match'];
          return (m.id != null && m.id == match.id) ||
                 (m.date == match.date && m.teamAName == match.teamAName && m.teamBName == match.teamBName);
        });

        if (!exists) {
          final events = await DatabaseHelper.instance.getBallEventsForMatch(match.id!);
          final perf = _computePerformance(events, widget.playerName);
          temp.add({
            'match': match,
            'performance': perf,
          });
        }
      }
    } catch (ex) {
      debugPrint('Error loading player matches from local SQLite: $ex');
    }

    // 3. Sort all matches by date descending
    temp.sort((a, b) {
      final CricketMatch mA = a['match'];
      final CricketMatch mB = b['match'];
      return mB.date.compareTo(mA.date);
    });

    if (mounted) {
      setState(() {
        _matchesWithPerformance = temp;
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _computePerformance(List<BallEvent> events, String playerName) {
    int runs = 0;
    int balls = 0;
    int fours = 0;
    int sixes = 0;
    bool isOut = false;
    String dismissalType = '';
    String dismissedBy = '';
    
    int wickets = 0;
    int runsConceded = 0;
    int ballsBowled = 0;
    
    bool batted = false;
    bool bowled = false;
    
    for (var event in events) {
      // Batting stats
      if (event.batsmanName.toLowerCase() == playerName.toLowerCase()) {
        batted = true;
        if (event.extraType != 'wide') {
          balls++;
        }
        if (event.extraType == 'none' || event.extraType == 'noball') {
          runs += event.runs;
          if (event.runs == 4) fours++;
          if (event.runs == 6) sixes++;
        }
      }
      
      // Dismissal check
      if (event.isWicket) {
        final disIdName = event.dismissedPlayerId != null ? event.batsmanName : event.batsmanName;
        if (disIdName.toLowerCase() == playerName.toLowerCase()) {
          isOut = true;
          dismissalType = event.wicketType ?? 'out';
          dismissedBy = event.bowlerName;
        }
      }
      
      // Bowling stats
      if (event.bowlerName.toLowerCase() == playerName.toLowerCase()) {
        bowled = true;
        if (event.extraType != 'wide' && event.extraType != 'noball') {
          ballsBowled++;
        }
        int bowlerRuns = event.runs;
        if (event.extraType == 'wide' || event.extraType == 'noball') {
          bowlerRuns += 1;
        }
        if (event.extraType != 'bye' && event.extraType != 'legbye') {
          runsConceded += bowlerRuns;
        }
        if (event.isWicket && event.wicketType != 'run out') {
          wickets++;
        }
      }
    }
    
    return {
      'batted': batted,
      'runs': runs,
      'balls': balls,
      'fours': fours,
      'sixes': sixes,
      'isOut': isOut,
      'dismissalType': dismissalType,
      'dismissedBy': dismissedBy,
      'bowled': bowled,
      'wickets': wickets,
      'runsConceded': runsConceded,
      'ballsBowled': ballsBowled,
    };
  }

  void _showScorecard(CricketMatch match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E222B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return MatchScorecardModal(match: match, scrollController: scrollController);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const neonGreen = Color(0xFF39FF14);
    const neonBlue = Color(0xFF00E5FF);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: neonBlue));
    }

    if (_matchesWithPerformance.isEmpty) {
      return const Center(
        child: Text(
          'No matches recorded for this player.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPlayerMatches,
      color: neonBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _matchesWithPerformance.length,
        itemBuilder: (context, index) {
          final item = _matchesWithPerformance[index];
          final CricketMatch match = item['match'];
          final Map<String, dynamic> perf = item['performance'];

          bool hasBatted = perf['batted'] as bool;
          bool hasBowled = perf['bowled'] as bool;

          return GestureDetector(
            onTap: () => _showScorecard(match),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E222B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        match.date,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      Icon(
                        Icons.insights,
                        color: neonBlue,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Scores Line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${match.teamAName} vs ${match.teamBName}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${match.teamAScore}/${match.teamAWickets} vs ${match.teamBScore}/${match.teamBWickets}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Player's Performance Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13161C),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PLAYER PERFORMANCE",
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (hasBatted) ...[
                              const Icon(Icons.sports_cricket, color: neonGreen, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${perf['runs']} (${perf['balls']}b)${perf['isOut'] ? "" : " *"}',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ] else ...[
                              Icon(Icons.sports_cricket, color: Colors.white.withOpacity(0.2), size: 14),
                              const SizedBox(width: 4),
                              const Text(
                                'DNB',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                            const SizedBox(width: 16),
                            if (hasBowled) ...[
                              const Icon(Icons.radar, color: neonBlue, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${perf['wickets']}/${perf['runsConceded']} (${perf['ballsBowled'] ~/ 6}.${perf['ballsBowled'] % 6} Ov)',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ] else ...[
                              Icon(Icons.radar, color: Colors.white.withOpacity(0.2), size: 14),
                              const SizedBox(width: 4),
                              const Text(
                                'DNB',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

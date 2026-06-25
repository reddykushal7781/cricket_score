import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../services/database_helper.dart';
import '../services/api_service.dart';
import '../providers/match_provider.dart';
import '../services/auth_service.dart';

class PreviousMatchesTab extends StatefulWidget {
  const PreviousMatchesTab({super.key});

  @override
  State<PreviousMatchesTab> createState() => _PreviousMatchesTabState();
}

class _PreviousMatchesTabState extends State<PreviousMatchesTab> {
  List<CricketMatch> _matches = [];
  bool _isLoading = true;
  MatchProvider? _matchProvider;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newProvider = Provider.of<MatchProvider>(context);
    if (_matchProvider != newProvider) {
      _matchProvider?.removeListener(_loadMatchesSilent);
      _matchProvider = newProvider;
      _matchProvider?.addListener(_loadMatchesSilent);
    }
  }

  @override
  void dispose() {
    _matchProvider?.removeListener(_loadMatchesSilent);
    super.dispose();
  }

  Future<void> _loadMatchesSilent() async {
    await _fetchAndMergeMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    await _fetchAndMergeMatches();
  }

  Future<void> _fetchAndMergeMatches() async {
    final List<CricketMatch> temp = [];
    final authService = AuthService();
    final username = await authService.getUsername() ?? 'kushal7781';

    // 1. Fetch matches for the logged-in player from the API
    try {
      final apiMatches = await ApiService.getPlayerMatches(username);
      for (var item in apiMatches) {
        temp.add(CricketMatch(
          id: item['matchId'] as int? ?? item['id'] as int?,
          teamAName: item['teamAName'] as String? ?? item['team_a_name'] as String? ?? 'Team A',
          teamBName: item['teamBName'] as String? ?? item['team_b_name'] as String? ?? 'Team B',
          oversCount: item['oversCount'] as int? ?? item['overs_count'] as int? ?? 5,
          playersPerTeam: item['playersPerTeam'] as int? ?? item['players_per_team'] as int? ?? 11,
          teamAScore: item['teamAScore'] as int? ?? item['team_a_score'] as int? ?? 0,
          teamBScore: item['teamBScore'] as int? ?? item['team_b_score'] as int? ?? 0,
          teamAWickets: item['teamAWickets'] as int? ?? item['team_a_wickets'] as int? ?? 0,
          teamBWickets: item['teamBWickets'] as int? ?? item['team_b_wickets'] as int? ?? 0,
          teamABalls: item['teamABalls'] as int? ?? item['team_a_balls'] as int? ?? (item['oversCount'] != null ? (item['oversCount'] as int) * 6 : 0),
          teamBBalls: item['teamBBalls'] as int? ?? item['team_b_balls'] as int? ?? (item['oversCount'] != null ? (item['oversCount'] as int) * 6 : 0),
          winner: item['winner'] as String?,
          date: item['date'] as String? ?? '',
          isCompleted: true,
        ));
      }
    } catch (e) {
      debugPrint('Error loading matches from API for player $username: $e');
    }

    // 2. Fetch matches from local SQLite and merge
    try {
      final localMatches = await DatabaseHelper.instance.getCompletedMatches();
      for (var match in localMatches) {
        bool exists = temp.any((m) =>
            (m.id != null && m.id == match.id) ||
            (m.date == match.date && m.teamAName == match.teamAName && m.teamBName == match.teamBName));
        if (!exists) {
          temp.add(match);
        }
      }
    } catch (e) {
      debugPrint('Error loading local completed matches: $e');
    }

    // 3. Sort all matches by date descending
    temp.sort((a, b) => b.date.compareTo(a.date));

    if (mounted) {
      setState(() {
        _matches = temp;
        _isLoading = false;
      });
    }
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

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: neonGreen))
          : RefreshIndicator(
              onRefresh: _loadMatches,
              color: neonGreen,
              child: _matches.isEmpty
                  ? const Center(
                      child: Text(
                        'No matches played yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _matches.length,
                      itemBuilder: (context, index) {
                        final match = _matches[index];
                        String overA = "${match.teamABalls ~/ 6}.${match.teamABalls % 6}";
                        String overB = "${match.teamBBalls ~/ 6}.${match.teamBBalls % 6}";
                        
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
                                    const Icon(
                                      Icons.bar_chart,
                                      color: neonGreen,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Team A Score line
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      match.teamAName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${match.teamAScore}/${match.teamAWickets} ($overA Ov)',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Team B Score line
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      match.teamBName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${match.teamBScore}/${match.teamBWickets} ($overB Ov)',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.white10, height: 24),
                                // Result Banner
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    match.winner == 'Tie'
                                        ? 'Match Tied'
                                        : '${match.winner} won the match',
                                    style: const TextStyle(
                                      color: neonGreen,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

// Inner widget for Scorecard Modal details
class MatchScorecardModal extends StatefulWidget {
  final CricketMatch match;
  final ScrollController scrollController;

  const MatchScorecardModal({required this.match, required this.scrollController});

  @override
  State<MatchScorecardModal> createState() => MatchScorecardModalState();
}

class MatchScorecardModalState extends State<MatchScorecardModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  // Data lists Compiled
  List<Map<String, dynamic>> _battingA = [];
  List<Map<String, dynamic>> _battingB = [];
  List<Map<String, dynamic>> _bowlingA = [];
  List<Map<String, dynamic>> _bowlingB = [];

  int _extrasA = 0;
  int _extrasB = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _compileScorecardData();
  }

  Map<String, dynamic>? getTopBatsman() {
    Map<String, dynamic>? top;
    for (var b in [..._battingA, ..._battingB]) {
      if (top == null || b['runs'] > top['runs']) {
        top = b;
      }
    }
    return top;
  }

  Map<String, dynamic>? getTopBowler() {
    Map<String, dynamic>? top;
    for (var b in [..._bowlingA, ..._bowlingB]) {
      if (top == null || b['wickets'] > top['wickets']) {
        top = b;
      } else if (b['wickets'] == top['wickets'] && b['runs'] < top['runs']) {
        top = b;
      }
    }
    return top;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _compileScorecardData() async {
    try {
      if (widget.match.id != null) {
        final apiDetails = await ApiService.getMatchDetails(widget.match.id!);
        if (apiDetails['success'] == true && apiDetails['match'] != null) {
          final matchData = apiDetails['match'] as Map<String, dynamic>;
          final inningsList = matchData['innings'] as List<dynamic>? ?? [];
          
          List<Map<String, dynamic>> tempBattingA = [];
          List<Map<String, dynamic>> tempBattingB = [];
          List<Map<String, dynamic>> tempBowlingA = [];
          List<Map<String, dynamic>> tempBowlingB = [];
          int tempExtrasA = 0;
          int tempExtrasB = 0;
          
          for (var inn in inningsList) {
            final innIndex = inn['inningsIndex'] as int? ?? 0;
            final extrasMap = inn['extras'] as Map<String, dynamic>? ?? {};
            final extrasTotal = extrasMap['total'] as int? ?? 0;
            
            final battingCard = inn['battingScorecard'] as List<dynamic>? ?? [];
            final bowlingCard = inn['bowlingScorecard'] as List<dynamic>? ?? [];
            
            List<Map<String, dynamic>> mappedBatting = battingCard.map((b) => {
              'name': b['name'] as String? ?? 'Player',
              'runs': b['runs'] as int? ?? 0,
              'balls': b['ballsFaced'] as int? ?? 0,
              'fours': b['fours'] as int? ?? 0,
              'sixes': b['sixes'] as int? ?? 0,
              'out': b['isOut'] as bool? ?? false,
              'how_out': b['isOut'] == true
                  ? (b['dismissalType'] == 'run out' ? 'Run Out' : 'c. ${b['dismissedBy'] ?? "Fielder"}')
                  : 'Not Out',
            }).toList();
            
            List<Map<String, dynamic>> mappedBowling = bowlingCard.map((bo) => {
              'name': bo['name'] as String? ?? 'Player',
              'balls': bo['ballsBowled'] as int? ?? 0,
              'runs': bo['runsConceded'] as int? ?? 0,
              'wickets': bo['wickets'] as int? ?? 0,
            }).toList();
            
            if (innIndex == 0) {
              tempBattingA = mappedBatting;
              tempBowlingB = mappedBowling;
              tempExtrasA = extrasTotal;
            } else {
              tempBattingB = mappedBatting;
              tempBowlingA = mappedBowling;
              tempExtrasB = extrasTotal;
            }
          }
          
          if (mounted) {
            setState(() {
              _battingA = tempBattingA;
              _battingB = tempBattingB;
              _bowlingA = tempBowlingA;
              _bowlingB = tempBowlingB;
              _extrasA = tempExtrasA;
              _extrasB = tempExtrasB;
              _isLoading = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching match details from API, falling back to local compilation: $e');
    }

    try {
      final events = await DatabaseHelper.instance.getBallEventsForMatch(widget.match.id!);

      final Map<int, Map<String, dynamic>> batsStatsA = {};
      final Map<int, Map<String, dynamic>> batsStatsB = {};
      final Map<int, Map<String, dynamic>> bowlStatsA = {};
      final Map<int, Map<String, dynamic>> bowlStatsB = {};

      for (var event in events) {
        bool isLegal = (event.extraType != 'wide' && event.extraType != 'noball');
        
        // Extras calculations
        if (event.inningsIndex == 0) {
          if (event.extraType == 'wide' || event.extraType == 'noball') {
            _extrasA += 1;
          } else if (event.extraType == 'bye' || event.extraType == 'legbye') {
            _extrasA += event.runs;
          }
        } else {
          if (event.extraType == 'wide' || event.extraType == 'noball') {
            _extrasB += 1;
          } else if (event.extraType == 'bye' || event.extraType == 'legbye') {
            _extrasB += event.runs;
          }
        }

        // Striker stats
        final batsStats = event.inningsIndex == 0 ? batsStatsA : batsStatsB;
        if (!batsStats.containsKey(event.batsmanId)) {
          batsStats[event.batsmanId] = {
            'name': event.batsmanName,
            'runs': 0,
            'balls': 0,
            'fours': 0,
            'sixes': 0,
            'out': false,
            'how_out': '',
          };
        }
        final bStat = batsStats[event.batsmanId]!;
        if (event.extraType != 'wide') {
          bStat['balls'] = (bStat['balls'] as int) + 1;
        }
        if (event.extraType == 'none' || event.extraType == 'noball') {
          bStat['runs'] = (bStat['runs'] as int) + event.runs;
          if (event.runs == 4) bStat['fours'] = (bStat['fours'] as int) + 1;
          if (event.runs == 6) bStat['sixes'] = (bStat['sixes'] as int) + 1;
        }

        // Bowler stats
        final bowlStats = event.inningsIndex == 0 ? bowlStatsB : bowlStatsA; // Opposing team bowlers
        if (!bowlStats.containsKey(event.bowlerId)) {
          bowlStats[event.bowlerId] = {
            'name': event.bowlerName,
            'balls': 0,
            'runs': 0,
            'wickets': 0,
          };
        }
        final boStat = bowlStats[event.bowlerId]!;
        if (isLegal) {
          boStat['balls'] = (boStat['balls'] as int) + 1;
        }
        int bowlerRuns = event.runs;
        if (event.extraType == 'wide' || event.extraType == 'noball') {
          bowlerRuns += 1;
        }
        if (event.extraType != 'bye' && event.extraType != 'legbye') {
          boStat['runs'] = (boStat['runs'] as int) + bowlerRuns;
        }

        // Wickets updates on batsman cards
        if (event.isWicket) {
          final disId = event.dismissedPlayerId ?? event.batsmanId;
          final disStats = event.inningsIndex == 0 ? batsStatsA : batsStatsB;
          if (disStats.containsKey(disId)) {
            disStats[disId]!['out'] = true;
            disStats[disId]!['how_out'] = event.wicketType == 'run out' 
                ? 'Run Out' 
                : 'c. ${event.fielderName ?? "Fielder"} b. ${event.bowlerName}';
          }
          if (event.wicketType != 'run out') {
            boStat['wickets'] = (boStat['wickets'] as int) + 1;
          }
        }
      }

      if (mounted) {
        setState(() {
          _battingA = batsStatsA.values.toList();
          _battingB = batsStatsB.values.toList();
          _bowlingA = bowlStatsA.values.toList();
          _bowlingB = bowlStatsB.values.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error compiling local scorecard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const neonGreen = Color(0xFF39FF14);

    return Scaffold(
      backgroundColor: const Color(0xFF1E222B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E222B),
        elevation: 0,
        title: const Text('Detailed Scorecard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: neonGreen,
          labelColor: neonGreen,
          unselectedLabelColor: Colors.grey,
          tabs: [
            const Tab(text: 'SUMMARY'),
            Tab(text: widget.match.teamAName),
            Tab(text: widget.match.teamBName),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: neonGreen))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildInningsScorecard(widget.match.teamAName, _battingA, _bowlingB, _extrasA, widget.match.teamAScore, widget.match.teamAWickets, widget.match.teamABalls),
                _buildInningsScorecard(widget.match.teamBName, _battingB, _bowlingA, _extrasB, widget.match.teamBScore, widget.match.teamBWickets, widget.match.teamBBalls),
              ],
            ),
    );
  }

  Widget _buildSummaryTab() {
    const neonGreen = Color(0xFF39FF14);
    const neonBlue = Color(0xFF00E5FF);

    final topBatsman = getTopBatsman();
    final topBowler = getTopBowler();

    final resultText = widget.match.winner == 'Tie'
        ? 'Match Tied'
        : '${widget.match.winner} won the match';

    final overAStr = "${widget.match.teamABalls ~/ 6}.${widget.match.teamABalls % 6}";
    final overBStr = "${widget.match.teamBBalls ~/ 6}.${widget.match.teamBBalls % 6}";

    final double rrA = widget.match.teamABalls == 0 ? 0.0 : (widget.match.teamAScore / (widget.match.teamABalls / 6.0));
    final double rrB = widget.match.teamBBalls == 0 ? 0.0 : (widget.match.teamBScore / (widget.match.teamBBalls / 6.0));

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Result Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [neonGreen.withOpacity(0.15), Colors.black26],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: neonGreen.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.emoji_events, color: neonGreen, size: 40),
              const SizedBox(height: 12),
              Text(
                resultText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Played on ${widget.match.date}',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Team Scores Comparison Card
        Card(
          color: const Color(0xFF161A22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MATCH SCORECARD SUMMARY',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const Divider(color: Colors.white10, height: 24),
                
                // Team A Line
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.match.teamAName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.match.teamAScore}/${widget.match.teamAWickets}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$overAStr Overs (RR: ${rrA.toStringAsFixed(1)})',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Team B Line
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.match.teamBName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.match.teamBScore}/${widget.match.teamBWickets}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$overBStr Overs (RR: ${rrB.toStringAsFixed(1)})',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Key Performers Title
        const Text(
          'KEY PERFORMERS',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),

        // Side-by-side Top Batsman & Top Bowler
        Row(
          children: [
            // Top Batsman Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161A22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOP BATSMAN',
                          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                        ),
                        Icon(Icons.sports_cricket, color: Colors.amber.withOpacity(0.8), size: 16),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      topBatsman != null ? topBatsman['name'] : 'N/A',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (topBatsman != null) ...[
                      Text(
                        '${topBatsman['runs']} Runs',
                        style: const TextStyle(color: neonGreen, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${topBatsman['balls']} Balls faced',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                      ),
                      Text(
                        'SR: ${(topBatsman['balls'] == 0 ? 0.0 : (topBatsman['runs'] / topBatsman['balls']) * 100).toStringAsFixed(1)}',
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                      ),
                    ] else
                      Text(
                        'No batting data',
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Top Bowler Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161A22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOP BOWLER',
                          style: TextStyle(color: neonBlue, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                        ),
                        Icon(Icons.star, color: neonBlue.withOpacity(0.8), size: 16),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      topBowler != null ? topBowler['name'] : 'N/A',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (topBowler != null) ...[
                      Text(
                        '${topBowler['wickets']} Wickets',
                        style: const TextStyle(color: neonBlue, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${topBowler['runs']} Runs conceded',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                      ),
                      Text(
                        '${(topBowler['balls'] ~/ 6)}.${(topBowler['balls'] % 6)} Overs',
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                      ),
                    ] else
                      Text(
                        'No bowling data',
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildInningsScorecard(
    String teamName,
    List<Map<String, dynamic>> batting,
    List<Map<String, dynamic>> bowling,
    int extras,
    int totalScore,
    int wickets,
    int ballsBowled,
  ) {
    String oversStr = "${ballsBowled ~/ 6}.${ballsBowled % 6}";
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Summary header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              teamName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              '$totalScore/$wickets ($oversStr Ov)',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF39FF14)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Batting header table
        const Text('BATTING', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13, letterSpacing: 1)),
        const Divider(color: Colors.white24),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: batting.length,
          itemBuilder: (context, i) {
            final card = batting[i];
            int runs = card['runs'];
            int balls = card['balls'];
            double sr = balls == 0 ? 0.0 : (runs / balls) * 100;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          card['name'],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                      Text(
                        '$runs ($balls)',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 50,
                        child: Text(
                          'SR: ${sr.toStringAsFixed(1)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  if (card['out'] == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        card['how_out'],
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'not out',
                        style: TextStyle(color: const Color(0xFF39FF14).withOpacity(0.6), fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                  const Divider(color: Colors.white10),
                ],
              ),
            );
          },
        ),
        // Extras
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Extras', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text('$extras', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Bowling table
        const Text('BOWLING', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13, letterSpacing: 1)),
        const Divider(color: Colors.white24),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bowling.length,
          itemBuilder: (context, i) {
            final card = bowling[i];
            int bBowled = card['balls'];
            int runs = card['runs'];
            int wkts = card['wickets'];
            String ov = "${bBowled ~/ 6}.${bBowled % 6}";
            double econ = bBowled == 0 ? 0.0 : (runs / (bBowled / 6.0));
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      card['name'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '$ov Ov - $runs R - $wkts W',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 60,
                    child: Text(
                      'Econ: ${econ.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

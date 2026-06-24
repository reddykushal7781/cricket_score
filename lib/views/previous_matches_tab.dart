import 'package:flutter/material.dart';
import '../models/match.dart';
import '../services/database_helper.dart';

class PreviousMatchesTab extends StatefulWidget {
  const PreviousMatchesTab({super.key});

  @override
  State<PreviousMatchesTab> createState() => _PreviousMatchesTabState();
}

class _PreviousMatchesTabState extends State<PreviousMatchesTab> {
  List<CricketMatch> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    final list = await DatabaseHelper.instance.getCompletedMatches();
    if (mounted) {
      setState(() {
        _matches = list;
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
            return _MatchScorecardModal(match: match, scrollController: scrollController);
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
class _MatchScorecardModal extends StatefulWidget {
  final CricketMatch match;
  final ScrollController scrollController;

  const _MatchScorecardModal({required this.match, required this.scrollController});

  @override
  State<_MatchScorecardModal> createState() => _MatchScorecardModalState();
}

class _MatchScorecardModalState extends State<_MatchScorecardModal> with SingleTickerProviderStateMixin {
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
    _tabController = TabController(length: 2, vsync: this);
    _compileScorecardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _compileScorecardData() async {
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
                _buildInningsScorecard(widget.match.teamAName, _battingA, _bowlingB, _extrasA, widget.match.teamAScore, widget.match.teamAWickets, widget.match.teamABalls),
                _buildInningsScorecard(widget.match.teamBName, _battingB, _bowlingA, _extrasB, widget.match.teamBScore, widget.match.teamBWickets, widget.match.teamBBalls),
              ],
            ),
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

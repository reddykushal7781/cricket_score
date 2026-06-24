import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/database_helper.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  List<Player> _players = [];
  bool _isLoading = true;
  String _sortBy = 'runs_scored'; // 'runs_scored', 'wickets_taken', 'highest_score', 'catches'

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final allPlayers = await DatabaseHelper.instance.getAllPlayers();
    
    // Sort logic
    _sortPlayerList(allPlayers);
    
    if (mounted) {
      setState(() {
        _players = allPlayers;
        _isLoading = false;
      });
    }
  }

  void _sortPlayerList(List<Player> list) {
    if (_sortBy == 'runs_scored') {
      list.sort((a, b) => b.runsScored.compareTo(a.runsScored));
    } else if (_sortBy == 'wickets_taken') {
      list.sort((a, b) => b.wicketsTaken.compareTo(a.wicketsTaken));
    } else if (_sortBy == 'highest_score') {
      list.sort((a, b) => b.highestScore.compareTo(a.highestScore));
    } else if (_sortBy == 'catches') {
      list.sort((a, b) => b.catches.compareTo(a.catches));
    }
  }

  @override
  Widget build(BuildContext context) {
    const neonGreen = Color(0xFF39FF14);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: neonGreen))
          : Column(
              children: [
                // Filter bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: const Color(0xFF1E222B),
                  child: Row(
                    children: [
                      const Text(
                        'Sort by:',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13161C),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: const Color(0xFF1E222B),
                              value: _sortBy,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              icon: const Icon(Icons.arrow_drop_down, color: neonGreen),
                              items: const [
                                DropdownMenuItem(value: 'runs_scored', child: Text('Runs Scored')),
                                DropdownMenuItem(value: 'wickets_taken', child: Text('Wickets Taken')),
                                DropdownMenuItem(value: 'highest_score', child: Text('Highest Score')),
                                DropdownMenuItem(value: 'catches', child: Text('Catches Taken')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _sortBy = val;
                                    _sortPlayerList(_players);
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: neonGreen),
                        onPressed: _loadStats,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _players.isEmpty
                      ? const Center(
                          child: Text(
                            'No player statistics recorded yet.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _players.length,
                          itemBuilder: (context, index) {
                            final player = _players[index];
                            return Container(
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
                                        player.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: neonGreen.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'M: ${player.matchesPlayed}',
                                          style: const TextStyle(
                                            color: neonGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Stats Grid
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildStatItem('Runs', '${player.runsScored}'),
                                      _buildStatItem('Wkts', '${player.wicketsTaken}'),
                                      _buildStatItem('S/R', player.battingStrikeRate.toStringAsFixed(1)),
                                      _buildStatItem('Econ', player.bowlingEconomy.toStringAsFixed(2)),
                                    ],
                                  ),
                                  const Divider(color: Colors.white10, height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildStatItem('High Score', '${player.highestScore}'),
                                      _buildStatItem('Catches', '${player.catches}'),
                                      _buildStatItem('Avg (Bat)', player.battingAverage.toStringAsFixed(1)),
                                      _buildStatItem('Avg (Bowl)', player.bowlingAverage.toStringAsFixed(1)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value == 'NaN' || value == 'Infinity' ? '-' : value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

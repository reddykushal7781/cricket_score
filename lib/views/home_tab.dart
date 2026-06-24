import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../services/database_helper.dart';
import '../providers/match_provider.dart';
import 'scoring_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _teamAController = TextEditingController(text: 'Team A');
  final _teamBController = TextEditingController(text: 'Team B');
  final _oversController = TextEditingController(text: '5');
  final _playersCountController = TextEditingController(text: '11');

  List<Player> _teamAPlayers = [];
  List<Player> _teamBPlayers = [];

  bool _hasActiveMatch = false;

  @override
  void initState() {
    super.initState();
    _checkActiveMatch();
  }

  Future<void> _checkActiveMatch() async {
    final active = await DatabaseHelper.instance.getActiveMatch();
    if (mounted) {
      setState(() {
        _hasActiveMatch = active != null;
      });
    }
  }

  Future<void> _resumeMatch() async {
    final provider = Provider.of<MatchProvider>(context, listen: false);
    final success = await provider.tryResumeActiveMatch();
    if (success && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ScoringPage()),
      ).then((_) => _checkActiveMatch());
    }
  }

  Future<void> _startMatch() async {
    int overs = int.tryParse(_oversController.text) ?? 5;
    int playersCount = int.tryParse(_playersCountController.text) ?? 11;

    if (_teamAPlayers.length < playersCount || _teamBPlayers.length < playersCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add exactly $playersCount players to both teams.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final match = CricketMatch(
      teamAName: _teamAController.text.trim(),
      teamBName: _teamBController.text.trim(),
      oversCount: overs,
      playersPerTeam: playersCount,
      date: DateTime.now().toString().split(' ')[0],
    );

    final provider = Provider.of<MatchProvider>(context, listen: false);
    await provider.startMatch(
      match: match,
      teamA: _teamAPlayers,
      teamB: _teamBPlayers,
    );

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ScoringPage()),
      ).then((_) => _checkActiveMatch());
    }
  }

  void _addPlayerToTeam(Player player, int teamIndex) {
    setState(() {
      if (teamIndex == 0) {
        if (!_teamAPlayers.any((p) => p.name.toLowerCase() == player.name.toLowerCase())) {
          _teamAPlayers.add(player);
        }
      } else {
        if (!_teamBPlayers.any((p) => p.name.toLowerCase() == player.name.toLowerCase())) {
          _teamBPlayers.add(player);
        }
      }
    });
  }

  void _generateQuickTeams() async {
    int playersCount = int.tryParse(_playersCountController.text) ?? 11;
    String teamAName = _teamAController.text.trim();
    String teamBName = _teamBController.text.trim();

    setState(() {
      _teamAPlayers.clear();
      _teamBPlayers.clear();
    });

    final List<Player> tempA = [];
    final List<Player> tempB = [];

    for (int i = 1; i <= playersCount; i++) {
      final pA = await DatabaseHelper.instance.getOrCreatePlayer('$teamAName Player $i');
      tempA.add(pA);
      final pB = await DatabaseHelper.instance.getOrCreatePlayer('$teamBName Player $i');
      tempB.add(pB);
    }

    setState(() {
      _teamAPlayers = tempA;
      _teamBPlayers = tempB;
    });
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _oversController.dispose();
    _playersCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const neonGreen = Color(0xFF39FF14);
    int playersCount = int.tryParse(_playersCountController.text) ?? 11;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resume active match banner
            if (_hasActiveMatch) ...[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [neonGreen.withOpacity(0.2), Colors.black26]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: neonGreen.withOpacity(0.4)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.sports_cricket, color: neonGreen, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Match Found',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'You have an unfinished match in progress.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _resumeMatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('RESUME', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Match details card
            Card(
              color: const Color(0xFF1E222B),
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
                      'MATCH DETAILS',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    // Teams text inputs
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _teamAController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Team A Name',
                              labelStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                              filled: true,
                              fillColor: const Color(0xFF13161C),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('VS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _teamBController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Team B Name',
                              labelStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                              filled: true,
                              fillColor: const Color(0xFF13161C),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Overs & Players count row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _oversController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Total Overs',
                              labelStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                              filled: true,
                              fillColor: const Color(0xFF13161C),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _playersCountController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              setState(() {
                                // Redraw player lists requirements
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Players / Team',
                              labelStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                              filled: true,
                              fillColor: const Color(0xFF13161C),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Team A Players Section
            _buildTeamPlayersCard(0, _teamAController.text, _teamAPlayers, playersCount),
            const SizedBox(height: 20),

            // Team B Players Section
            _buildTeamPlayersCard(1, _teamBController.text, _teamBPlayers, playersCount),
            const SizedBox(height: 24),

            // Actions Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _generateQuickTeams,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: neonGreen,
                      side: const BorderSide(color: neonGreen),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('AUTO FILL PLAYERS', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startMatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neonGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('START MATCH', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamPlayersCard(int teamIndex, String teamName, List<Player> list, int requiredCount) {
    const neonGreen = Color(0xFF39FF14);
    
    return Card(
      color: const Color(0xFF1E222B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${teamName.toUpperCase()} ROSTER',
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                ),
                Text(
                  '${list.length}/$requiredCount',
                  style: TextStyle(
                    color: list.length == requiredCount ? neonGreen : Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 24),
            // Autocomplete Field
            LayoutBuilder(
              builder: (context, constraints) {
                return Autocomplete<Player>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Player>.empty();
                    }
                    return await DatabaseHelper.instance.searchPlayers(textEditingValue.text);
                  },
                  displayStringForOption: (Player option) => option.name,
                  onSelected: (Player selection) {
                    _addPlayerToTeam(selection, teamIndex);
                  },
                  fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: textController,
                      focusNode: focusNode,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search or type player name',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: const Color(0xFF13161C),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add, color: neonGreen),
                          onPressed: () async {
                            final name = textController.text.trim();
                            if (name.isNotEmpty) {
                              final player = await DatabaseHelper.instance.getOrCreatePlayer(name);
                              _addPlayerToTeam(player, teamIndex);
                              textController.clear();
                            }
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onFieldSubmitted: (val) async {
                        final name = val.trim();
                        if (name.isNotEmpty) {
                          final player = await DatabaseHelper.instance.getOrCreatePlayer(name);
                          _addPlayerToTeam(player, teamIndex);
                          textController.clear();
                        }
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: const Color(0xFF1E222B),
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: constraints.maxWidth,
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                title: Text(option.name, style: const TextStyle(color: Colors.white)),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            ),
            const SizedBox(height: 12),
            // Chips Wrap
            list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'No players added yet.',
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: list.map((player) {
                      return Chip(
                        backgroundColor: const Color(0xFF13161C),
                        labelStyle: const TextStyle(color: Colors.white),
                        label: Text(player.name),
                        deleteIconColor: Colors.redAccent,
                        onDeleted: () {
                          setState(() {
                            list.removeWhere((p) => p.id == player.id);
                          });
                        },
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

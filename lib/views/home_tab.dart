import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../services/database_helper.dart';
import '../providers/match_provider.dart';
import 'scoring_page.dart';
import '../services/mock_stats_data.dart';
import '../services/api_service.dart';

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
  
  final _teamASearchController = TextEditingController();
  final _teamBSearchController = TextEditingController();
  final _doubleSidedSearchController = TextEditingController();

  final _teamAFocusNode = FocusNode();
  final _teamBFocusNode = FocusNode();
  final _doubleSidedFocusNode = FocusNode();

  List<Player> _teamAPlayers = [];
  List<Player> _teamBPlayers = [];

  bool _hasActiveMatch = false;
  int? _activeMatchId;
  bool _hasDoubleSidedPlayer = false;
  Player? _doubleSidedPlayer;

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
        _activeMatchId = active?.id;
      });
    }
  }

  Future<void> _resumeMatch() async {
    final provider = Provider.of<MatchProvider>(context, listen: false);
    final success = await provider.tryResumeActiveMatch();
    if (success && mounted) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(builder: (_) => const ScoringPage()),
          )
          .then((_) => _checkActiveMatch());
    }
  }

  Future<void> _confirmDeleteOngoingMatch() async {
    if (_activeMatchId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E222B),
        title: const Text(
          'Delete Ongoing Match?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this ongoing match? This will permanently erase the match score and ball-by-ball history from this device.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await DatabaseHelper.instance.deleteMatch(_activeMatchId!);
      
      final provider = Provider.of<MatchProvider>(context, listen: false);
      provider.exitMatch();

      setState(() {
        _hasActiveMatch = false;
        _activeMatchId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ongoing match deleted successfully.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<List<Player>> _getSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    try {
      final results = await ApiService.searchPlayers(query);
      return results.map((item) => Player(id: item['id'] as int?, name: item['name'] as String)).toList();
    } catch (e) {
      debugPrint('Error searching players from API, falling back to local DB/mock: $e');
      final dbPlayers = await DatabaseHelper.instance.getAllPlayers();
      final mockPlayersList = MockStatsData.mockPlayers.map((up) => Player(name: up.name)).toList();
      final Map<String, Player> uniqueSuggestions = {};
      for (var p in mockPlayersList) {
        uniqueSuggestions[p.name.toLowerCase()] = p;
      }
      for (var p in dbPlayers) {
        uniqueSuggestions[p.name.toLowerCase()] = p;
      }
      final filtered = uniqueSuggestions.values.where((p) {
        return p.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      return filtered;
    }
  }

  Future<Player> _processTypedName(String typedName) async {
    final cleanedName = typedName.trim();
    if (cleanedName.isEmpty) {
      return Player(name: '');
    }
    final suggestions = await _getSuggestions(cleanedName);
    final exactMatch = suggestions.firstWhere(
      (p) => p.name.toLowerCase() == cleanedName.toLowerCase(),
      orElse: () => Player(name: ''),
    );
    if (exactMatch.name.isNotEmpty) {
      return exactMatch;
    }
    String formattedName = cleanedName;
    if (!formattedName.toLowerCase().endsWith('(unknown)')) {
      formattedName = '$formattedName(unknown)';
    }
    return Player(name: formattedName);
  }

  Future<void> _startMatch() async {
    int overs = int.tryParse(_oversController.text) ?? 5;
    int playersCount = int.tryParse(_playersCountController.text) ?? 11;

    if (_teamAPlayers.length < playersCount ||
        _teamBPlayers.length < playersCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please add exactly $playersCount players to both teams.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Ensure all players are registered in local SQLite and have IDs before starting
    final List<Player> savedTeamA = [];
    for (var player in _teamAPlayers) {
      if (player.id == null) {
        final dbPlayer = await DatabaseHelper.instance.getOrCreatePlayer(player.name);
        savedTeamA.add(dbPlayer);
      } else {
        savedTeamA.add(player);
      }
    }

    final List<Player> savedTeamB = [];
    for (var player in _teamBPlayers) {
      if (player.id == null) {
        final dbPlayer = await DatabaseHelper.instance.getOrCreatePlayer(player.name);
        savedTeamB.add(dbPlayer);
      } else {
        savedTeamB.add(player);
      }
    }

    // Update local roster lists and double-sided player reference
    setState(() {
      _teamAPlayers = savedTeamA;
      _teamBPlayers = savedTeamB;
      if (_doubleSidedPlayer != null) {
        _doubleSidedPlayer = savedTeamA.firstWhere(
          (p) => p.name.toLowerCase() == _doubleSidedPlayer!.name.toLowerCase(),
          orElse: () => _doubleSidedPlayer!,
        );
      }
    });

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
      teamA: savedTeamA,
      teamB: savedTeamB,
    );

    // Reset home tab selections and controllers to clean state
    setState(() {
      _teamAPlayers = [];
      _teamBPlayers = [];
      _teamAController.text = 'Team A';
      _teamBController.text = 'Team B';
      _oversController.text = '5';
      _playersCountController.text = '11';
      _doubleSidedPlayer = null;
      _hasDoubleSidedPlayer = false;
      _teamASearchController.clear();
      _teamBSearchController.clear();
      _doubleSidedSearchController.clear();
    });

    if (mounted) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(builder: (_) => const ScoringPage()),
          )
          .then((_) => _checkActiveMatch());
    }
  }

  void _addPlayerToTeam(Player player, int teamIndex) {
    final opposingTeamList = teamIndex == 0 ? _teamBPlayers : _teamAPlayers;
    final opposingTeamName = teamIndex == 0 ? _teamBController.text.trim() : _teamAController.text.trim();
    if (opposingTeamList.any((p) => p.name.toLowerCase() == player.name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${player.name} is already added to $opposingTeamName!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      if (teamIndex == 0) {
        if (!_teamAPlayers
            .any((p) => p.name.toLowerCase() == player.name.toLowerCase())) {
          _teamAPlayers.add(player);
        }
      } else {
        if (!_teamBPlayers
            .any((p) => p.name.toLowerCase() == player.name.toLowerCase())) {
          _teamBPlayers.add(player);
        }
      }
    });
  }

  void _setDoubleSidedPlayer(Player player) {
    setState(() {
      if (_doubleSidedPlayer != null) {
        _teamAPlayers.removeWhere((p) =>
            p.name.toLowerCase() == _doubleSidedPlayer!.name.toLowerCase());
        _teamBPlayers.removeWhere((p) =>
            p.name.toLowerCase() == _doubleSidedPlayer!.name.toLowerCase());
      }

      _doubleSidedPlayer = player;
      _doubleSidedSearchController.text = player.name;

      if (!_teamAPlayers
          .any((p) => p.name.toLowerCase() == player.name.toLowerCase())) {
        _teamAPlayers.add(player);
      }
      if (!_teamBPlayers
          .any((p) => p.name.toLowerCase() == player.name.toLowerCase())) {
        _teamBPlayers.add(player);
      }
    });
  }


  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _oversController.dispose();
    _playersCountController.dispose();
    _teamASearchController.dispose();
    _teamBSearchController.dispose();
    _doubleSidedSearchController.dispose();
    _teamAFocusNode.dispose();
    _teamBFocusNode.dispose();
    _doubleSidedFocusNode.dispose();
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
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [neonGreen.withOpacity(0.2), Colors.black26]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: neonGreen.withOpacity(0.4)),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 44, 16),
                    child: Row(
                      children: [
                        const Icon(Icons.sports_cricket,
                            color: neonGreen, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Match Found',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('RESUME',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 20),
                      onPressed: _confirmDeleteOngoingMatch,
                      tooltip: 'Delete ongoing match',
                    ),
                  ),
                ],
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
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1),
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    // Teams text inputs
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _teamAController,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Team A Name',
                              labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.4)),
                              filled: true,
                              fillColor: const Color(0xFF13161C),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('VS',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _teamBController,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Team B Name',
                              labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.4)),
                              filled: true,
                              fillColor: const Color(0xFF13161C),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none),
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
                              labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.4)),
                              filled: true,
                              fillColor: const Color(0xFF13161C),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none),
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
                              labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.4)),
                              filled: true,
                              fillColor: const Color(0xFF13161C),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white10, height: 24),
                    SwitchListTile(
                      title: const Text(
                        'Double-Sided Player',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      subtitle: const Text(
                        'A player who plays for both teams (e.g. for odd numbers of players)',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      value: _hasDoubleSidedPlayer,
                      activeColor: neonGreen,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          _hasDoubleSidedPlayer = val;
                          if (!val && _doubleSidedPlayer != null) {
                            _teamAPlayers.removeWhere((p) =>
                                p.name.toLowerCase() ==
                                _doubleSidedPlayer!.name.toLowerCase());
                            _teamBPlayers.removeWhere((p) =>
                                p.name.toLowerCase() ==
                                _doubleSidedPlayer!.name.toLowerCase());
                            _doubleSidedPlayer = null;
                          }
                          if (!val) {
                            _doubleSidedSearchController.clear();
                          }
                        });
                      },
                    ),
                    if (_hasDoubleSidedPlayer) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'SELECT DOUBLE-SIDED PLAYER',
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      LayoutBuilder(builder: (context, constraints) {
                        return Autocomplete<Player>(
                          textEditingController: _doubleSidedSearchController,
                          focusNode: _doubleSidedFocusNode,
                          optionsBuilder:
                              (TextEditingValue textEditingValue) async {
                            return await _getSuggestions(textEditingValue.text);
                          },
                          displayStringForOption: (Player option) =>
                              option.name,
                          onSelected: (Player selection) {
                            _setDoubleSidedPlayer(selection);
                          },
                          fieldViewBuilder: (context, textController, focusNode,
                              onFieldSubmitted) {
                            return TextFormField(
                              controller: textController,
                              focusNode: focusNode,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText:
                                    'Search or type double-sided player...',
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.3)),
                                filled: true,
                                fillColor: const Color(0xFF13161C),
                                suffixIcon: IconButton(
                                  icon:
                                      const Icon(Icons.check, color: neonGreen),
                                  onPressed: () async {
                                    final name = textController.text.trim();
                                    if (name.isNotEmpty) {
                                      final player = await _processTypedName(name);
                                      _setDoubleSidedPlayer(player);
                                    }
                                  },
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                              ),
                              onFieldSubmitted: (val) async {
                                final name = val.trim();
                                if (name.isNotEmpty) {
                                  final player = await _processTypedName(name);
                                  _setDoubleSidedPlayer(player);
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
                                  constraints:
                                      const BoxConstraints(maxHeight: 200),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option.name,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Team A Players Section
            _buildTeamPlayersCard(
                0, _teamAController.text, _teamAPlayers, playersCount),
            const SizedBox(height: 20),

            // Team B Players Section
            _buildTeamPlayersCard(
                1, _teamBController.text, _teamBPlayers, playersCount),
            const SizedBox(height: 24),

            // Actions Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startMatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('START MATCH',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamPlayersCard(
      int teamIndex, String teamName, List<Player> list, int requiredCount) {
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
                  style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1),
                ),
                Text(
                  '${list.length}/$requiredCount',
                  style: TextStyle(
                    color:
                        list.length == requiredCount ? neonGreen : Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 24),
            LayoutBuilder(builder: (context, constraints) {
              final activeController = teamIndex == 0 ? _teamASearchController : _teamBSearchController;
              final activeFocusNode = teamIndex == 0 ? _teamAFocusNode : _teamBFocusNode;
              return Autocomplete<Player>(
                textEditingController: activeController,
                focusNode: activeFocusNode,
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  return await _getSuggestions(textEditingValue.text);
                },
                displayStringForOption: (Player option) => option.name,
                onSelected: (Player selection) {
                  _addPlayerToTeam(selection, teamIndex);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    activeController.clear();
                  });
                },
                fieldViewBuilder:
                    (context, textController, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: textController,
                    focusNode: focusNode,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search or type player name',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: const Color(0xFF13161C),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add, color: neonGreen),
                        onPressed: () async {
                          final name = textController.text.trim();
                          if (name.isNotEmpty) {
                            final player = await _processTypedName(name);
                            _addPlayerToTeam(player, teamIndex);
                            textController.clear();
                          }
                        },
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                    ),
                    onFieldSubmitted: (val) async {
                      final name = val.trim();
                      if (name.isNotEmpty) {
                        final player = await _processTypedName(name);
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
                              title: Text(option.name,
                                  style: const TextStyle(color: Colors.white)),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 12),
            // Chips Wrap
            list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'No players added yet.',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.3), fontSize: 13),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: list.map((player) {
                      final isDoubleSided = _hasDoubleSidedPlayer &&
                          _doubleSidedPlayer != null &&
                          player.name.toLowerCase() ==
                              _doubleSidedPlayer!.name.toLowerCase();

                      return Chip(
                        backgroundColor: isDoubleSided
                            ? neonGreen.withOpacity(0.15)
                            : const Color(0xFF13161C),
                        side: isDoubleSided
                            ? const BorderSide(color: neonGreen, width: 1)
                            : null,
                        labelStyle: const TextStyle(color: Colors.white),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(player.name),
                            if (isDoubleSided) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.sync,
                                  size: 12, color: neonGreen),
                            ]
                          ],
                        ),
                        deleteIconColor: Colors.redAccent,
                        onDeleted: () {
                          setState(() {
                            list.removeWhere((p) => p.name.toLowerCase() == player.name.toLowerCase());
                            if (isDoubleSided) {
                              _teamAPlayers
                                  .removeWhere((p) => p.name.toLowerCase() == player.name.toLowerCase());
                              _teamBPlayers
                                  .removeWhere((p) => p.name.toLowerCase() == player.name.toLowerCase());
                              _doubleSidedPlayer = null;
                              _doubleSidedSearchController.clear();
                              _hasDoubleSidedPlayer = false;
                            }
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

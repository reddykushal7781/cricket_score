import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../providers/match_provider.dart';
import 'celebration_page.dart';

class ScoringPage extends StatefulWidget {
  const ScoringPage({super.key});

  @override
  State<ScoringPage> createState() => _ScoringPageState();
}

class _ScoringPageState extends State<ScoringPage> {
  // Check if match over on didChangeDependencies and redirect
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<MatchProvider>(context);
    if (provider.isMatchOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CelebrationPage()),
        );
      });
    }
  }

  void _showPlayerSelectDialog({
    required String title,
    required List<Player> options,
    required Function(Player) onSelect,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E222B),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: options.isEmpty
                ? const Text('No players available.', style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final player = options[index];
                      return ListTile(
                        title: Text(player.name, style: const TextStyle(color: Colors.white)),
                        onTap: () {
                          onSelect(player);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  void _showWicketDialog() {
    final provider = Provider.of<MatchProvider>(context, listen: false);
    final striker = provider.striker;
    final nonStriker = provider.nonStriker;
    final bowlingTeam = provider.bowlingTeamList;

    if (striker == null) return;

    String selectedType = 'bowled';
    Player? selectedDismissed = striker;
    Player? selectedFielder;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool needsFielder = (selectedType == 'caught' || selectedType == 'run out' || selectedType == 'stumped');
            bool isRunOut = (selectedType == 'run out');

            return AlertDialog(
              backgroundColor: const Color(0xFF1E222B),
              title: const Text('Record Wicket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wicket type dropdown
                    const Text('Wicket Type', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13161C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: const Color(0xFF1E222B),
                          value: selectedType,
                          style: const TextStyle(color: Colors.white),
                          items: const [
                            DropdownMenuItem(value: 'bowled', child: Text('Bowled')),
                            DropdownMenuItem(value: 'caught', child: Text('Caught')),
                            DropdownMenuItem(value: 'lbw', child: Text('LBW')),
                            DropdownMenuItem(value: 'stumped', child: Text('Stumped')),
                            DropdownMenuItem(value: 'run out', child: Text('Run Out')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedType = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dismissed player (Only for run out)
                    if (isRunOut) ...[
                      const Text('Dismissed Batsman', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Radio<Player>(
                            value: striker,
                            groupValue: selectedDismissed,
                            activeColor: const Color(0xFF39FF14),
                            onChanged: (val) {
                              setDialogState(() => selectedDismissed = val);
                            },
                          ),
                          Text(striker.name, style: const TextStyle(color: Colors.white)),
                          if (nonStriker != null) ...[
                            Radio<Player>(
                              value: nonStriker,
                              groupValue: selectedDismissed,
                              activeColor: const Color(0xFF39FF14),
                              onChanged: (val) {
                                setDialogState(() => selectedDismissed = val);
                              },
                            ),
                            Text(nonStriker.name, style: const TextStyle(color: Colors.white)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Fielder Selection
                    if (needsFielder) ...[
                      const Text('Select Fielder', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF13161C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Player?>(
                            dropdownColor: const Color(0xFF1E222B),
                            value: selectedFielder,
                            hint: const Text('Select Fielder', style: TextStyle(color: Colors.grey)),
                            style: const TextStyle(color: Colors.white),
                            items: bowlingTeam.map((p) {
                              return DropdownMenuItem<Player?>(
                                value: p,
                                child: Text(p.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setDialogState(() {
                                selectedFielder = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    provider.recordBall(
                      runs: 0,
                      extraType: 'none',
                      isWicket: true,
                      wicketType: selectedType,
                      dismissedPlayerId: selectedDismissed?.id,
                      fielderId: selectedFielder?.id,
                      fielderName: selectedFielder?.name,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('CONFIRM', style: TextStyle(color: Color(0xFF39FF14), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExtrasDialog() {
    final provider = Provider.of<MatchProvider>(context, listen: false);
    String selectedExtra = 'wide';
    int runsScored = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E222B),
              title: const Text('Record Extras', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Extra Type', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13161C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF1E222B),
                        value: selectedExtra,
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'wide', child: Text('Wide')),
                          DropdownMenuItem(value: 'noball', child: Text('No Ball')),
                          DropdownMenuItem(value: 'bye', child: Text('Bye')),
                          DropdownMenuItem(value: 'legbye', child: Text('Leg Bye')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedExtra = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Additional Runs Run', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [0, 1, 2, 3, 4].map((r) {
                      return ChoiceChip(
                        label: Text('$r'),
                        selected: runsScored == r,
                        selectedColor: const Color(0xFF39FF14),
                        disabledColor: Colors.black,
                        labelStyle: runsScored == r ? const TextStyle(color: Colors.black) : const TextStyle(color: Colors.white),
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() => runsScored = r);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    provider.recordBall(
                      runs: runsScored,
                      extraType: selectedExtra,
                      isWicket: false,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('CONFIRM', style: TextStyle(color: Color(0xFF39FF14), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _exitMatchPrompt() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E222B),
          title: const Text('Exit Scorer?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to exit? Match progress will be saved in SQLite database.', style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final provider = Provider.of<MatchProvider>(context, listen: false);
                provider.exitMatch();
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Pop page to Dashboard
              },
              child: const Text('EXIT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const neonGreen = Color(0xFF39FF14);
    final provider = Provider.of<MatchProvider>(context);

    // Guard against null match
    if (provider.currentMatch == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1115),
        body: Center(child: CircularProgressIndicator(color: neonGreen)),
      );
    }

    final match = provider.currentMatch!;
    String teamBatting = provider.inningsIndex == 0 ? match.teamAName : match.teamBName;
    String teamBowling = provider.inningsIndex == 0 ? match.teamBName : match.teamAName;

    return WillPopScope(
      onWillPop: () async {
        _exitMatchPrompt();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1115),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E222B),
          title: Text(
            'Innings ${provider.inningsIndex + 1} - $teamBatting',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _exitMatchPrompt,
          ),
          actions: [
            // Undo button
            TextButton.icon(
              onPressed: provider.ballEvents.isEmpty ? null : () => provider.undoLastBall(),
              icon: const Icon(Icons.undo, color: neonGreen, size: 18),
              label: const Text(
                'UNDO',
                style: TextStyle(color: neonGreen, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total score board
            Container(
              color: const Color(0xFF13161C),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$teamBatting BATTING',
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${provider.totalScore}/${provider.wickets}',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${provider.overString} Ov)',
                                style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Run Rate (CRR)',
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            provider.runRate.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: neonGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Innings 2 Target Information
                  if (provider.inningsIndex == 1) ...[
                    const Divider(color: Colors.white10, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Target: ${provider.targetScore}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Need ${provider.targetScore - provider.totalScore} runs in ${((match.oversCount * 6) - provider.ballsBowled)} balls',
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'RRR: ${provider.requiredRunRate.toStringAsFixed(2)}',
                          style: const TextStyle(color: neonGreen, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],

                  // Extras display
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Extras: ${provider.extraRuns} (W: ${provider.extrasDetails['wide']}, NB: ${provider.extrasDetails['noball']}, B: ${provider.extrasDetails['bye']}, LB: ${provider.extrasDetails['legbye']})',
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                      ),
                      if (provider.inningsIndex == 1)
                        Text(
                          '1st Innings: ${provider.firstInningsScore}',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                        ),
                    ],
                  )
                ],
              ),
            ),

            // Live Crease stats (Striker, NonStriker, Bowler)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Batsmen scorecard card
                    Card(
                      color: const Color(0xFF1E222B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('BATSMEN', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                                if (provider.striker != null && provider.nonStriker != null)
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: neonGreen,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 30),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () => provider.swapStrikerAndNonStriker(),
                                    icon: const Icon(Icons.swap_vert, size: 16),
                                    label: const Text('SWAP POSITIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            const Divider(color: Colors.white10),
                            
                            // Striker line
                            _buildCreaseBatsmanRow(
                              player: provider.striker,
                              card: provider.striker != null ? provider.batsmenScorecards[provider.striker!.id] : null,
                              isOnStrike: true,
                              placeholderLabel: 'Select Striker',
                              onSelectPrompt: () {
                                _showPlayerSelectDialog(
                                  title: 'Select Striker',
                                  options: provider.yetToBatPlayers.where((p) => p.id != provider.nonStriker?.id).toList(),
                                  onSelect: (p) => provider.selectStriker(p),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            // Non-striker line
                            _buildCreaseBatsmanRow(
                              player: provider.nonStriker,
                              card: provider.nonStriker != null ? provider.batsmenScorecards[provider.nonStriker!.id] : null,
                              isOnStrike: false,
                              placeholderLabel: 'Select Non-Striker',
                              onSelectPrompt: () {
                                _showPlayerSelectDialog(
                                  title: 'Select Non-Striker',
                                  options: provider.yetToBatPlayers.where((p) => p.id != provider.striker?.id).toList(),
                                  onSelect: (p) => provider.selectNonStriker(p),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bowler card
                    Card(
                      color: const Color(0xFF1E222B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('BOWLER', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                            const Divider(color: Colors.white10),
                            _buildCreaseBowlerRow(
                              player: provider.currentBowler,
                              card: provider.currentBowler != null ? provider.bowlerScorecards[provider.currentBowler!.id] : null,
                              placeholderLabel: 'Select Bowler for this Over',
                              onSelectPrompt: () {
                                _showPlayerSelectDialog(
                                  title: 'Select Bowler',
                                  options: provider.bowlingTeamList,
                                  onSelect: (p) => provider.selectBowler(p),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // scoring console inputs
            Container(
              color: const Color(0xFF1E222B),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Keypad rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [0, 1, 2, 3].map((r) => _buildScoringButton('$r', () {
                      provider.recordBall(runs: r, extraType: 'none', isWicket: false);
                    })).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildScoringButton('4', () {
                        provider.recordBall(runs: 4, extraType: 'none', isWicket: false);
                      }),
                      _buildScoringButton('6', () {
                        provider.recordBall(runs: 6, extraType: 'none', isWicket: false);
                      }),
                      // Extras button
                      Expanded(
                        child: Container(
                          height: 55,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: ElevatedButton(
                            onPressed: (provider.striker == null || provider.currentBowler == null) ? null : _showExtrasDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text('EXTRAS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ),
                      ),
                      // Wicket button
                      Expanded(
                        child: Container(
                          height: 55,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: ElevatedButton(
                            onPressed: (provider.striker == null || provider.currentBowler == null) ? null : _showWicketDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text('OUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
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
    );
  }

  Widget _buildScoringButton(String label, VoidCallback onPressed) {
    final provider = Provider.of<MatchProvider>(context, listen: false);
    bool isDisabled = (provider.striker == null || provider.currentBowler == null);

    return Expanded(
      child: Container(
        height: 55,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF13161C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildCreaseBatsmanRow({
    required Player? player,
    required BattingScorecard? card,
    required bool isOnStrike,
    required String placeholderLabel,
    required VoidCallback onSelectPrompt,
  }) {
    const neonGreen = Color(0xFF39FF14);
    if (player == null) {
      return TextButton.icon(
        onPressed: onSelectPrompt,
        icon: const Icon(Icons.add, color: neonGreen),
        label: Text(placeholderLabel, style: const TextStyle(color: neonGreen, fontWeight: FontWeight.bold)),
      );
    }

    final runs = card?.runs ?? 0;
    final balls = card?.ballsFaced ?? 0;
    final fours = card?.fours ?? 0;
    final sixes = card?.sixes ?? 0;
    final double sr = balls == 0 ? 0.0 : (runs / balls) * 100.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (isOnStrike)
              const Icon(Icons.star, color: neonGreen, size: 16)
            else
              const SizedBox(width: 16),
            const SizedBox(width: 6),
            Text(
              player.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isOnStrike ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              '$runs ($balls)',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Text(
              '4s: $fours | 6s: $sixes',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 50,
              child: Text(
                'SR: ${sr.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                textAlign: TextAlign.right,
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildCreaseBowlerRow({
    required Player? player,
    required BowlingScorecard? card,
    required String placeholderLabel,
    required VoidCallback onSelectPrompt,
  }) {
    const neonGreen = Color(0xFF39FF14);
    if (player == null) {
      return TextButton.icon(
        onPressed: onSelectPrompt,
        icon: const Icon(Icons.add, color: neonGreen),
        label: Text(placeholderLabel, style: const TextStyle(color: neonGreen, fontWeight: FontWeight.bold)),
      );
    }

    final balls = card?.ballsBowled ?? 0;
    final runs = card?.runsConceded ?? 0;
    final wickets = card?.wickets ?? 0;
    final oversStr = "${balls ~/ 6}.${balls % 6}";
    final double econ = balls == 0 ? 0.0 : (runs / (balls / 6.0));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          player.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        Row(
          children: [
            Text(
              '$oversStr Ov',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Text(
              '$runs R',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Text(
              '$wickets W',
              style: const TextStyle(color: neonGreen, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Text(
              'Econ: ${econ.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ],
        )
      ],
    );
  }
}

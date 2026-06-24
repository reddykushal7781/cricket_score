import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/match_provider.dart';

class CelebrationPage extends StatefulWidget {
  const CelebrationPage({super.key});

  @override
  State<CelebrationPage> createState() => _CelebrationPageState();
}

class _CelebrationPageState extends State<CelebrationPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const neonGreen = Color(0xFF39FF14);
    final provider = Provider.of<MatchProvider>(context);
    final match = provider.currentMatch;

    // Fallback if match is null
    if (match == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F1115),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
        ),
      );
    }

    String winMessage;
    if (match.winner == 'Tie') {
      winMessage = 'Match Tied!';
    } else {
      winMessage = '${match.winner} wins the Match!';
    }

    String overA = "${match.teamABalls ~/ 6}.${match.teamABalls % 6}";
    String overB = "${match.teamBBalls ~/ 6}.${match.teamBBalls % 6}";

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background graphic elements
          Positioned(
            top: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neonGreen.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: neonGreen.withOpacity(0.2),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Trophy icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Congratulations Title
                const Text(
                  'CONGRATULATIONS!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: neonGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Winner Name
                Text(
                  winMessage,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Match scorecard Summary card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E222B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'MATCH SUMMARY',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            match.teamAName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${match.teamAScore}/${match.teamAWickets} ($overA Ov)',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            match.teamBName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${match.teamBScore}/${match.teamBWickets} ($overB Ov)',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Exit button
                ElevatedButton(
                  onPressed: () {
                    provider.exitMatch();
                    Navigator.of(context).pop(); // Exit back to Dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'BACK TO DASHBOARD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Confetti Widget Overlay
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.amber,
              neonGreen,
            ],
          ),
        ],
      ),
    );
  }
}

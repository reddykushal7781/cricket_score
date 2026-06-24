import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_score/models/player.dart';
import 'package:cricket_score/models/match.dart';
import 'package:cricket_score/providers/match_provider.dart';

void main() {
  test('MatchProvider Live Scoring Calculations & Undo Test', () async {
    final provider = MatchProvider();
    
    // Create mock players
    final teamA = List.generate(11, (i) => Player(id: i + 1, name: 'TeamA Player ${i + 1}'));
    final teamB = List.generate(11, (i) => Player(id: i + 12, name: 'TeamB Player ${i + 1}'));
    
    final match = CricketMatch(
      teamAName: 'Team A',
      teamBName: 'Team B',
      oversCount: 2,
      playersPerTeam: 11,
      date: '2026-06-21',
    );

    // Start match
    await provider.startMatch(match: match, teamA: teamA, teamB: teamB);
    
    expect(provider.totalScore, 0);
    expect(provider.wickets, 0);
    expect(provider.ballsBowled, 0);

    // Select batsmen and bowler
    provider.selectStriker(teamA[0]);
    provider.selectNonStriker(teamA[1]);
    provider.selectBowler(teamB[0]);

    expect(provider.striker?.name, 'TeamA Player 1');
    expect(provider.nonStriker?.name, 'TeamA Player 2');
    expect(provider.currentBowler?.name, 'TeamB Player 1');

    // 1. Record normal delivery (1 run)
    await provider.recordBall(runs: 1, extraType: 'none', isWicket: false);
    expect(provider.totalScore, 1);
    expect(provider.ballsBowled, 1);
    expect(provider.striker?.id, teamA[1].id); // Strike rotated to player 2
    
    // 2. Record boundary (4 runs)
    await provider.recordBall(runs: 4, extraType: 'none', isWicket: false);
    expect(provider.totalScore, 5);
    expect(provider.ballsBowled, 2);
    expect(provider.striker?.id, teamA[1].id); // No strike rotation on boundary

    // 3. Record wide extra
    await provider.recordBall(runs: 0, extraType: 'wide', isWicket: false);
    expect(provider.totalScore, 6); // 1 extra run added
    expect(provider.ballsBowled, 2); // Wides don't count as legal deliveries

    // 4. Record wicket (Striker is out)
    await provider.recordBall(runs: 0, extraType: 'none', isWicket: true, wicketType: 'bowled');
    expect(provider.wickets, 1);
    expect(provider.ballsBowled, 3);
    expect(provider.striker, null); // Striker is dismissed, needs selection

    // Select a new striker
    provider.selectStriker(teamA[2]);
    expect(provider.striker?.name, 'TeamA Player 3');

    // 5. Test Undo
    await provider.undoLastBall(); // Undo wicket
    expect(provider.wickets, 0);
    expect(provider.ballsBowled, 2);
    expect(provider.striker?.id, teamA[1].id); // Reverted striker back to player 2

    // Undo wide
    await provider.undoLastBall();
    expect(provider.totalScore, 5);
    expect(provider.ballsBowled, 2);
  });
}

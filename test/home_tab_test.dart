import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cricket_score/views/home_tab.dart';
import 'package:cricket_score/providers/match_provider.dart';

void main() {
  testWidgets('HomeTab builds and toggles double-sided player selection', (WidgetTester tester) async {
    final matchProvider = MatchProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<MatchProvider>.value(
        value: matchProvider,
        child: const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      ),
    );

    // Verify initial layout elements are visible
    expect(find.text('MATCH DETAILS'), findsOneWidget);
    expect(find.text('Team A Name'), findsOneWidget);
    expect(find.text('Team B Name'), findsOneWidget);
    expect(find.text('Double-Sided Player'), findsOneWidget);
    expect(find.text('SELECT DOUBLE-SIDED PLAYER'), findsNothing);

    // Toggle double-sided player switch on
    final switchFinder = find.byType(SwitchListTile);
    expect(switchFinder, findsOneWidget);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // Verify "SELECT DOUBLE-SIDED PLAYER" section appears
    expect(find.text('SELECT DOUBLE-SIDED PLAYER'), findsOneWidget);

    // Toggle double-sided player switch off
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // Verify "SELECT DOUBLE-SIDED PLAYER" section disappears
    expect(find.text('SELECT DOUBLE-SIDED PLAYER'), findsNothing);
  });
}

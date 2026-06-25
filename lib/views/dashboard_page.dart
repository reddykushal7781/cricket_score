import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'stats_tab.dart';
import 'previous_matches_tab.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  int _matchesTabKeySuffix = 0;
  int _statsTabKeySuffix = 0;

  final List<String> _titles = [
    'Dashboard',
    'Player Career Stats',
    'Match History',
  ];

  @override
  Widget build(BuildContext context) {
    const neonGreen = Color(0xFF39FF14);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E222B),
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeTab(),
          StatsTab(key: ValueKey('stats_tab_$_statsTabKeySuffix')),
          PreviousMatchesTab(key: ValueKey('matches_tab_$_matchesTabKeySuffix')),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF1E222B),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index == 2) {
                _matchesTabKeySuffix++;
              } else if (index == 1) {
                _statsTabKeySuffix++;
              }
            });
          },
          selectedItemColor: neonGreen,
          unselectedItemColor: Colors.white.withOpacity(0.4),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Matches',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';
import 'login_page.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  UserProfile? _userProfile;
  bool _isLoading = true;
  int _matchCount = 0;

  static const neonGreen = Color(0xFF39FF14);

  final Map<String, dynamic> _mockProfileJson = {
    "email": "kushal.reddy@example.com",
    "name": "Kushal Reddy",
    "avatarUrl":
        "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80",
    "role": "Batting All-Rounder",
    "battingStyle": "Right-hand bat",
    "bowlingStyle": "Right-arm medium-fast",
    "stats": {
      "batting": {
        "matches": 45,
        "innings": 42,
        "runs": 1248,
        "ballsFaced": 843,
        "average": 34.68,
        "strikeRate": 148.04,
        "highestScore": "94*",
        "notOuts": 6,
        "fifties": 8,
        "hundreds": 0,
        "fours": 112,
        "sixes": 48
      },
      "bowling": {
        "matches": 45,
        "innings": 38,
        "wickets": 52,
        "runsConceded": 1040,
        "ballsBowled": 912,
        "economy": 6.84,
        "average": 20.00,
        "strikeRate": 17.53,
        "bestBowling": "5/14",
        "threeWickets": 4,
        "fiveWickets": 1
      },
      "fielding": {"catches": 18, "stumpings": 0, "runOuts": 5}
    }
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final name = await _authService.getUsername();
    final matches = await DatabaseHelper.instance.getCompletedMatches();

    UserProfile? profile;
    if (name != null) {
      try {
        profile = await ApiService.getPlayerProfile(name);
      } catch (e) {
        debugPrint('Error loading user profile from API, using local mock: $e');
      }
    }

    if (profile == null) {
      final mock = UserProfile.fromJson(_mockProfileJson);
      profile = UserProfile(
        username: name ?? mock.username,
        name: name ?? mock.name,
        avatarUrl: mock.avatarUrl,
        role: mock.role,
        battingStyle: mock.battingStyle,
        bowlingStyle: mock.bowlingStyle,
        battingStats: mock.battingStats,
        bowlingStats: mock.bowlingStats,
        fieldingStats: mock.fieldingStats,
      );
    }

    if (mounted) {
      setState(() {
        _userProfile = profile;
        _matchCount = matches.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1115),
        body: Center(child: CircularProgressIndicator(color: neonGreen)),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1115),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: const Color(0xFF1E222B),
                expandedHeight: 320.0,
                floating: false,
                pinned: true,
                title: const Text(
                  'Player Profile',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.only(
                        top: 88.0, left: 16.0, right: 16.0, bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar & Name Card
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: neonGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: neonGreen, width: 2),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: neonGreen,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userProfile!.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (_userProfile!.username.isNotEmpty) ...[
                                    Text(
                                      '@${_userProfile!.username}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: neonGreen.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _userProfile!.role,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: neonGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Style details
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161A22),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'BATTING STYLE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.5),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userProfile!.battingStyle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              Column(
                                children: [
                                  Text(
                                    'BOWLING STYLE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.5),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userProfile!.bowlingStyle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
                ),
                bottom: TabBar(
                  indicatorColor: neonGreen,
                  labelColor: neonGreen,
                  unselectedLabelColor: Colors.white.withOpacity(0.6),
                  indicatorWeight: 3.0,
                  tabs: const [
                    Tab(text: 'OVERVIEW'),
                    Tab(text: 'BATTING'),
                    Tab(text: 'BOWLING'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildOverviewTab(),
              _buildBattingTab(),
              _buildBowlingTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Career Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildStatCard('Matches', '${_userProfile!.battingStats.matches}',
                  Icons.sports_cricket),
              _buildStatCard(
                  'Runs', '${_userProfile!.battingStats.runs}', Icons.timeline),
              _buildStatCard('Wickets', '${_userProfile!.bowlingStats.wickets}',
                  Icons.radar),
              _buildStatCard('Batting Avg',
                  '${_userProfile!.battingStats.average}', Icons.trending_up),
              _buildStatCard('Highest Score',
                  _userProfile!.battingStats.highestScore, Icons.emoji_events),
              _buildStatCard('Best Bowling',
                  _userProfile!.bowlingStats.bestBowling, Icons.star),
              _buildStatCard('Bowling Avg',
                  '${_userProfile!.bowlingStats.average}', Icons.trending_down),
              _buildStatCard('Catches',
                  '${_userProfile!.fieldingStats.catches}', Icons.pan_tool),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Fielding & Extras',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E222B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFieldingItem(
                    'Catches', '${_userProfile!.fieldingStats.catches}'),
                _buildFieldingItem(
                    'Stumpings', '${_userProfile!.fieldingStats.stumpings}'),
                _buildFieldingItem(
                    'Run Outs', '${_userProfile!.fieldingStats.runOuts}'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Scoring Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E222B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: neonGreen, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Matches Scored via this App',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_matchCount matches',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E222B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: neonGreen.withOpacity(0.8), size: 18),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldingItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBattingTab() {
    final b = _userProfile!.battingStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Batting Career Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E222B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                _buildStatRow('Matches', '${b.matches}'),
                _buildStatRow('Innings', '${b.innings}'),
                _buildStatRow('Runs', '${b.runs}'),
                _buildStatRow('Balls Faced', '${b.ballsFaced}'),
                _buildStatRow('Average', '${b.average}'),
                _buildStatRow('Strike Rate', '${b.strikeRate}'),
                _buildStatRow('Highest Score', b.highestScore),
                _buildStatRow('Not Outs', '${b.notOuts}'),
                _buildStatRow('Fifties', '${b.fifties}'),
                _buildStatRow('Hundreds', '${b.hundreds}'),
                _buildStatRow('Fours (4s)', '${b.fours}'),
                _buildStatRow('Sixes (6s)', '${b.sixes}', showBorder: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBowlingTab() {
    final b = _userProfile!.bowlingStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bowling Career Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E222B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                _buildStatRow('Matches', '${b.matches}'),
                _buildStatRow('Innings', '${b.innings}'),
                _buildStatRow('Wickets', '${b.wickets}'),
                _buildStatRow('Runs Conceded', '${b.runsConceded}'),
                _buildStatRow('Balls Bowled', '${b.ballsBowled}'),
                _buildStatRow('Economy Rate', '${b.economy}'),
                _buildStatRow('Average', '${b.average}'),
                _buildStatRow('Strike Rate', '${b.strikeRate}'),
                _buildStatRow('Best Bowling', b.bestBowling),
                _buildStatRow('3 Wicket Hauls', '${b.threeWickets}'),
                _buildStatRow('5 Wicket Hauls', '${b.fiveWickets}',
                    showBorder: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool showBorder = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

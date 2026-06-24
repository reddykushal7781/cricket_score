import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/match_provider.dart';
import 'services/auth_service.dart';
import 'services/database_helper.dart';
import 'views/login_page.dart';
import 'views/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pre-initialize database to ensure schema created
  await DatabaseHelper.instance.database;

  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MatchProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    const neonGreen = Color(0xFF39FF14);

    return MaterialApp(
      title: 'CricScorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        primaryColor: neonGreen,
        colorScheme: ColorScheme.dark(
          primary: neonGreen,
          secondary: neonGreen,
          background: const Color(0xFF0F1115),
          surface: const Color(0xFF1E222B),
          onBackground: Colors.white,
          onSurface: Colors.white,
          error: Colors.redAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E222B),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: isLoggedIn ? const DashboardPage() : const LoginPage(),
    );
  }
}

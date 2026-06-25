import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

import 'api_service.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'logged_in_username';

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<bool> register(String username, String password) async {
    if (username.isEmpty || password.isEmpty) return false;
    try {
      final response = await ApiService.register(username, password);
      return response['success'] == true;
    } catch (_) {
      final result = await _dbHelper.registerUser(username, password);
      return result != -1;
    }
  }

  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) return false;
    try {
      final response = await ApiService.login(username, password);
      if (response['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyUsername, username);
        return true;
      }
    } catch (_) {
      final user = await _dbHelper.loginUser(username, password);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyUsername, username);
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }
}

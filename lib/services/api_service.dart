import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ApiService {
  static const String baseUrl = 'https://cricket-score-backend-sfhz.onrender.com/api';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- Auth Service APIs ---
  static Future<Map<String, dynamic>> register(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    debugPrint('API Request [register]: POST $url with username: $username');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    debugPrint('API Response [register]: Status ${response.statusCode}, Body: ${response.body}');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try{
      final url = Uri.parse('$baseUrl/auth/login');
      debugPrint('API Request [login]: POST $url with username: $username');
      print('login called with username: $username');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      print("here ${response}");
      debugPrint('API Response [login]: Status ${response.statusCode}, Body: ${response.body}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('login result: $data');
      if (response.statusCode == 200 && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token'] as String);
      }
      return data;
    }
    catch(e){
      print("here e ${e}");
      throw e;
    }
    
  }

  // --- Player APIs ---
  static Future<List<Map<String, dynamic>>> searchPlayers(String query) async {
    final url = Uri.parse('$baseUrl/players/search?q=$query');
    final headers = await _getHeaders();
    debugPrint('API Request [searchPlayers]: GET $url');
    final response = await http.get(url, headers: headers);
    debugPrint('API Response [searchPlayers]: Status ${response.statusCode}, Body: ${response.body}');
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((item) => item as Map<String, dynamic>).toList();
    }
    throw Exception('Failed to search players: ${response.statusCode} - ${response.body}');
  }

  static Future<UserProfile> getPlayerProfile(String name) async {
    final encodedName = Uri.encodeComponent(name);
    final url = Uri.parse('$baseUrl/players/$encodedName/profile');
    final headers = await _getHeaders();
    debugPrint('API Request [getPlayerProfile]: GET $url');
    final response = await http.get(url, headers: headers);
    debugPrint('API Response [getPlayerProfile]: Status ${response.statusCode}, Body: ${response.body}');
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load profile for $name: ${response.statusCode} - ${response.body}');
  }

  static Future<List<Map<String, dynamic>>> getPlayerMatches(String name) async {
    final encodedName = Uri.encodeComponent(name);
    final url = Uri.parse('$baseUrl/players/$encodedName/matches');
    final headers = await _getHeaders();
    debugPrint('API Request [getPlayerMatches]: GET $url');
    final response = await http.get(url, headers: headers);
    debugPrint('API Response [getPlayerMatches]: Status ${response.statusCode}, Body: ${response.body}');
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((item) => item as Map<String, dynamic>).toList();
    }
    throw Exception('Failed to load matches for $name: ${response.statusCode} - ${response.body}');
  }

  // --- Match APIs ---
  static Future<Map<String, dynamic>> publishMatch(Map<String, dynamic> matchJson) async {
    final url = Uri.parse('$baseUrl/matches/publish');
    final headers = await _getHeaders();
    debugPrint('API Request [publishMatch]: POST $url with Body: ${jsonEncode(matchJson)}');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(matchJson),
    );
    debugPrint('API Response [publishMatch]: Status ${response.statusCode}, Body: ${response.body}');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getMatchDetails(int matchId) async {
    final url = Uri.parse('$baseUrl/matches/$matchId');
    final headers = await _getHeaders();
    debugPrint('API Request [getMatchDetails]: GET $url');
    final response = await http.get(url, headers: headers);
    debugPrint('API Response [getMatchDetails]: Status ${response.statusCode}, Body: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load match details: ${response.statusCode} - ${response.body}');
  }

  static Future<List<Map<String, dynamic>>> getMatches() async {
    final url = Uri.parse('$baseUrl/matches');
    final headers = await _getHeaders();
    debugPrint('API Request [getMatches]: GET $url');
    final response = await http.get(url, headers: headers);
    debugPrint('API Response [getMatches]: Status ${response.statusCode}, Body: ${response.body}');
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((item) => item as Map<String, dynamic>).toList();
    }
    throw Exception('Failed to load all matches: ${response.statusCode} - ${response.body}');
  }

  // --- Leaderboards/Stats APIs ---
  static Future<List<Map<String, dynamic>>> getStatsDays() async {
    final url = Uri.parse('$baseUrl/stats/days');
    final headers = await _getHeaders();
    debugPrint('API Request [getStatsDays]: GET $url');
    final response = await http.get(url, headers: headers);
    debugPrint('API Response [getStatsDays]: Status ${response.statusCode}, Body: ${response.body}');
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((item) => item as Map<String, dynamic>).toList();
    }
    throw Exception('Failed to load stats days: ${response.statusCode} - ${response.body}');
  }

  static Future<Map<String, dynamic>> getStatsPerformers(String date) async {
    final url = Uri.parse('$baseUrl/stats/performers?date=$date');
    final headers = await _getHeaders();
    debugPrint('API Request [getStatsPerformers]: GET $url');
    final response = await http.get(url, headers: headers);
    debugPrint('API Response [getStatsPerformers]: Status ${response.statusCode}, Body: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load performers: ${response.statusCode} - ${response.body}');
  }

  // --- Health API ---
  static Future<bool> checkHealth() async {
    final url = Uri.parse('$baseUrl/health');
    debugPrint('API Request [checkHealth]: GET $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 2));
      debugPrint('API Response [checkHealth]: Status ${response.statusCode}, Body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API Response [checkHealth]: Error checking health: $e');
      return false;
    }
  }
}

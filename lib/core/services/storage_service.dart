import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Save auth token
  Future<bool> saveToken(String token) async {
    return await _preferences!.setString('auth_token', token);
  }

  // Get auth token
  String? getToken() {
    return _preferences!.getString('auth_token');
  }

  // Save user ID
  Future<bool> saveUserId(String userId) async {
    return await _preferences!.setString('user_id', userId);
  }

  // Get user ID
  String? getUserId() {
    return _preferences!.getString('user_id');
  }

  // Save user data as JSON
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    return await _preferences!.setString('user_data', jsonEncode(userData));
  }

  // Get user data
  Map<String, dynamic>? getUserData() {
    final String? data = _preferences!.getString('user_data');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getToken() != null;
  }

  // Clear all data (logout)
  Future<bool> clearAll() async {
    return await _preferences!.clear();
  }

  // Save any string value
  Future<bool> saveString(String key, String value) async {
    return await _preferences!.setString(key, value);
  }

  // Get any string value
  String? getString(String key) {
    return _preferences!.getString(key);
  }

  // Save any boolean value
  Future<bool> saveBool(String key, bool value) async {
    return await _preferences!.setBool(key, value);
  }

  // Get any boolean value
  bool? getBool(String key) {
    return _preferences!.getBool(key);
  }
}

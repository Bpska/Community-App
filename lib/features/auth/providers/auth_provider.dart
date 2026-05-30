import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/config/app_config.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _needsVerification = false; // true when login blocked by unverified email

  AuthProvider(this._apiService, this._storageService);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get needsVerification => _needsVerification;

  // Initialize - check if user is already logged in
  Future<void> init() async {
    final userData = _storageService.getUserData();
    if (userData != null) {
      _currentUser = UserModel.fromJson(userData);
      notifyListeners();
      _updateLocationInBackground();
    }
  }

  // Update user location in background (non-blocking)
  Future<void> _updateLocationInBackground() async {
    try {
      final locationService = LocationService.getInstance();
      final position = await locationService.getCurrentPosition();
      if (position != null) {
        await _apiService.put('/users/location', data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      }
    } catch (e) {
      // Non-critical
    }
  }

  // ─────────────────────────── LOGIN ───────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    _needsVerification = false;
    notifyListeners();

    try {
      // Backend login endpoint: POST /api/auth/token
      final response = await _apiService.post(
        '${AppConfig.authBaseUrl}/token',
        data: {'email': email, 'password': password},
      );

      return await _handleLoginSuccess(response.data, email);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;

      if (status == 400 || status == 401) {
        _error = 'Incorrect email or password. Please try again.';
      } else if (body is Map && body['message'] != null) {
        _error = body['message'];
      } else {
        _error = 'Login failed. Please check your connection and try again.';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'A network error occurred. Please check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────── REGISTER ───────────────────────────
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    _needsVerification = false;
    notifyListeners();

    try {
      // Backend register endpoint: POST /api/auth/signup
      final response = await _apiService.post(
        '${AppConfig.authBaseUrl}/signup',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return await _handleLoginSuccess(response.data, email, pendingName: name);
      }

      _error = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;

      if (status == 400 && body is Map && body['message'] == 'User already exists') {
        // Email already registered — attempt login automatically
        print('Email already exists, attempting login...');
        _isLoading = false;
        notifyListeners();
        return await login(email, password);
      } else if (body is Map && body['message'] != null) {
        _error = body['message'];
      } else {
        _error = 'Registration failed. Please try again.';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'A network error occurred. Please check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Stored temporarily when registration succeeds but login follows
  String? _pendingName;

  // ─────────────────────── SHARED LOGIN HANDLER ───────────────────────
  Future<bool> _handleLoginSuccess(
    dynamic responseData,
    String email, {
    String? pendingName,
  }) async {
    try {
      final authUser = responseData['user'];
      final accessToken =
          responseData['accessToken'] ?? responseData['access_token'];
      final userId = authUser['id'].toString();

      // Save token immediately so subsequent API calls are authenticated
      await _storageService.saveToken(accessToken ?? '');
      await _storageService.saveUserId(userId);

      // Try to fetch existing profile row
      Map<String, dynamic> userData;
      try {
        final profileResponse =
            await _apiService.get('/users?id=eq.$userId');
        if (profileResponse.statusCode == 200 &&
            (profileResponse.data as List).isNotEmpty) {
          userData = profileResponse.data[0];
        } else {
          // Profile doesn't exist yet — create it
          final name = pendingName ?? _pendingName ?? authUser['email'] ?? 'User';
          userData = {
            'id': userId,
            'name': name,
            'email': email,
          };
          try {
            await _apiService.post('/users', data: [userData]);
          } catch (insertErr) {
            print('Profile insert warning: $insertErr');
          }
        }
      } catch (profileErr) {
        // Fallback profile in memory only
        userData = {
          'id': userId,
          'email': email,
          'name': pendingName ?? _pendingName ?? 'User',
        };
      }

      _pendingName = null;
      await _storageService.saveUserData(userData);
      _currentUser = UserModel.fromJson(userData);
      _needsVerification = false;
      _isLoading = false;
      notifyListeners();

      _updateLocationInBackground();
      return true;
    } catch (e) {
      _error = 'Login succeeded but failed to load your profile. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────── LOGOUT ───────────────────────────
  Future<void> logout() async {
    try {
      await _apiService.post('${AppConfig.authBaseUrl}/sessions/logout');
    } catch (_) {} // Logout is best-effort — always clear local state
    await _storageService.clearAll();
    _currentUser = null;
    _needsVerification = false;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    _needsVerification = false;
    notifyListeners();
  }
}

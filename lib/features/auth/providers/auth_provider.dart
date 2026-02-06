import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiService, this._storageService);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Initialize - check if user is already logged in
  Future<void> init() async {
    final userData = _storageService.getUserData();
    if (userData != null) {
      _currentUser = UserModel.fromJson(userData);
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Save token and user data
        await _storageService.saveToken(data['token'] ?? '');
        await _storageService.saveUserId(data['user']['id'].toString());
        await _storageService.saveUserData(data['user']);
        
        _currentUser = UserModel.fromJson(data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed. Please check your credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Save token and user data
        await _storageService.saveToken(data['token'] ?? '');
        await _storageService.saveUserId(data['user']['id'].toString());
        await _storageService.saveUserData(data['user']);
        
        _currentUser = UserModel.fromJson(data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call logout API (optional)
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Logout locally even if API fails
    } finally {
      // Clear local storage
      await _storageService.clearAll();
      _currentUser = null;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

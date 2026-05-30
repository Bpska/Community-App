import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/services/api_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/storage_service.dart';

class ProfileProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  ProfileProvider(this._apiService, this._storageService);

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load user profile
  Future<void> loadProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = _storageService.getUserId();
      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      final response = await _apiService.get('/users?id=eq.$userId');

      if (response.statusCode == 200 && (response.data as List).isNotEmpty) {
        final userData = response.data[0];
        _user = UserModel.fromJson(userData);
        await _storageService.saveUserData(userData);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Profile load error: $e');
      // Try to load from local storage as fallback
      final localData = _storageService.getUserData();
      if (localData != null) {
        _user = UserModel.fromJson(localData);
      }
      _error = 'Failed to load profile';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<bool> updateProfile({
    required String name,
    String? bio,
    String? gender,
    int? age,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = _storageService.getUserId();
      if (userId == null) return false;

      final response = await _apiService.put(
        '/users?id=eq.$userId',
        data: {
          'name': name,
          'bio': bio,
          'gender': gender,
          'age': age,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await loadProfile();
        return true;
      }

      _error = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An error occurred while updating profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Upload profile photo
  Future<bool> uploadProfilePhoto(File imageFile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.uploadFile(
        '/user/upload-photo',
        imageFile.path,
        'photo',
      );

      if (response.statusCode == 200) {
        await loadProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to upload photo';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An error occurred while uploading photo';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Change Password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.put(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'password': newPassword,
        },
      );

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _error = 'Failed to update password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Change Email
  Future<bool> changeEmail(String newEmail) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response =
          await _apiService.put('/user/change-email', data: {'email': newEmail});

      if (response.data['success'] == true) {
        if (_user != null) {
          _user = _user!.copyWith(email: newEmail);
          await _storageService.saveUserData(_user!.toJson());
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = response.data['message'] ?? 'Failed to update email';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update email';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Change Phone
  Future<bool> changePhone(String newPhone) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response =
          await _apiService.put('/user/change-phone', data: {'phone': newPhone});

      if (response.data['success'] == true) {
        if (_user != null) {
          _user = _user!.copyWith(phone: newPhone);
          await _storageService.saveUserData(_user!.toJson());
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = response.data['message'] ?? 'Failed to update phone number';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update phone number';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Deactivate Account
  Future<bool> deactivateAccount() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.post('/user/deactivate');

      if (response.data['success'] == true) {
        await _storageService.clearAll();
        _user = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = response.data['message'] ?? 'Failed to deactivate account';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to deactivate account';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete Account
  Future<bool> deleteAccount() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.delete('/user/delete');

      if (response.data['success'] == true) {
        await _storageService.clearAll();
        _user = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = response.data['message'] ?? 'Failed to delete account';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete account';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Set user from storage (initial load)
  void setUserFromStorage(UserModel user) {
    _user = user;
    notifyListeners();
  }
}

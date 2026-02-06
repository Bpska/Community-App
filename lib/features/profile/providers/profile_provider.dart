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

      final response = await _apiService.get('/user/profile');
      
      if (response.statusCode == 200) {
        _user = UserModel.fromJson(response.data);
        await _storageService.saveUserData(response.data);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
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

      final response = await _apiService.put('/user/profile', data: {
        'name': name,
        'bio': bio,
        'gender': gender,
        'age': age,
      });

      if (response.statusCode == 200) {
        _user = UserModel.fromJson(response.data);
        await _storageService.saveUserData(response.data);
        _isLoading = false;
        notifyListeners();
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
        _user = UserModel.fromJson(response.data);
        await _storageService.saveUserData(response.data);
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

  // Set user from storage (initial load)
  void setUserFromStorage(UserModel user) {
    _user = user;
    notifyListeners();
  }
}

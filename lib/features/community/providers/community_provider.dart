import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/community_model.dart';
import 'dart:io';

class CommunityProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<CommunityModel> _communities = [];
  bool _isLoading = false;
  String? _error;

  CommunityProvider(this._apiService);

  List<CommunityModel> get communities => _communities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch communities
  Future<void> fetchCommunities() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/communities/list');
      
      if (response.statusCode == 200) {
        List<dynamic> data;
        if (response.data is List) {
          data = response.data;
        } else {
          data = response.data['communities'] ?? [];
        }
        _communities = data.map((json) => CommunityModel.fromJson(json)).toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Fetch communities error: $e');
      _error = 'Failed to load communities';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search communities
  Future<void> searchCommunities(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/communities/search', queryParameters: {
        'query': query,
      });
      
      if (response.statusCode == 200) {
        List<dynamic> data;
        if (response.data is List) {
          data = response.data;
        } else {
          data = response.data['communities'] ?? [];
        }
        _communities = data.map((json) => CommunityModel.fromJson(json)).toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Search communities error: $e');
      _error = 'Failed to search communities';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Join community
  Future<bool> joinCommunity(String communityId) async {
    try {
      final response = await _apiService.post('/communities/join', data: {
        'communityId': communityId,
      });

      if (response.statusCode == 200) {
        // Update local community status
        final index = _communities.indexWhere((c) => c.id == communityId);
        if (index != -1) {
          _communities[index] = _communities[index].copyWith(
            isJoined: true,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      // If already a member (400), treat as success
      if (e.toString().contains('400')) {
        final index = _communities.indexWhere((c) => c.id == communityId);
        if (index != -1) {
          _communities[index] = _communities[index].copyWith(
            isJoined: true,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    }
  }

  // Create community
  Future<bool> createCommunity({
    required String name,
    required String description,
    required String category,
    required String type,
    required double radius,
    double? latitude,
    double? longitude,
    File? logo,
    File? cover,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Build text fields
      Map<String, dynamic> fields = {
        'name': name,
        'description': description,
        'category': category,
        'type': type,
        'radius': radius,
      };
      if (latitude != null) fields['latitude'] = latitude;
      if (longitude != null) fields['longitude'] = longitude;

      // Build files map
      Map<String, String>? files;
      if (logo != null || cover != null) {
        files = {};
        if (logo != null) files['logo'] = logo.path;
        if (cover != null) files['cover'] = cover.path;
      }

      final response = await _apiService.postMultipart(
        '/communities/create',
        fields: fields,
        files: files,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCommunities();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = 'Failed to create community';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Create community error: $e');
      _error = 'Failed to create community';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch community messages (convenience wrapper)
  Future<List<dynamic>> fetchCommunityMessages(String communityId) async {
    try {
      final response = await _apiService.get('/chat/community/$communityId');
      if (response.statusCode == 200) {
        return response.data['messages'] ?? [];
      }
      return [];
    } catch (e) {
      print('Fetch community messages error: $e');
      return [];
    }
  }

  // Update community
  Future<bool> updateCommunity({
    required String communityId,
    required String name,
    required String description,
    required String category,
    required String type,
    required double radius,
    File? logo,
    File? cover,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Map<String, dynamic> fields = {
        'name': name,
        'description': description,
        'category': category,
        'type': type,
        'radius': radius,
      };

      Map<String, String>? files;
      if (logo != null || cover != null) {
        files = {};
        if (logo != null) files['logo'] = logo.path;
        if (cover != null) files['cover'] = cover.path;
      }

      Response response;
      if (files != null) {
        response = await _apiService.postMultipart(
          '/communities/$communityId/update',
          fields: fields,
          files: files,
        );
      } else {
        response = await _apiService.put(
          '/communities/$communityId',
          data: fields,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        await fetchCommunities();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to update community';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Update community error: $e');
      _error = 'Failed to update community';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch community members
  Future<List<dynamic>> fetchCommunityMembers(String communityId) async {
    try {
      final response = await _apiService.get('/communities/$communityId/members');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Fetch community members error: $e');
      return [];
    }
  }

  // Delete community
  Future<bool> deleteCommunity(String communityId) async {
    try {
      final response = await _apiService.delete('/communities/$communityId');
      if (response.statusCode == 200) {
        _communities.removeWhere((c) => c.id == communityId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Delete community error: $e');
      return false;
    }
  }
}


import 'package:flutter/material.dart';
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
        final List<dynamic> data = response.data['communities'] ?? response.data;
        _communities = data.map((json) => CommunityModel.fromJson(json)).toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
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
        final List<dynamic> data = response.data['communities'] ?? response.data;
        _communities = data.map((json) => CommunityModel.fromJson(json)).toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
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
    File? logo,
    File? cover,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      Map<String, dynamic> data = {
        'name': name,
        'description': description,
        'category': category,
        'type': type,
        'radius': radius,
      };

      // If images, use multipart upload
      if (logo != null || cover != null) {
        Map<String, String> files = {};
        if (logo != null) files['logo'] = logo.path;
        if (cover != null) files['cover'] = cover.path;
        
        final response = await _apiService.uploadFiles('/communities/create', files);
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          await fetchCommunities();
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else {
        final response = await _apiService.post('/communities/create', data: data);
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          await fetchCommunities();
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

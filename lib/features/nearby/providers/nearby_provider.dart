import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/models/user_model.dart';

class NearbyProvider with ChangeNotifier {
  final ApiService _apiService;
  final LocationService _locationService;
  
  List<UserModel> _nearbyUsers = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  NearbyProvider(this._apiService, this._locationService);

  List<UserModel> get nearbyUsers => _nearbyUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;

  // Fetch nearby users
  Future<void> fetchNearbyUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get current location
      final position = await _locationService.getCurrentPosition();
      
      if (position == null) {
        _error = 'Unable to get your location. Please enable location services.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = position;

      // Update our own location in the backend first
      try {
        await _apiService.put('/users/location', data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
        print('Own location updated before nearby search');
      } catch (e) {
        print('Failed to update own location: $e');
        // Continue with fetch anyway
      }

      // Fetch nearby users from API (50km radius for better coverage)
      final response = await _apiService.get('/users/nearby', queryParameters: {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'radius': 50.0,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['users'] ?? response.data;
        _nearbyUsers = data.map((json) => UserModel.fromJson(json)).toList();
        
        // Calculate distances
        for (var user in _nearbyUsers) {
          if (user.latitude != null && user.longitude != null) {
            final distance = _locationService.calculateDistance(
              position.latitude,
              position.longitude,
              user.latitude!,
              user.longitude!,
            );
            // Store distance in a custom way or just use it for display
          }
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Nearby fetch error: $e');
      _error = 'Failed to fetch nearby users';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh nearby users
  Future<void> refresh() async {
    await fetchNearbyUsers();
  }

  // Get distance for a user
  double? getDistanceForUser(UserModel user) {
    if (_currentPosition == null || user.latitude == null || user.longitude == null) {
      return null;
    }
    
    return _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      user.latitude!,
      user.longitude!,
    );
  }

  // Format distance for display
  String formatDistance(UserModel user) {
    final distance = getDistanceForUser(user);
    if (distance == null) return 'Distance unknown';
    return _locationService.formatDistance(distance);
  }
}

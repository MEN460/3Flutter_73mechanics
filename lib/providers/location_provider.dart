import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechanic_discovery_app/providers/auth_provider.dart';
import 'package:mechanic_discovery_app/services/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService;
  final AuthProvider _authProvider;
  Position? _currentPosition;
  bool _isProcessing = false;

  LocationProvider(this._locationService, this._authProvider);

  Position? get currentPosition => _currentPosition;
  bool get isProcessing => _isProcessing;

  Future<void> getCurrentLocationAndUpdateBackend() async {
    if (_isProcessing) return;
    _isProcessing = true;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      _currentPosition = position;

      await _locationService.updateUserLocation(
        position.latitude,
        position.longitude,
      );

      _authProvider.updateUserLocation(position.latitude, position.longitude);

      notifyListeners();
    } catch (e) {
      print('[LocationProvider] Error: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> updateLocationManually(double latitude, double longitude) async {
    if (_isProcessing) return;
    _isProcessing = true;
    notifyListeners();

    final previousPosition = _currentPosition;
    try {
      await _locationService.updateUserLocation(latitude, longitude);

      _currentPosition = Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      );

      _authProvider.updateUserLocation(latitude, longitude);

      notifyListeners();
    } catch (e) {
      _currentPosition = previousPosition;
      print('[LocationProvider] Update failed: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final position = await _locationService.getCurrentLocation();
      _currentPosition = position;
      notifyListeners();
          return position;
    } catch (e) {
      print('[LocationProvider] Error: $e');
      return null;
    }
  }
}

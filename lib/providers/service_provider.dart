import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mechanic_discovery_app/models/service_request_model.dart';
import 'package:mechanic_discovery_app/models/user_model.dart';
import 'package:mechanic_discovery_app/providers/auth_provider.dart';
import 'package:mechanic_discovery_app/services/api_service.dart';
import 'package:mechanic_discovery_app/services/storage_service.dart';
import 'package:mechanic_discovery_app/services/api_endpoints.dart';

class ServiceProvider with ChangeNotifier {
  final AuthProvider _auth;
  final ApiService _apiService;
  final StorageService _storageService;
  List<ServiceRequest> _requests = [];

  List<ServiceRequest> get requests => _requests;

  ServiceProvider({
    required AuthProvider auth,
    required ApiService apiService,
    required StorageService storageService,
  }) : _auth = auth,
       _apiService = apiService,
       _storageService = storageService;

  Future<List<ServiceRequest>> getNearbyRequests() async {
    try {
      final token = await _storageService.getAccessToken();
      final response = await _apiService.get(
        ApiEndpoints.nearbyRequests,
        token: token,
      );

      if (response is! List) throw const FormatException('Expected List');
      _requests = response
          .map((item) => ServiceRequest.fromJson(item))
          .toList();
      notifyListeners();
      return _requests;
    } catch (e) {
      debugPrint('Error loading requests: $e');
      rethrow;
    }
  }

  // NEW: Get all pending requests
  Future<List<ServiceRequest>> getAllPendingRequests() async {
    try {
      final token = await _storageService.getAccessToken();
      final response = await _apiService.get(
        ApiEndpoints.allPendingRequests,
        token: token,
      );

      if (response is! List) throw const FormatException('Expected List');
      return response.map((item) => ServiceRequest.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading all pending requests: $e');
      rethrow;
    }
  }

  // NEW: Get mechanic's accepted pending requests
  Future<List<ServiceRequest>> getMyPendingRequests() async {
    try {
      final token = await _storageService.getAccessToken();
      final response = await _apiService.get(
        ApiEndpoints.myPendingRequests,
        token: token,
      );

      if (response is! List) throw const FormatException('Expected List');
      return response.map((item) => ServiceRequest.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading my pending requests: $e');
      rethrow;
    }
  }

  Future<void> acceptRequest(int requestId) async {
    try {
      final token = await _storageService.getAccessToken();
      await _apiService.post(ApiEndpoints.acceptRequest, {
        'request_id': requestId,
      }, token: token);

      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _requests[index] = _requests[index].copyWith(
          status: 'accepted',
          acceptedAt: DateTime.now(),
          mechanicId: _auth.user?.id,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error accepting request: $e');
      rethrow;
    }
  }

  // UPDATED: Request service with optional mechanicId
  Future<void> requestService(
    double latitude,
    double longitude,
    String description, {
    int? mechanicId,
  }) async {
    try {
      final token = await _storageService.getAccessToken();
      await _apiService.post(ApiEndpoints.serviceRequest, {
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        if (mechanicId != null) 'mechanic_id': mechanicId,
      }, token: token);
    } catch (e) {
      debugPrint('Error requesting service: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> getNearbyMechanics(
    double latitude,
    double longitude,
  ) async {
    try {
      final token = await _storageService.getAccessToken();
      final response = await _apiService.get(
        '${ApiEndpoints.nearbyMechanics}?latitude=$latitude&longitude=$longitude',
        token: token,
      );

      if (response is! List) throw const FormatException('Expected List');
      return response.map((item) => UserModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading mechanics: $e');
      rethrow;
    }
  }
}
// This code defines a ServiceProvider class that manages service requests and mechanics.
// It includes methods to get nearby requests, accept requests, and request services.
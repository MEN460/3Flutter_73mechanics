import 'dart:convert';
import 'package:mechanic_discovery_app/models/user_model.dart';
import 'package:mechanic_discovery_app/services/api_endpoints.dart';
import 'package:mechanic_discovery_app/services/api_service.dart';
import 'package:mechanic_discovery_app/services/storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService({ApiService? apiService, StorageService? storageService})
    : _apiService = apiService ?? ApiService(),
      _storageService = storageService ?? StorageService();

  Future<UserModel> register(
    String username,
    String email,
    String password,
    String userType,
    String phone,
  ) async {
    try {
      final response = await _apiService.post(ApiEndpoints.register, {
        'username': username,
        'email': email,
        'password': password,
        'user_type': userType,
        'phone': phone,
      });

      // Save tokens immediately
      await _storageService.saveTokens(
        response['access_token'],
        response['refresh_token'],
      );

      // Parse user directly
      return UserModel.fromJson(response['user']);
    } catch (e) {
      throw Exception(_parseError(e));
    }
  }


  Future<UserModel> login(String loginId, String password) async {
    try {
      final response = await _apiService.post(ApiEndpoints.login, {
        'login_id': loginId,
        'password': password,
      });

      if (response == null || response['user'] == null) {
        throw Exception('Login failed: Invalid response');
      }

      await _storageService.saveTokens(
        response['access_token'],
        response['refresh_token'],
      );

      return UserModel.fromJson(response['user']);
    } catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> logout() async {
    await _storageService.deleteTokens();
  }

  String _parseError(Object error) {
    final raw = error.toString();
    final jsonStart = raw.indexOf('{');
    if (jsonStart != -1) {
      try {
        final decoded = jsonDecode(raw.substring(jsonStart));
        if (decoded is Map) {
          return decoded['message'] ?? decoded['error'] ?? raw;
        }
      } catch (_) {}
    }
    return raw;
  }
}

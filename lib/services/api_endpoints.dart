import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static String baseUrl = dotenv.get(
    'API_URL',
    fallback: 'http://localhost:5000',
  );

  static String get apiBase => '$baseUrl/api';

  static String get login => '$apiBase/auth/login';
  static String get register => '$apiBase/auth/register';
  static String get userProfile => '$apiBase/user/profile';
  static String get updateLocation => '$apiBase/update-location';
  static String get nearbyMechanics => '$apiBase/mechanics/nearby-mechanics';
  static String get nearbyRequests => '$apiBase/service/nearby-requests';
  static String get serviceRequest => '$apiBase/service/request-service';
  static String get acceptRequest => '$apiBase/service/accept-request';
  static String get health => '$apiBase/health';
  static String get updateProfile => '$apiBase/user/update-profile';

  // NEW: Endpoints for request categories
  static String get allPendingRequests =>
      '$apiBase/service/nearby-requests';
  static String get myPendingRequests => '$apiBase/service/nearby-requests';
}
//
// Compare this snippet from lib/services/api_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<dynamic> post(String url, dynamic body, {String? token}) async {
    print('[API] POST to $url');
    print('[API] Request body: $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('[API] Error: $e');
      rethrow;
    }
  }

  Future<dynamic> get(String url, {String? token}) async {
    print('[API] GET to $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      print('[API] Response status: ${response.statusCode}');
      print('[API] Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('[API] Error: $e');
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'API Error ${response.statusCode}');
      } catch (_) {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    }
  }
}

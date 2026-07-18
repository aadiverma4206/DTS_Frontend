import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class UserApi {
  static const Duration timeout = Duration(seconds: 30);
  static Future<Map<String, dynamic>> getUserDetail(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse("${ApiService.baseUrl}/users/detail/$id"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        if (data is Map<String, dynamic>) {
          if (data.containsKey("data") && data["data"] is Map) {
            return Map<String, dynamic>.from(data["data"]);
          }
          return data;
        }
        return {};
      } else {
        throw Exception(_message(data, "Failed to fetch user detail"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await http
          .get(
            Uri.parse("${ApiService.baseUrl}/users"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseList(data);
      } else {
        throw Exception(_message(data, "Failed to fetch users"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> getRetailers() async {
    try {
      final response = await http
          .get(
            Uri.parse("${ApiService.baseUrl}/users/retailers"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseList(data);
      } else {
        throw Exception(_message(data, "Failed to load retailers"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http
          .get(
            Uri.parse("${ApiService.baseUrl}/users/profile"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return data is Map<String, dynamic> ? data : {};
      } else {
        throw Exception(_message(data, "Failed to fetch profile"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> approveUser(int userId) async {
    try {
      final response = await http
          .patch(
            Uri.parse("${ApiService.baseUrl}/users/approve/$userId"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return data is Map<String, dynamic> ? data : {};
      } else {
        throw Exception(_message(data, "Approval failed"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> rejectUser(int userId) async {
    try {
      final response = await http
          .patch(
            Uri.parse("${ApiService.baseUrl}/users/reject/$userId"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return data is Map<String, dynamic> ? data : {};
      } else {
        throw Exception(_message(data, "Rejection failed"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> createInspector(
    String name,
    String email,
    String password,
    String mobile,
  ) async {
    try {
      final uri = Uri.parse("${ApiService.baseUrl}/users/inspector");

      final response = await http
          .post(
            uri,
            headers: ApiService.headers,
            body: jsonEncode({
              "name": name.trim(),
              "email": email.trim(),
              "password": password,
              "mobile": mobile.trim(),
            }),
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data is Map<String, dynamic> ? data : {};
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired. Please login again.");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      throw Exception(_message(data, "Failed to create inspector"));
    } on SocketException {
      throw Exception("No internet connection");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<Map<String, dynamic>> getProfileById(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse("${ApiService.baseUrl}/users/profile/$id"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return data is Map<String, dynamic> ? data : {};
      } else {
        throw Exception(_message(data, "Failed to fetch profile"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> getWholesalers() async {
    try {
      final response = await http
          .get(
            Uri.parse("${ApiService.baseUrl}/users/wholesalers"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseList(data);
      } else {
        throw Exception(_message(data, "Failed to fetch wholesalers"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) {
      return data
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    if (data is Map && data["data"] is List) {
      return (data["data"] as List)
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }

  static String _message(dynamic data, String fallback) {
    if (data is Map && data["message"] != null) {
      return data["message"].toString();
    }
    return fallback;
  }

  static dynamic _decode(http.Response response) {
    try {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } catch (_) {
      return {"message": "Invalid response from server"};
    }
  }
}

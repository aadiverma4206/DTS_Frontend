import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthApi {
  static const Duration timeout = Duration(seconds: 30);
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final url = Uri.parse("${ApiService.baseUrl}/auth/login");

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": email.trim(),
              "password": password.trim(),
            }),
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        if (data is! Map<String, dynamic>) {
          throw Exception("Invalid server response");
        }

        final token = data["token"];

        if (token == null || token.toString().isEmpty) {
          throw Exception("Token not found");
        }

        ApiService.setToken(token.toString());

        return data;
      }

      if (data is Map && data["message"] != null) {
        throw Exception(data["message"].toString());
      }

      throw Exception("Login failed");
    } on SocketException {
      throw Exception("No internet connection");
    } on HttpException {
      throw Exception("Server error");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      final error = e.toString().replaceAll("Exception:", "").trim();

      throw Exception(error);
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    int roleId,
    String mobile,
  ) async {
    try {
      final url = Uri.parse("${ApiService.baseUrl}/auth/register");

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "name": name.trim(),
              "email": email.trim(),
              "password": password.trim(),
              "role_id": roleId,
              "mobile": mobile.trim(),
            }),
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 201) {
        return data is Map<String, dynamic> ? data : {};
      } else {
        throw Exception(_message(data, "Registration failed"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } on HttpException {
      throw Exception("Server error");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> forgetPassword({
    required String email,
    required String mobile,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final url = Uri.parse("${ApiService.baseUrl}/auth/forget-password");

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": email.trim(),
              "mobile": mobile.trim(),
              "password": password.trim(),
              "confirm_password": confirmPassword.trim(),
            }),
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return data is Map<String, dynamic> ? data : {};
      } else {
        throw Exception(_message(data, "Password reset failed"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } on HttpException {
      throw Exception("Server error");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static dynamic _decode(http.Response response) {
    try {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } catch (_) {
      return {"message": "Invalid response from server"};
    }
  }

  static String _message(dynamic data, String fallback) {
    if (data is Map && data["message"] != null) {
      return data["message"].toString();
    }
    return fallback;
  }
}

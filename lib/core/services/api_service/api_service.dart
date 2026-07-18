import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = "http://10.0.2.2:5000/api"; //for emulator
  // static const String baseUrl = "http://192.168.29.153:5000/api";// for mobile
  // static const String baseUrl = "http://localhost:5000/api";//for chrome
  static const String baseUrl =
      "https://drug-tracking-system-production-ae87.up.railway.app/api";

  static String? token;
  static void setToken(String newToken) {
    token = newToken;
  }

  static Map<String, String> get headers {
    final map = {"Content-Type": "application/json"};
    if (token != null && token!.isNotEmpty) {
      map["Authorization"] = "Bearer $token";
    }
    return map;
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) return {};
    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw Exception("Invalid response from server");
    }
  }

  static Exception _handleError(dynamic data, String fallback) {
    if (data is Map && data["message"] != null) {
      return Exception(data["message"].toString());
    }
    return Exception(fallback);
  }

  static Future<Map<String, dynamic>> postRequest(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      final data = _handleResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data is Map<String, dynamic> ? data : {};
      } else {
        throw _handleError(data, "Request failed");
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

  static Future<dynamic> getRequest(Uri url) async {
    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      final data = _handleResponse(response);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw _handleError(data, "Request failed");
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

  static Future<Map<String, dynamic>> patchRequest(
    Uri url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http
          .patch(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      final data = _handleResponse(response);

      if (response.statusCode == 200) {
        return data is Map<String, dynamic> ? data : {};
      } else {
        throw _handleError(data, "Request failed");
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

  static Future<Map<String, dynamic>> deleteRequest(Uri url) async {
    try {
      final response = await http
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      final data = _handleResponse(response);

      if (response.statusCode == 200) {
        return data is Map<String, dynamic> ? data : {};
      } else {
        throw _handleError(data, "Request failed");
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
}

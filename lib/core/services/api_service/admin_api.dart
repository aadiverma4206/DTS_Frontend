import 'api_service.dart';
import 'dart:async';
import 'dart:io';

class AdminApi {
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final res = await ApiService.getRequest(
      Uri.parse("${ApiService.baseUrl}/users"),
    );

    return _parseList(res);
  }

  static Future<Map<String, dynamic>> getAdminProfile() async {
    try {
      final res = await ApiService.getRequest(
        Uri.parse("${ApiService.baseUrl}/admin/my-profile"),
      );

      if (res == null) {
        throw Exception("No response from server");
      }

      if (res is Map<String, dynamic>) {
        if (res["success"] == true) {
          return Map<String, dynamic>.from(res["data"] ?? {});
        }

        throw Exception(
          res["message"]?.toString() ?? "Failed to load admin profile",
        );
      }

      throw Exception("Invalid server response");
    } on TimeoutException {
      throw Exception("Request timeout. Please try again.");
    } on SocketException {
      throw Exception("No internet connection.");
    } on FormatException {
      throw Exception("Invalid response format.");
    } catch (e) {
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  static Future<List<Map<String, dynamic>>> getStockUsers({
    String role = 'all',
    String search = '',
  }) async {
    final encodedSearch = Uri.encodeComponent(search);

    final res = await ApiService.getRequest(
      Uri.parse(
        "${ApiService.baseUrl}/admin/stock-users?role=$role&search=$encodedSearch",
      ),
    );

    return _parseList(res);
  }

  static Future<List<Map<String, dynamic>>> getUserStockList(int userId) async {
    final res = await ApiService.getRequest(
      Uri.parse("${ApiService.baseUrl}/admin/user-stock/$userId"),
    );

    return _parseList(res);
  }

  static Future<Map<String, dynamic>> getStockDetail(int stockId) async {
    final res = await ApiService.getRequest(
      Uri.parse("${ApiService.baseUrl}/admin/stock-detail/$stockId"),
    );

    return _parseMap(res);
  }

  static Future<List<Map<String, dynamic>>> getStockMonitor() async {
    final res = await ApiService.getRequest(
      Uri.parse("${ApiService.baseUrl}/admin/stock-users"),
    );

    return _parseList(res);
  }

  static List<Map<String, dynamic>> _parseList(dynamic data) {
    try {
      if (data is List) {
        return data
            .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e as Map),
            )
            .toList();
      }

      if (data is Map && data["data"] is List) {
        return (data["data"] as List)
            .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e as Map),
            )
            .toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  static Map<String, dynamic> _parseMap(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        return data;
      }

      if (data is Map && data["data"] is Map) {
        return Map<String, dynamic>.from(data["data"]);
      }

      return {};
    } catch (_) {
      return {};
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class InspectionApi {
  static const Duration timeout = Duration(seconds: 30);
  static String get base => "${ApiService.baseUrl}/inspections";

  static Future<Map<String, dynamic>> createInspection({
    required int targetUserId,
    required String inspectionType,
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> checks,
    int? totalSystemQty,
    int? totalPhysicalQty,
    String? remarks,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(base),
            headers: ApiService.headers,
            body: jsonEncode({
              "target_user_id": targetUserId,
              "inspection_type": inspectionType,
              "items": items,
              "checks": checks,
              "total_system_qty": totalSystemQty,
              "total_physical_qty": totalPhysicalQty,
              "remarks": remarks,
            }),
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data is Map<String, dynamic> ? data : {};
      }

      if (response.statusCode == 401) throw Exception("Session expired");
      if (response.statusCode == 403) throw Exception("Access denied");
      if (response.statusCode == 404) throw Exception("Route not found");

      throw Exception(_message(data, "Failed to create inspection"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<Map<String, dynamic>> getInspectorProfile() async {
    try {
      final response = await http
          .get(Uri.parse("$base/my-profile"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Map<String, dynamic>.from(data["data"] ?? {});
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      if (response.statusCode == 404) {
        throw Exception("Inspector profile not found");
      }

      throw Exception(_message(data, "Failed to load inspector profile"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<List<Map<String, dynamic>>> getAllInspections({
    String inspectorId = "all",
    String targetType = "all",
    String search = "",
  }) async {
    try {
      final uri = Uri.parse(base).replace(
        queryParameters: {
          if (inspectorId != "all") "inspector_id": inspectorId,
          if (targetType != "all") "target_type": targetType,
          if (search.isNotEmpty) "search": search,
        },
      );

      final response = await http
          .get(uri, headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseList(data);
      }

      if (response.statusCode == 401) throw Exception("Session expired");
      if (response.statusCode == 403) throw Exception("Access denied");

      throw Exception(_message(data, "Failed to fetch inspections"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<Map<String, dynamic>> getInspectionDetails(
    int inspectionId,
  ) async {
    try {
      if (inspectionId <= 0) {
        throw Exception("Invalid inspection id");
      }

      final response = await http
          .get(Uri.parse("$base/$inspectionId"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data is Map<String, dynamic> ? data : {};
      }

      if (response.statusCode == 401) throw Exception("Session expired");
      if (response.statusCode == 403) throw Exception("Access denied");
      if (response.statusCode == 404) throw Exception("Inspection not found");

      throw Exception(_message(data, "Failed to fetch inspection details"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<List<Map<String, dynamic>>> getTargets({
    required String type,
    String? search,
  }) async {
    try {
      final uri = Uri.parse("$base/targets").replace(
        queryParameters: {
          "type": type,
          if (search != null && search.isNotEmpty) "search": search,
        },
      );

      final response = await http
          .get(uri, headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseList(data);
      }

      if (response.statusCode == 401) throw Exception("Session expired");
      if (response.statusCode == 403) throw Exception("Access denied");

      throw Exception(_message(data, "Failed to fetch targets"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<List<Map<String, dynamic>>> getInspectionStock(
    int userId,
  ) async {
    try {
      if (userId <= 0) throw Exception("Invalid user id");

      final response = await http
          .get(Uri.parse("$base/stock/$userId"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseList(data);
      }

      if (response.statusCode == 401) throw Exception("Session expired");
      if (response.statusCode == 403) throw Exception("Access denied");

      throw Exception(_message(data, "Failed to fetch stock"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<List<Map<String, dynamic>>> getWholesalers() async {
    try {
      final response = await http
          .get(Uri.parse("$base/wholesalers"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseList(data);
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      throw Exception(_message(data, "Failed to fetch wholesalers"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<Map<String, dynamic>> getWholesalerDetails(int userId) async {
    try {
      if (userId <= 0) {
        throw Exception("Invalid user id");
      }

      final response = await http
          .get(
            Uri.parse("$base/wholesalers/$userId"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data is Map<String, dynamic> ? data : {};
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      if (response.statusCode == 404) {
        throw Exception("Wholesaler not found");
      }

      throw Exception(_message(data, "Failed to fetch wholesaler details"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<List<Map<String, dynamic>>> getExpiredStock(int userId) async {
    try {
      if (userId <= 0) throw Exception("Invalid user id");

      final response = await http
          .get(Uri.parse("$base/expired/$userId"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseList(data);
      }

      if (response.statusCode == 401) throw Exception("Session expired");
      if (response.statusCode == 403) throw Exception("Access denied");

      throw Exception(_message(data, "Failed to fetch expired stock"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<List<Map<String, dynamic>>> getRetailers() async {
    try {
      final response = await http
          .get(Uri.parse("$base/retailers"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseList(data);
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      throw Exception(_message(data, "Failed to fetch retailers"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<Map<String, dynamic>> getRetailerDetails(int userId) async {
    try {
      if (userId <= 0) {
        throw Exception("Invalid user id");
      }

      final response = await http
          .get(
            Uri.parse("$base/retailers/$userId"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data is Map<String, dynamic> ? data : {};
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      if (response.statusCode == 404) {
        throw Exception("Retailer not found");
      }

      throw Exception(_message(data, "Failed to fetch retailer details"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<List<Map<String, dynamic>>> getStockTargets() async {
    try {
      final response = await http
          .get(Uri.parse("$base/stock-targets"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseList(data);
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      throw Exception(_message(data, "Failed to fetch stock targets"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<Map<String, dynamic>> getStockDetails(int userId) async {
    try {
      if (userId <= 0) {
        throw Exception("Invalid user id");
      }

      final response = await http
          .get(
            Uri.parse("$base/stock-details/$userId"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data is Map<String, dynamic> ? data : {};
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      if (response.statusCode == 404) {
        throw Exception("Stock details not found");
      }

      throw Exception(_message(data, "Failed to fetch stock details"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<List<Map<String, dynamic>>> getSalesList({
    required String type,
  }) async {
    try {
      final response = await http
          .get(Uri.parse("$base/sales?type=$type"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseList(data);
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      throw Exception(_message(data, "Failed to fetch sales list"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<Map<String, dynamic>> getSaleDetails({
    required int userId,
    required String type,
  }) async {
    try {
      if (userId <= 0) {
        throw Exception("Invalid user id");
      }

      final response = await http
          .get(
            Uri.parse("$base/sales/$userId?type=$type"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data is Map<String, dynamic> ? data : {};
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      if (response.statusCode == 404) {
        throw Exception("Data not found");
      }

      throw Exception(_message(data, "Failed to fetch sales details"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<List<Map<String, dynamic>>> getDrugList({
    String search = "",
  }) async {
    try {
      final uri = Uri.parse(
        "$base/drugs",
      ).replace(queryParameters: {if (search.isNotEmpty) "search": search});

      final response = await http
          .get(uri, headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseList(data);
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      throw Exception(_message(data, "Failed to fetch drugs"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<List<Map<String, dynamic>>> getDrugHolders({
    required int drugId,
    String type = "all",
    String search = "",
  }) async {
    try {
      if (drugId <= 0) {
        throw Exception("Invalid drug id");
      }

      final uri = Uri.parse("$base/drugs/$drugId/holders").replace(
        queryParameters: {
          "type": type,
          if (search.isNotEmpty) "search": search,
        },
      );

      final response = await http
          .get(uri, headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseList(data);
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      throw Exception(_message(data, "Failed to fetch drug holders"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<Map<String, dynamic>> getDrugHolderDetails({
    required int drugId,
    required int userId,
  }) async {
    try {
      if (drugId <= 0 || userId <= 0) {
        throw Exception("Invalid parameters");
      }

      final response = await http
          .get(
            Uri.parse("$base/drugs/$drugId/holder/$userId"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data is Map<String, dynamic> ? data : {};
      }

      if (response.statusCode == 401) {
        throw Exception("Session expired");
      }

      if (response.statusCode == 403) {
        throw Exception("Access denied");
      }

      if (response.statusCode == 404) {
        throw Exception("Data not found");
      }

      throw Exception(_message(data, "Failed to fetch drug holder details"));
    } on TimeoutException {
      throw Exception("Request timeout");
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is List) {
      return data
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (data is Map && data["data"] is List) {
      return (data["data"] as List)
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return [];
  }

  static dynamic _decode(http.Response response) {
    try {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } catch (_) {
      return {"message": "Invalid response"};
    }
  }

  static String _message(dynamic data, String fallback) {
    if (data is Map && data["message"] != null) {
      return data["message"].toString();
    }
    return fallback;
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class StockApi {
  static const Duration timeout = Duration(seconds: 30);

  static String get _base => "${ApiService.baseUrl}/stock";

  static Future<Map<String, dynamic>> getStockDetail(int batchId) async {
    try {
      if (batchId <= 0) {
        throw Exception("Invalid batch id");
      }

      final response = await http
          .get(Uri.parse("$_base/detail/$batchId"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        if (data is Map && data["data"] is Map) {
          return Map<String, dynamic>.from(data["data"]);
        }
        if (data is Map<String, dynamic>) {
          return data;
        }
        return {};
      } else {
        throw Exception(_message(data, "Failed to fetch stock detail"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> getStock() async {
    try {
      final response = await http
          .get(Uri.parse(_base), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseList(data, isHistory: false);
      } else {
        throw Exception(_message(data, "Failed to fetch stock"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> getStockHistory() async {
    try {
      final response = await http
          .get(Uri.parse("$_base/history"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseList(data, isHistory: true);
      } else {
        throw Exception(_message(data, "Failed to fetch stock history"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static List<Map<String, dynamic>> _parseList(
    dynamic data, {
    required bool isHistory,
  }) {
    final list = _extractList(data);

    return list.map<Map<String, dynamic>>((e) {
      final map = Map<String, dynamic>.from(e);

      if (isHistory) {
        return {
          "batch_id": int.tryParse(map["batch_id"]?.toString() ?? "") ?? 0,
          "drug_name": map["drug_name"]?.toString() ?? "",
          "batch_no": map["batch_no"]?.toString() ?? "",
          "change_qty": int.tryParse(map["change_qty"]?.toString() ?? "") ?? 0,
          "movement_type": map["movement_type"]?.toString() ?? "",
          "reference_type": map["reference_type"]?.toString() ?? "",
          "created_at": map["created_at"]?.toString() ?? "",
          "manufacturer_name": map["manufacturer_name"]?.toString() ?? "",
          "sender_name": map["sender_name"]?.toString() ?? "",
          "receiver_name": map["receiver_name"]?.toString() ?? "",
        };
      } else {
        return {
          "batch_id": int.tryParse(map["batch_id"]?.toString() ?? "") ?? 0,
          "drug_name": map["drug_name"]?.toString() ?? "",
          "batch_no": map["batch_no"]?.toString() ?? "",
          "quantity": int.tryParse(map["quantity"]?.toString() ?? "") ?? 0,
          "mrp": double.tryParse(map["mrp"]?.toString() ?? "") ?? 0,
          "manufacturer_name": map["manufacturer_name"]?.toString() ?? "",
          "expiry_date": map["expiry_date"]?.toString() ?? "",
          "created_at": map["created_at"]?.toString() ?? "",
        };
      }
    }).toList();
  }

  static List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data["data"] is List) return data["data"];
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

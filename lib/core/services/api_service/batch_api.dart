import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class BatchApi {
  static const Duration timeout = Duration(seconds: 30);
  static Future<Map<String, dynamic>> createBatch({
    required String batchNo,
    required int manufacturerId,
    required int drugId,
    required DateTime manufactureDate,
    required DateTime expiryDate,
    required DateTime stockReceiveDate,
    required double mrp,
    required double purchasePrice,
    required int quantity,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("${ApiService.baseUrl}/batches"),

            headers: ApiService.headers,

            body: jsonEncode({
              "batch_no": batchNo.trim(),

              "manufacturer_id": manufacturerId,

              "drug_id": drugId,

              "manufacture_date": manufactureDate.toIso8601String().split(
                "T",
              )[0],

              "expiry_date": expiryDate.toIso8601String().split("T")[0],

              "stock_receive_date": stockReceiveDate.toIso8601String().split(
                "T",
              )[0],

              "mrp": mrp,

              "purchase_price": purchasePrice,

              "quantity": quantity,
            }),
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map<String, dynamic>) {
          return data;
        }

        return {"success": false, "message": "Invalid response data"};
      } else {
        throw Exception(_message(data, "Failed to create batch"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } on HttpException {
      throw Exception("Server error");
    } on TimeoutException {
      throw Exception("Request timeout");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<List<Map<String, dynamic>>> getAllBatches() async {
    try {
      final response = await http
          .get(
            Uri.parse("${ApiService.baseUrl}/batches"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseList(data);
      } else {
        throw Exception(_message(data, "Failed to fetch batches"));
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

  static Future<List<Map<String, dynamic>>> getMyBatches() async {
    try {
      final response = await http
          .get(
            Uri.parse("${ApiService.baseUrl}/batches/my"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseList(data);
      } else {
        throw Exception(_message(data, "Failed to fetch my batches"));
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

  static List<Map<String, dynamic>> _parseList(dynamic data) {
    final list = _extractList(data);

    return list.map<Map<String, dynamic>>((e) {
      final map = Map<String, dynamic>.from(e);

      return {
        "batch_id": int.tryParse(map["batch_id"]?.toString() ?? "0") ?? 0,
        "batch_no": map["batch_no"]?.toString() ?? "",
        "drug_id": int.tryParse(map["drug_id"]?.toString() ?? "0") ?? 0,
        "drug_name": map["drug_name"]?.toString() ?? "",
        "manufacturer_name": map["manufacturer_name"]?.toString() ?? "",
        "mrp": double.tryParse(map["mrp"]?.toString() ?? "0") ?? 0.0,
        "purchase_price":
            double.tryParse(map["purchase_price"]?.toString() ?? "0") ?? 0.0,
        "manufacture_date": map["manufacture_date"]?.toString() ?? "",
        "expiry_date": map["expiry_date"]?.toString() ?? "",
        "status": map["status"]?.toString() ?? "active",
      };
    }).toList();
  }

  static List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data["data"] is List) return data["data"];
    return [];
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

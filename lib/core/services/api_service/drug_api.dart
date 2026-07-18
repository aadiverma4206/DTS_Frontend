import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class DrugApi {
  static const Duration timeout = Duration(seconds: 30);
  static Future<List<Map<String, dynamic>>> getDrugsByManufacturer(
    int manufacturerId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              "${ApiService.baseUrl}/drugs/manufacturer/$manufacturerId",
            ),

            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        if (data is Map<String, dynamic>) {
          final result = data["data"];

          if (result is List) {
            return result
                .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                .toList();
          }
        }

        return [];
      } else {
        throw Exception(_message(data, "Failed to load drugs"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } on TimeoutException {
      throw Exception("Request timeout");
    } on HttpException {
      throw Exception("Server error");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  static Future<List<Map<String, dynamic>>> getDrugsByWholesaler() async {
    try {
      final response = await http
          .get(
            Uri.parse("${ApiService.baseUrl}/drugs/my"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseList(data);
      } else {
        throw Exception(_message(data, "Failed to load drugs"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  static Future<Map<String, dynamic>> addDrug({
    required String name,
    required String dosageForm,
    required String strength,
    required String itemBrandId,
    String? composition,
    String? category,
    String? scheduleType,
    int isNarcotic = 0,
    int abuseRisk = 0,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse("${ApiService.baseUrl}/drugs"),
        headers: ApiService.headers,
        body: jsonEncode({
          "drug_name": name.trim(),
          "composition": composition?.trim().isEmpty ?? true
              ? null
              : composition!.trim(),
          "category": category?.trim().isEmpty ?? true
              ? null
              : category!.trim(),
          "dosage_form": dosageForm.trim(),
          "strength": strength.trim(),
          "is_narcotic": isNarcotic,
          "item_brand_id": itemBrandId.trim(),
          "schedule_type": scheduleType?.trim().isEmpty ?? true
              ? null
              : scheduleType!.trim(),
          "abuse_risk": abuseRisk,
        }),
      )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data is Map<String, dynamic> ? data : {};
      } else {
        throw Exception(_message(data, "Failed to add drug"));
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
  static Future<List<Map<String, dynamic>>> getAllDrugs() async {
    try {
      final response = await http
          .get(
            Uri.parse("${ApiService.baseUrl}/drugs"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseList(data);
      } else {
        throw Exception(_message(data, "Failed to fetch drugs"));
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

  static Future<List<Map<String, dynamic>>> getMyDrugs() async {
    try {
      final response = await http
          .get(
            Uri.parse("${ApiService.baseUrl}/drugs/my"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseList(data);
      } else {
        throw Exception(_message(data, "Failed to fetch my drugs"));
      }
    } catch (e) {
      throw Exception(e.toString());
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

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class WholesalerApi {
  static const Duration timeout = Duration(seconds: 30);

  static const String base = "${ApiService.baseUrl}/wholesalers";
  static Future<List<Map<String, dynamic>>> getReceivedStockHistory() async {
    try {
      final headers = await ApiService.headers;

      debugPrint("Headers => $headers");

      final response = await http
          .get(Uri.parse("$base/received-stock-history"), headers: headers)
          .timeout(timeout);

      debugPrint("Status Code => ${response.statusCode}");

      debugPrint("Response => ${response.body}");

      final data = _decode(response);

      if (response.statusCode == 200) {
        final List list = data["data"] ?? [];

        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      throw Exception(_message(data, "Failed to load received stock history"));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  static Future<Map<String, dynamic>> getWholesalerProfile() async {
    try {
      final headers = await ApiService.headers;

      debugPrint("Headers => $headers");

      final response = await http
          .get(
        Uri.parse("$base/my-profile"),
        headers: headers,
      )
          .timeout(timeout);

      debugPrint("Status Code => ${response.statusCode}");
      debugPrint("Response => ${response.body}");

      final data = _decode(response);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(data["data"] ?? {});
      }

      throw Exception(
        _message(data, "Failed to load wholesaler profile"),
      );
    } on TimeoutException {
      throw Exception(
        "Request timeout. Please check your internet connection.",
      );
    } on FormatException {
      throw Exception(
        "Invalid response received from server.",
      );
    } catch (e) {
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }
  static Future<List<Map<String, dynamic>>> getRejectedStockHistory() async {
    try {
      final headers = await ApiService.headers;

      debugPrint("Headers => $headers");

      final response = await http
          .get(Uri.parse("$base/rejected-stock-history"), headers: headers)
          .timeout(timeout);

      debugPrint("Status Code => ${response.statusCode}");

      debugPrint("Response => ${response.body}");

      final data = _decode(response);

      if (response.statusCode == 200) {
        final List list = data["data"] ?? [];

        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      throw Exception(_message(data, "Failed to load rejected stock history"));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static dynamic _decode(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    return jsonDecode(response.body);
  }

  static String _message(dynamic data, String fallback) {
    if (data is Map<String, dynamic> && data["message"] != null) {
      return data["message"].toString();
    }

    return fallback;
  }

  static Future<List<Map<String, dynamic>>> getManufacturers() async {
    try {
      final headers = await ApiService.headers;

      final response = await http
          .get(Uri.parse("$base/manufacturers"), headers: headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        final List list = data["data"] ?? [];

        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      throw Exception(_message(data, "Failed to load manufacturers"));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> getManufacturerDetails(
    int manufacturerId,
  ) async {
    try {
      final headers = await ApiService.headers;

      final response = await http
          .get(
            Uri.parse("$base/manufacturers/$manufacturerId"),
            headers: headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(data["data"] ?? {});
      }

      throw Exception(_message(data, "Failed to load manufacturer details"));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> getRetailers() async {
    try {
      final headers = await ApiService.headers;

      final response = await http
          .get(Uri.parse("$base/retailers"), headers: headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        final List list = data["data"] ?? [];

        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      throw Exception(_message(data, "Failed to load retailers"));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> getRetailerDetails(int retailerId) async {
    try {
      final headers = await ApiService.headers;

      final response = await http
          .get(Uri.parse("$base/retailers/$retailerId"), headers: headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(data["data"] ?? {});
      }

      throw Exception(_message(data, "Failed to load retailer details"));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final headers = await ApiService.headers;

      debugPrint("Headers => $headers");

      final response = await http
          .get(Uri.parse("$base/dashboard"), headers: headers)
          .timeout(timeout);

      debugPrint("Status Code => ${response.statusCode}");

      debugPrint("Response => ${response.body}");

      final data = _decode(response);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(data["data"] ?? {});
      }

      throw Exception(data["message"] ?? "Failed to load dashboard");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class RetailerApi {
  static const Duration timeout = Duration(seconds: 30);

  static String get _base => "${ApiService.baseUrl}/retailers";

  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await http
          .get(Uri.parse("$_base/dashboard"), headers: ApiService.headers)
          .timeout(const Duration(seconds: 30));

      final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200 && data["success"] == true) {
        return Map<String, dynamic>.from(data["data"] ?? {});
      }

      throw Exception(data["message"] ?? "Failed to load dashboard");
    } on SocketException {
      throw Exception("No internet connection");
    } on TimeoutException {
      throw Exception("Request timeout");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> getStock() async {
    try {
      final response = await http
          .get(Uri.parse("$_base/stock"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseStock(data);
      } else {
        throw Exception(_message(data, "Failed to fetch stock"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> getStockDetail(int batchId) async {
    try {
      if (batchId <= 0) {
        throw Exception("Invalid batch id");
      }

      final response = await http
          .get(Uri.parse("$_base/stock/$batchId"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(data["data"] ?? {});
      }

      throw Exception(_message(data, "Failed to load stock details"));
    } on SocketException {
      throw Exception("No internet connection");
    } on TimeoutException {
      throw Exception("Request timeout");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http
          .get(Uri.parse("$_base/profile"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return data is Map<String, dynamic> ? data : {};
      } else {
        throw Exception(_message(data, "Failed to load profile"));
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<bool> hasProfile() async {
    final res = await getProfile();
    return res["data"] != null;
  }

  static Future<Map<String, dynamic>> sellProduct({
    required List<Map<String, dynamic>> items,
    required String patientName,
    required String abhaId,
    required String paymentMode,
    String? patientMobile,
    String? doctorName,
  }) async {
    try {
      const validModes = ["Cash", "Online", "Card"];

      if (!validModes.contains(paymentMode)) {
        throw Exception("Invalid payment mode");
      }

      if (patientName.trim().isEmpty) {
        throw Exception("Patient name is required");
      }

      if (abhaId.trim().isEmpty) {
        throw Exception("ABHA ID is required");
      }

      if (items.isEmpty) {
        throw Exception("Please add at least one product");
      }

      final formattedItems = items.map((e) {
        final batchId = int.tryParse(e["batch_id"].toString()) ?? 0;

        final quantity = int.tryParse(e["quantity"].toString()) ?? 0;

        final price = double.tryParse(e["price"].toString()) ?? 0;

        if (batchId <= 0 || quantity <= 0 || price <= 0) {
          throw Exception("Invalid item data");
        }

        return {"batch_id": batchId, "quantity": quantity, "price": price};
      }).toList();

      final body = {
        "items": formattedItems,
        "payment_mode": paymentMode,
        "patient_name": patientName.trim(),
        "abha_id": abhaId.trim(),
        if (patientMobile != null && patientMobile.trim().isNotEmpty)
          "patient_mobile": patientMobile.trim(),
        if (doctorName != null && doctorName.trim().isNotEmpty)
          "doctor_name": doctorName.trim(),
      };

      final response = await http
          .post(
            Uri.parse("$_base/sell"),
            headers: ApiService.headers,
            body: jsonEncode(body),
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map<String, dynamic>) {
          return data;
        }

        return {"success": true};
      }

      final message = _message(data, "Sale failed");

      throw Exception(message);
    } on SocketException {
      throw Exception("No internet connection");
    } on TimeoutException {
      throw Exception("Request timeout");
    } on HttpException {
      throw Exception("Server error");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      final msg = e.toString().replaceAll("Exception:", "").trim();

      throw Exception(msg);
    }
  }

  static Future<List<Map<String, dynamic>>> getSaleHistory() async {
    try {
      final response = await http
          .get(Uri.parse("$_base/sales"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        final list = _extractList(data);

        return list.map<Map<String, dynamic>>((e) {
          final map = Map<String, dynamic>.from(e);

          return {
            "patient_name": map["patient_name"] ?? "",
            "patient_mobile": map["patient_mobile"] ?? "",
            "doctor_name": map["doctor_name"] ?? "",
            "abha_id": map["abha_id"] ?? "",
            "payment_mode": map["payment_mode"] ?? "",
            "manufacturer_name": map["manufacturer_name"] ?? "",
            "created_at": map["created_at"] ?? "",
            "total_amount":
                double.tryParse(map["total_amount"].toString()) ?? 0.0,

            "drugs": List<Map<String, dynamic>>.from(
              (map["drugs"] ?? []).map(
                (drug) => {
                  "sale_id": drug["sale_id"],
                  "batch_id": drug["batch_id"],
                  "batch_no": drug["batch_no"] ?? "",
                  "drug_id": drug["drug_id"],
                  "drug_name": drug["drug_name"] ?? "",
                  "strength": drug["strength"] ?? "",
                  "dosage_form": drug["dosage_form"] ?? "",
                  "quantity": int.tryParse(drug["quantity"].toString()) ?? 0,
                  "price": double.tryParse(drug["price"].toString()) ?? 0.0,
                  "total_amount":
                      double.tryParse(drug["total_amount"].toString()) ?? 0.0,
                },
              ),
            ),
          };
        }).toList();
      } else {
        throw Exception(_message(data, "Failed to load sales"));
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  static Future<Map<String, dynamic>> getRetailerProfile() async {
    try {
      final response = await http
          .get(
        Uri.parse("$_base/my-profile"),
        headers: ApiService.headers,
      )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(data["data"] ?? {});
      }

      throw Exception(
        _message(data, "Failed to load retailer profile"),
      );
    } on SocketException {
      throw Exception("No internet connection");
    } on TimeoutException {
      throw Exception("Request timeout");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }
  static Future<List<Map<String, dynamic>>> getManufacturers() async {
    try {
      final response = await http
          .get(Uri.parse("$_base/manufacturers"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        final list = _extractList(data);

        return list
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      throw Exception(_message(data, "Failed to load manufacturers"));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> getWholesalers() async {
    try {
      final response = await http
          .get(Uri.parse("$_base/wholesalers"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        final list = _extractList(data);

        return list
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      throw Exception(_message(data, "Failed to load wholesalers"));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> getWholesalerDetails(
    int wholesalerId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse("$_base/wholesalers/$wholesalerId"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(data["data"] ?? {});
      }

      throw Exception(_message(data, "Failed to load wholesaler details"));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> getManufacturerDetails(
    int manufacturerId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse("$_base/manufacturers/$manufacturerId"),
            headers: ApiService.headers,
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

  static Future<List<Map<String, dynamic>>> getPatients() async {
    try {
      final response = await http
          .get(Uri.parse("$_base/patients"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        final list = _extractList(data);

        return list
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      throw Exception(_message(data, "Failed to load patients"));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Map<String, dynamic>> getPatientDetails(
    String patientMobile,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse("$_base/patients/$patientMobile"),
            headers: ApiService.headers,
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(data["data"] ?? {});
      }

      throw Exception(_message(data, "Failed to load patient details"));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static List<Map<String, dynamic>> _parseStock(dynamic data) {
    final list = _extractList(data);

    return list.map<Map<String, dynamic>>((e) {
      final map = Map<String, dynamic>.from(e);
      return {
        "batch_id": int.tryParse(map["batch_id"]?.toString() ?? "") ?? 0,
        "quantity": int.tryParse(map["quantity"]?.toString() ?? "") ?? 0,
        "drug_name": map["drug_name"]?.toString() ?? "",
        "batch_no": map["batch_no"]?.toString() ?? "",
        "mrp": map["mrp"]?.toString() ?? "",
        "expiry_date": map["expiry_date"]?.toString() ?? "",
        "manufacturer_name": map["manufacturer_name"]?.toString() ?? "",
        "composition": map["composition"]?.toString() ?? "",
        "category": map["category"]?.toString() ?? "",
        "dosage_form": map["dosage_form"]?.toString() ?? "",
        "strength": map["strength"]?.toString() ?? "",
      };
    }).toList();
  }

  static List<Map<String, dynamic>> _parseHistory(dynamic data) {
    final list = _extractList(data);

    return list.map<Map<String, dynamic>>((e) {
      final map = Map<String, dynamic>.from(e);
      return {
        "batch_id": int.tryParse(map["batch_id"]?.toString() ?? "") ?? 0,
        "change_qty": int.tryParse(map["change_qty"]?.toString() ?? "") ?? 0,
        "drug_name": map["drug_name"]?.toString() ?? "",
        "batch_no": map["batch_no"]?.toString() ?? "",
        "created_at": map["created_at"]?.toString() ?? "",
        "movement_type": map["movement_type"]?.toString() ?? "",
      };
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

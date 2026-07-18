import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../api_service.dart';

class ManufacturerFormApi {
  static const Duration timeout = Duration(seconds: 30);

  static Future<Map<String, dynamic>> createManufacturer({
    required String companyName,
    required String gstin,
    required String drugLicenseNo,
    required String address,
    String? panNo,
    String? cinNo,
    String? phone,
    String? email,
    String? website,
    String? productInfo,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse("${ApiService.baseUrl}/manufacturers"),
        headers: {
          ...ApiService.headers,
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "company_name": companyName.trim(),
          "gstin": gstin.trim(),
          "drug_license_no": drugLicenseNo.trim(),
          "address": address.trim(),
          "pan_no": (panNo?.trim().isEmpty ?? true) ? null : panNo?.trim(),
          "cin_no": (cinNo?.trim().isEmpty ?? true) ? null : cinNo?.trim(),
          "phone": (phone?.trim().isEmpty ?? true) ? null : phone?.trim(),
          "email": (email?.trim().isEmpty ?? true) ? null : email?.trim(),
          "website": (website?.trim().isEmpty ?? true) ? null : website?.trim(),
          "product_info": (productInfo?.trim().isEmpty ?? true) ? null : productInfo?.trim(),
        }),
      )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map<String, dynamic>) return data;
        return {};
      } else {
        throw Exception(_message(data, "Failed to create manufacturer"));
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

  static dynamic _decode(http.Response response) {
    try {
      if (response.body.isEmpty) return null;
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
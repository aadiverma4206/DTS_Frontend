import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
class ManufacturerApi {
  static Future<List<Map<String, dynamic>>> getMyManufacturers() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/manufacturers"),
        headers: ApiService.headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data is Map && data["data"] is List) {
          return (data["data"] as List)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        return [];
      } else {
        throw Exception(data["message"] ?? "Failed to load manufacturers");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
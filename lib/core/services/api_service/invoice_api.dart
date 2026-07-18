import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class InvoiceApi {
  static const Duration timeout = Duration(seconds: 30);

  static String get base => "${ApiService.baseUrl}/invoices";
  static Future<List<Map<String, dynamic>>> getInvoicesByBuyer(
    int buyerId,
  ) async {
    try {
      final response = await http
          .get(Uri.parse("$base/buyer/$buyerId"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseInvoiceList(data);
      } else {
        throw Exception(_message(data, "Failed to fetch invoices"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } on TimeoutException {
      throw Exception("Request timeout");
    } catch (e) {
      throw Exception("Invoice load failed: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getBuyers() async {
    try {
      final response = await http
          .get(Uri.parse("$base/buyers"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseBuyerList(data);
      } else {
        throw Exception(_message(data, "Failed to fetch buyers"));
      }
    } on SocketException {
      throw Exception("No internet connection");
    } catch (_) {
      throw Exception("Buyer load failed");
    }
  }

  static Future<Map<String, dynamic>> createInvoice({
    required String receiverRole,
    required int receiverId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      if (receiverId <= 0) {
        throw Exception("Invalid receiver");
      }

      if (items.isEmpty) {
        throw Exception("Please add at least one item");
      }

      final formattedItems = items.map((e) {
        final batchId = int.tryParse(e["batch_id"].toString()) ?? 0;

        final quantity = int.tryParse(e["quantity"].toString()) ?? 0;

        final price = double.tryParse(e["price"].toString()) ?? 0.0;

        if (batchId <= 0 || quantity <= 0 || price <= 0) {
          throw Exception("Invalid invoice item");
        }

        return {"batch_id": batchId, "quantity": quantity, "price": price};
      }).toList();

      final response = await http
          .post(
            Uri.parse(base),

            headers: ApiService.headers,

            body: jsonEncode({
              "receiver_id": receiverId,

              "receiver_role": receiverRole,

              "items": formattedItems,
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
        throw Exception(_message(data, "Invoice failed"));
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

  static Future<List<Map<String, dynamic>>> getInvoices() async {
    try {
      final response = await http
          .get(Uri.parse(base), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseInvoiceList(data);
      } else {
        throw Exception(_message(data, "Failed to fetch invoices"));
      }
    } catch (_) {
      throw Exception("Invoice load failed");
    }
  }

  static Future<List<Map<String, dynamic>>> getIncomingInvoices() async {
    try {
      final response = await http
          .get(Uri.parse("$base/incoming"), headers: ApiService.headers)
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        return _parseInvoiceList(data);
      } else {
        throw Exception(_message(data, "Failed to fetch incoming invoices"));
      }
    } catch (_) {
      throw Exception("Incoming invoice load failed");
    }
  }
  static Future<Map<String, dynamic>> getInvoiceDetails(int invoiceId) async {
    try {
      final response = await http
          .get(
        Uri.parse("$base/$invoiceId/details"),
        headers: ApiService.headers,
      )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        if (data is Map<String, dynamic>) {
          return {
            "success": data["success"] ?? true,

            "invoice": Map<String, dynamic>.from(
              data["invoice"] ?? {},
            ),

            "wholesaler": Map<String, dynamic>.from(
              data["wholesaler"] ?? {},
            ),

            "retailer": Map<String, dynamic>.from(
              data["retailer"] ?? {},
            ),

            "summary": Map<String, dynamic>.from(
              data["summary"] ?? {},
            ),

            "items": (data["items"] is List)
                ? (data["items"] as List)
                .map<Map<String, dynamic>>((e) {
              final m = Map<String, dynamic>.from(e);

              return {
                "item_id":
                int.tryParse(
                  m["item_id"]?.toString() ?? "0",
                ) ??
                    0,

                "batch_id":
                int.tryParse(
                  m["batch_id"]?.toString() ?? "0",
                ) ??
                    0,

                "drug_id":
                int.tryParse(
                  m["drug_id"]?.toString() ?? "0",
                ) ??
                    0,

                "manufacturer_id":
                int.tryParse(
                  m["manufacturer_id"]?.toString() ?? "0",
                ) ??
                    0,

                "drug_name":
                m["drug_name"]?.toString() ?? "",

                "composition":
                m["composition"]?.toString() ?? "",

                "category":
                m["category"]?.toString() ?? "",

                "strength":
                m["strength"]?.toString() ?? "",

                "dosage_form":
                m["dosage_form"]?.toString() ?? "",

                "is_narcotic":
                m["is_narcotic"] == 1 ||
                    m["is_narcotic"] == true,

                "batch_no":
                m["batch_no"]?.toString() ?? "",

                "manufacture_date":
                m["manufacture_date"]?.toString() ?? "",

                "expiry_date":
                m["expiry_date"]?.toString() ?? "",

                "quantity":
                int.tryParse(
                  m["quantity"]?.toString() ?? "0",
                ) ??
                    0,

                "mrp":
                double.tryParse(
                  m["mrp"]?.toString() ?? "0",
                ) ??
                    0.0,

                "purchase_price":
                double.tryParse(
                  m["purchase_price"]?.toString() ?? "0",
                ) ??
                    0.0,

                "selling_price":
                double.tryParse(
                  m["selling_price"]?.toString() ?? "0",
                ) ??
                    0.0,

                "total":
                double.tryParse(
                  m["total"]?.toString() ?? "0",
                ) ??
                    0.0,

                "manufacturer_name":
                m["manufacturer_name"]?.toString() ?? "",

                "manufacturer_dl_no":
                m["manufacturer_dl_no"]?.toString() ?? "",

                "manufacturer_phone":
                m["manufacturer_phone"]?.toString() ?? "",

                "manufacturer_email":
                m["manufacturer_email"]?.toString() ?? "",
              };
            })
                .toList()
                : [],
          };
        }

        return {
          "success": false,
          "message": "Invalid response format",
        };
      } else {
        throw Exception(
          _message(data, "Failed to fetch invoice details"),
        );
      }
    } catch (e) {
      throw Exception(
        e.toString().replaceAll("Exception:", "").trim(),
      );
    }
  }
  static Future<String> updateInvoiceStatus({
    required int invoiceId,
    required String status,
  }) async {
    try {
      if (invoiceId <= 0) {
        throw Exception("Invalid invoice id");
      }

      final formattedStatus = status.trim().toLowerCase();

      if (formattedStatus != "accepted" && formattedStatus != "rejected") {
        throw Exception("Invalid status");
      }

      final response = await http
          .patch(
            Uri.parse("$base/$invoiceId/status"),

            headers: ApiService.headers,

            body: jsonEncode({"status": formattedStatus}),
          )
          .timeout(timeout);

      final data = _decode(response);

      if (response.statusCode == 200) {
        if (data is Map<String, dynamic>) {
          return data["message"]?.toString() ?? "Success";
        }

        return "Success";
      } else {
        throw Exception(_message(data, "Failed to update invoice status"));
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

  static List<Map<String, dynamic>> _parseInvoiceList(dynamic data) {
    if (data is List) {
      return data
          .map<Map<String, dynamic>>((e) {
            final m = Map<String, dynamic>.from(e);

            return {
              "invoice_id":
                  int.tryParse(m["invoice_id"]?.toString() ?? "") ?? 0,

              "invoice_number": m["invoice_number"]?.toString() ?? "",

              "total_amount":
                  double.tryParse(m["total_amount"]?.toString() ?? "0") ?? 0,

              "invoice_date": m["invoice_date"]?.toString() ?? "",

              "created_at": m["created_at"]?.toString() ?? "",

              "status": m["status"]?.toString().toLowerCase() ?? "pending",

              // NEW FIELDS
              "wholesaler_name": m["wholesaler_name"]?.toString() ?? "",

              "shop_name": m["shop_name"]?.toString() ?? "",

              "drug_license_no": m["drug_license_no"]?.toString() ?? "",

              "phone": m["phone"]?.toString() ?? "",

              "email": m["email"]?.toString() ?? "",
            };
          })
          .where((e) => e["invoice_id"] != 0)
          .toList();
    }

    if (data is Map && data["data"] is List) {
      return _parseInvoiceList(data["data"]);
    }

    return [];
  }

  static List<Map<String, dynamic>> _parseBuyerList(dynamic data) {
    if (data is List) {
      return data
          .map<Map<String, dynamic>>((e) {
            final m = Map<String, dynamic>.from(e);
            return {
              "user_id": int.tryParse(m["user_id"]?.toString() ?? "0") ?? 0,
              "name": m["name"]?.toString() ?? "",
            };
          })
          .where((e) => e["user_id"] != 0)
          .toList();
    }

    if (data is Map && data["data"] is List) {
      return _parseBuyerList(data["data"]);
    }

    return [];
  }

  static List<Map<String, dynamic>> _parseDetails(dynamic data) {
    if (data is List) {
      return data.map<Map<String, dynamic>>((e) {
        final map = Map<String, dynamic>.from(e);
        map["quantity"] = int.tryParse(map["quantity"]?.toString() ?? "0") ?? 0;
        map["price"] = double.tryParse(map["price"]?.toString() ?? "0") ?? 0;
        map["total"] = double.tryParse(map["total"]?.toString() ?? "0") ?? 0;
        return map;
      }).toList();
    }

    if (data is Map && data["data"] is List) {
      return _parseDetails(data["data"]);
    }

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

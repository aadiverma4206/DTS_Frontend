import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/services/api_service/inspection_api.dart';

class DrugWRController extends GetxController {
  DrugWRController({required this.drugId, required this.drugName});

  final int drugId;
  final String drugName;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedType = 'all'.obs;

  final TextEditingController searchController = TextEditingController();

  final RxList<Map<String, dynamic>> holders = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredHolders =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHolders();
  }

  Future<void> loadHolders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await InspectionApi.getDrugHolders(
        drugId: drugId,
        type: selectedType.value,
      );

      holders.assignAll(response);
      filteredHolders.assignAll(response);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
      holders.clear();
      filteredHolders.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async => loadHolders();

  Future<void> changeType(String type) async {
    if (selectedType.value == type) return;
    selectedType.value = type;
    searchController.clear();
    await loadHolders();
  }

  void search(String value) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) {
      filteredHolders.assignAll(holders);
      return;
    }
    filteredHolders.assignAll(
      holders.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        final company = (item['company_name'] ?? '').toString().toLowerCase();
        final shop = (item['shop_name'] ?? '').toString().toLowerCase();
        final dl = (item['drug_license_no'] ?? '').toString().toLowerCase();
        return name.contains(query) ||
            company.contains(query) ||
            shop.contains(query) ||
            dl.contains(query);
      }).toList(),
    );
  }

  Future<void> downloadPdf() async {
    final pdf = pw.Document();
    final items = filteredHolders;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return [
            pw.Text(
              '$drugName — Holder Report',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Type: ${selectedType.value.toUpperCase()}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 16),
            ...items.map((item) {
              final ws = isWholesaler(item);
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 14),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      getName(item),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(getBusinessName(item)),
                    pw.Text('DL: ${getLicense(item)}'),
                    pw.Text('Type: ${getUserType(item).toUpperCase()}'),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text('Received: ${getReceivedQty(item)}'),
                        ),
                        pw.Expanded(
                          child: pw.Text('Available: ${getAvailableQty(item)}'),
                        ),
                        pw.Expanded(
                          child: ws
                              ? pw.Text('Supplied: ${getSuppliedQty(item)}')
                              : pw.Text('Sold: ${getSoldQty(item)}'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: '${drugName}_holders_report.pdf',
    );
  }

  String getBusinessName(Map<String, dynamic> item) {
    final company = (item['company_name'] ?? '').toString();
    final shop = (item['shop_name'] ?? '').toString();
    return company.isNotEmpty ? company : shop;
  }

  String getName(Map<String, dynamic> item) => (item['name'] ?? '').toString();

  String getLicense(Map<String, dynamic> item) =>
      (item['drug_license_no'] ?? '').toString();

  String getUserType(Map<String, dynamic> item) =>
      (item['user_type'] ?? '').toString();

  int getUserId(Map<String, dynamic> item) =>
      int.tryParse(item['user_id'].toString()) ?? 0;

  int getReceivedQty(Map<String, dynamic> item) =>
      int.tryParse(item['total_received_qty'].toString()) ?? 0;

  int getSuppliedQty(Map<String, dynamic> item) =>
      int.tryParse(item['total_supplied_qty'].toString()) ?? 0;

  int getAvailableQty(Map<String, dynamic> item) =>
      int.tryParse(item['available_qty'].toString()) ?? 0;

  int getSoldQty(Map<String, dynamic> item) =>
      int.tryParse(item['sold_qty'].toString()) ?? 0;

  bool isWholesaler(Map<String, dynamic> item) =>
      getUserType(item) == 'wholesaler';

  bool isRetailer(Map<String, dynamic> item) => getUserType(item) == 'retailer';

  String getSupplyFlow(Map<String, dynamic> item) => isWholesaler(item)
      ? 'Manufacturer → Wholesaler'
      : 'Wholesaler → Retailer';

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service/inspection_api.dart';

enum DetailTab { all, stock, batch, purchase, supply, sale }

extension DetailTabLabel on DetailTab {
  String get label {
    switch (this) {
      case DetailTab.all:
        return 'All';
      case DetailTab.stock:
        return 'Stock';
      case DetailTab.batch:
        return 'Batch';
      case DetailTab.purchase:
        return 'Purchase';
      case DetailTab.supply:
        return 'Supply';
      case DetailTab.sale:
        return 'Sale';
    }
  }

  IconData get icon {
    switch (this) {
      case DetailTab.all:
        return Icons.grid_view_rounded;
      case DetailTab.stock:
        return Icons.inventory_2_rounded;
      case DetailTab.batch:
        return Icons.qr_code_rounded;
      case DetailTab.purchase:
        return Icons.download_rounded;
      case DetailTab.supply:
        return Icons.upload_rounded;
      case DetailTab.sale:
        return Icons.point_of_sale_rounded;
    }
  }
}

class DrugWRDetailsController extends GetxController {
  DrugWRDetailsController({
    required this.drugId,
    required this.userId,
    required this.drugName,
    required this.userType,
  });

  final int drugId;
  final int userId;
  final String drugName;
  final String userType;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final holder = <String, dynamic>{}.obs;
  final summary = <String, dynamic>{}.obs;

  final stockBatches = <Map<String, dynamic>>[].obs;
  final purchaseHistory = <Map<String, dynamic>>[].obs;
  final supplyHistory = <Map<String, dynamic>>[].obs;
  final salesHistory = <Map<String, dynamic>>[].obs;

  final totalAvailable = 0.obs;
  final totalSold = 0.obs;
  final expiredQty = 0.obs;
  final receivedQty = 0.obs;
  final suppliedQty = 0.obs;

  final selectedTab = DetailTab.all.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  bool get isWholesaler => userType.toLowerCase().trim() == 'wholesaler';
  bool get isRetailer => userType.toLowerCase().trim() == 'retailer';

  List<DetailTab> get visibleTabs {
    final base = [
      DetailTab.all,
      DetailTab.stock,
      DetailTab.batch,
      DetailTab.purchase,
    ];
    if (isWholesaler) base.add(DetailTab.supply);
    if (isRetailer) base.add(DetailTab.sale);
    return base;
  }

  List<Map<String, dynamic>> get filteredBatches {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return stockBatches;
    return stockBatches.where((b) {
      return batchNumber(b).toLowerCase().contains(q) ||
          manufacturerName(b).toLowerCase().contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get filteredPurchase {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return purchaseHistory;
    return purchaseHistory.where((e) {
      return invoiceNumber(e).toLowerCase().contains(q) ||
          supplierName(e).toLowerCase().contains(q) ||
          batchNoFromHistory(e).toLowerCase().contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get filteredSupply {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return supplyHistory;
    return supplyHistory.where((e) {
      return invoiceNumber(e).toLowerCase().contains(q) ||
          supplierName(e).toLowerCase().contains(q) ||
          batchNoFromHistory(e).toLowerCase().contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get filteredSales {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return salesHistory;
    return salesHistory.where((e) {
      return supplierName(e).toLowerCase().contains(q) ||
          patientMobile(e).toLowerCase().contains(q) ||
          batchNoFromHistory(e).toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadDetails();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void changeTab(DetailTab tab) => selectedTab.value = tab;

  void onSearch(String query) => searchQuery.value = query.trim();

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  Future<void> refreshData() => loadDetails();

  Future<void> downloadPdf() async {
    // TODO: implement PDF download via InspectionApi
    Get.snackbar(
      'PDF',
      'Generating PDF report...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4338CA),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> loadDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await InspectionApi.getDrugHolderDetails(
        drugId: drugId,
        userId: userId,
      );

      final data = Map<String, dynamic>.from(response['data'] ?? {});

      holder.assignAll(Map<String, dynamic>.from(data['holder'] ?? {}));
      summary.assignAll(Map<String, dynamic>.from(data['summary'] ?? {}));

      receivedQty.value = _toInt(summary['received_qty']);
      suppliedQty.value = _toInt(summary['supplied_qty']);
      totalAvailable.value = _toInt(summary['available_qty']);
      totalSold.value = _toInt(summary['sold_qty']);
      expiredQty.value = _toInt(summary['expired_qty']);

      final manufacturers = (data['manufacturer_batches'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final batches = <Map<String, dynamic>>[];
      for (final mfr in manufacturers) {
        final mfrBatches = (mfr['batches'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        for (final batch in mfrBatches) {
          batch['manufacturer_name'] = mfr['manufacturer_name'] ?? '';
          batch['manufacturer_dl'] = mfr['manufacturer_dl'] ?? '';
          batch['manufacturer_gstin'] = mfr['manufacturer_gstin'] ?? '';
          batch['manufacturer_id'] = mfr['manufacturer_id'];
          batches.add(batch);
        }
      }
      stockBatches.assignAll(batches);

      purchaseHistory.assignAll(
        (data['purchase_history'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
      supplyHistory.assignAll(
        (data['supply_history'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
      salesHistory.assignAll(
        (data['sales_history'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
    } catch (e, st) {
      debugPrint('DrugWRDetailsController error: $e\n$st');
      errorMessage.value = _friendlyError(e);
    } finally {
      isLoading.value = false;
    }
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Network')) {
      return 'No internet connection. Please check your network.';
    }
    if (msg.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    if (msg.contains('404')) return 'Data not found.';
    if (msg.contains('401') || msg.contains('403')) {
      return 'Authentication error. Please login again.';
    }
    if (msg.contains('500')) return 'Server error. Please try again later.';
    return 'Something went wrong. Please try again.';
  }

  String get name => (holder['name'] ?? '').toString();
  String get email => (holder['email'] ?? '').toString();
  String get mobile => (holder['mobile'] ?? '').toString();
  String get companyName => (holder['company_name'] ?? '').toString();
  String get shopName => (holder['shop_name'] ?? '').toString();
  String get businessName => companyName.isNotEmpty ? companyName : shopName;

  String get gstin {
    final ws = (holder['gstin'] ?? '').toString();
    final rt = (holder['retailer_gstin'] ?? '').toString();
    return ws.isNotEmpty ? ws : rt;
  }

  String get drugLicense {
    final ws = (holder['drug_license_no'] ?? '').toString();
    final rt = (holder['retailer_dl'] ?? '').toString();
    return ws.isNotEmpty ? ws : rt;
  }

  String get address {
    final ws = (holder['address'] ?? '').toString();
    final rt = (holder['retailer_address'] ?? '').toString();
    return ws.isNotEmpty ? ws : rt;
  }

  int batchAvailableQty(Map<String, dynamic> b) => _toInt(b['available_qty']);
  int batchReceivedQty(Map<String, dynamic> b) => _toInt(b['received_qty']);
  int batchSuppliedQty(Map<String, dynamic> b) => _toInt(b['supplied_qty']);
  String batchNumber(Map<String, dynamic> b) =>
      (b['batch_no'] ?? '').toString();
  String batchExpiry(Map<String, dynamic> b) =>
      (b['expiry_date'] ?? '').toString();
  String batchManufacture(Map<String, dynamic> b) =>
      (b['manufacture_date'] ?? '').toString();
  String batchMrp(Map<String, dynamic> b) => (b['mrp'] ?? '').toString();
  String batchPurchasePrice(Map<String, dynamic> b) =>
      (b['purchase_price'] ?? '').toString();
  String manufacturerName(Map<String, dynamic> b) =>
      (b['manufacturer_name'] ?? '').toString();
  String manufacturerDL(Map<String, dynamic> b) =>
      (b['manufacturer_dl'] ?? '').toString();
  String manufacturerGST(Map<String, dynamic> b) =>
      (b['manufacturer_gstin'] ?? '').toString();

  String invoiceNumber(Map<String, dynamic> item) =>
      (item['invoice_number'] ?? '').toString();
  String invoiceDate(Map<String, dynamic> item) =>
      (item['invoice_date'] ?? item['sale_date'] ?? '').toString();
  String supplierName(Map<String, dynamic> item) =>
      (item['wholesaler_name'] ??
              item['retailer_name'] ??
              item['patient_name'] ??
              '')
          .toString();
  String supplierCompany(Map<String, dynamic> item) =>
      (item['company_name'] ?? item['shop_name'] ?? '').toString();
  String batchNoFromHistory(Map<String, dynamic> item) =>
      (item['batch_no'] ?? '').toString();
  int quantityFromHistory(Map<String, dynamic> item) =>
      _toInt(item['quantity']);
  String patientMobile(Map<String, dynamic> item) =>
      (item['mobile'] ?? '').toString();
  String patientAbha(Map<String, dynamic> item) =>
      (item['abha_id'] ?? '').toString();
}

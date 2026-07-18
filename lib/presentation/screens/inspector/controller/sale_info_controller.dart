import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service/inspection_api.dart';

class SaleInfoController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedType = 'retailer'.obs;
  final RxBool hasSearchText = false.obs; // ← for suffix icon reactivity

  final TextEditingController searchController = TextEditingController();

  final RxList<Map<String, dynamic>> sales = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredSales =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSales();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchSales() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      List<Map<String, dynamic>> result;

      if (selectedType.value == 'all') {
        // Fetch both and merge
        final retailers =
        await InspectionApi.getSalesList(type: 'retailer');
        final wholesalers =
        await InspectionApi.getSalesList(type: 'wholesaler');

        // Tag each item with its type so cards can show correct chip
        for (var item in retailers) {
          item['type'] = 'retailer';
        }
        for (var item in wholesalers) {
          item['type'] = 'wholesaler';
        }

        result = [...retailers, ...wholesalers];
      } else {
        result = await InspectionApi.getSalesList(type: selectedType.value);
        for (var item in result) {
          item['type'] = selectedType.value;
        }
      }

      sales.assignAll(result);
      _applySearch(searchController.text.trim());
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchSales();
  }

  Future<void> changeType(String type) async {
    if (selectedType.value == type) return;
    selectedType.value = type;
    searchController.clear();
    hasSearchText.value = false;
    await fetchSales();
  }

  void onSearch(String value) {
    hasSearchText.value = value.isNotEmpty;
    _applySearch(value.trim());
  }

  void clearSearch() {
    searchController.clear();
    hasSearchText.value = false;
    _applySearch('');
  }

  void _applySearch(String query) {
    final q = query.toLowerCase();
    if (q.isEmpty) {
      filteredSales.assignAll(sales);
      return;
    }
    filteredSales.assignAll(
      sales.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        final business =
        (item['business_name'] ?? '').toString().toLowerCase();
        final dlNo = (item['drug_license_no'] ?? '').toString().toLowerCase();
        return name.contains(q) ||
            business.contains(q) ||
            dlNo.contains(q);
      }).toList(),
    );
  }

  int getUserId(Map<String, dynamic> item) {
    return int.tryParse(item['user_id'].toString()) ?? 0;
  }

  String getBusinessName(Map<String, dynamic> item) {
    return item['business_name']?.toString() ?? '';
  }
}

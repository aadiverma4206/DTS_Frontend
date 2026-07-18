import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service/inspection_api.dart';

class WholesalerInfoController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxList<Map<String, dynamic>> wholesalers = <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> filteredWholesalers =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(filterData);

    loadWholesalers();
  }

  Future<void> loadWholesalers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await InspectionApi.getWholesalers();

      wholesalers.clear();
      filteredWholesalers.clear();

      wholesalers.assignAll(List<Map<String, dynamic>>.from(data));

      filteredWholesalers.assignAll(List<Map<String, dynamic>>.from(data));

      debugPrint('Wholesalers Loaded : ${wholesalers.length}');

      for (final item in wholesalers) {
        debugPrint(item.toString());
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void filterData() {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      filteredWholesalers.assignAll(wholesalers);
      return;
    }

    final result = wholesalers.where((item) {
      final name = item['name']?.toString().toLowerCase() ?? '';

      final companyName = item['company_name']?.toString().toLowerCase() ?? '';

      final dlNo = item['drug_license_no']?.toString().toLowerCase() ?? '';

      return name.contains(query) ||
          companyName.contains(query) ||
          dlNo.contains(query);
    }).toList();

    filteredWholesalers.assignAll(result);
  }

  Future<void> refreshData() async {
    await loadWholesalers();
  }

  int getUserId(Map<String, dynamic> item) {
    final dynamic value = item['user_id'];

    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

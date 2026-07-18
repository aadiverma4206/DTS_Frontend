import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service/inspection_api.dart';

class RetailerInfoController extends GetxController {
  final searchController = TextEditingController();

  final retailers = <Map<String, dynamic>>[].obs;
  final filteredRetailers = <Map<String, dynamic>>[].obs;

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRetailers();
    searchController.addListener(filterData);
  }

  Future<void> loadRetailers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await InspectionApi.getRetailers();

      retailers.assignAll(data);
      filteredRetailers.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void filterData() {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      filteredRetailers.assignAll(retailers);
      return;
    }

    filteredRetailers.assignAll(
      retailers.where((item) {
        final name =
        (item['name'] ?? '').toString().toLowerCase();

        final shop =
        (item['shop_name'] ?? '').toString().toLowerCase();

        final dl =
        (item['drug_license_no'] ?? '')
            .toString()
            .toLowerCase();

        return name.contains(query) ||
            shop.contains(query) ||
            dl.contains(query);
      }).toList(),
    );
  }

  Future<void> refreshData() async {
    await loadRetailers();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
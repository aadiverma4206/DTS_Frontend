import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service/wholesaler_api.dart';

class RetailerListController extends GetxController {
  final isLoading = false.obs;

  final retailers = <Map<String, dynamic>>[].obs;
  final filteredRetailers = <Map<String, dynamic>>[].obs;

  final searchController = TextEditingController();

  @override
  void onInit() {
    loadRetailers();
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadRetailers() async {
    try {
      isLoading.value = true;

      final data = await WholesalerApi.getRetailers();

      retailers.assignAll(data);
      filteredRetailers.assignAll(data);
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchRetailers(String query) {
    if (query.trim().isEmpty) {
      filteredRetailers.assignAll(retailers);
      return;
    }

    final searchText = query.toLowerCase().trim();

    final result = retailers.where((retailer) {
      final retailerName =
      (retailer["retailer_name"] ?? "")
          .toString()
          .toLowerCase();

      final shopName =
      (retailer["shop_name"] ?? "")
          .toString()
          .toLowerCase();

      final dlNumber =
      (retailer["drug_license_no"] ?? "")
          .toString()
          .toLowerCase();

      return retailerName.contains(searchText) ||
          shopName.contains(searchText) ||
          dlNumber.contains(searchText);
    }).toList();

    filteredRetailers.assignAll(result);
  }

  void clearSearch() {
    searchController.clear();
    filteredRetailers.assignAll(retailers);
  }
}
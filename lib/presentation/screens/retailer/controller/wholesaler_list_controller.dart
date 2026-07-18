import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service/retailer_api.dart';

class WholesalerListController extends GetxController {
  final isLoading = false.obs;

  final wholesalers = <Map<String, dynamic>>[].obs;
  final filteredWholesalers = <Map<String, dynamic>>[].obs;

  final searchController = TextEditingController();

  @override
  void onInit() {
    loadWholesalers();
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadWholesalers() async {
    try {
      isLoading.value = true;

      final data =
      await RetailerApi.getWholesalers();

      wholesalers.assignAll(data);
      filteredWholesalers.assignAll(data);
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchWholesalers(String query) {
    if (query.trim().isEmpty) {
      filteredWholesalers.assignAll(
        wholesalers,
      );
      return;
    }

    final search =
    query.toLowerCase().trim();

    filteredWholesalers.assignAll(
      wholesalers.where((item) {
        final name =
        (item["name"] ?? "")
            .toString()
            .toLowerCase();

        final shop =
        (item["company_name"] ?? "")
            .toString()
            .toLowerCase();

        final dl =
        (item["drug_license_no"] ?? "")
            .toString()
            .toLowerCase();

        return name.contains(search) ||
            shop.contains(search) ||
            dl.contains(search);
      }).toList(),
    );
  }

  void clearSearch() {
    searchController.clear();
    filteredWholesalers.assignAll(
      wholesalers,
    );
  }
}
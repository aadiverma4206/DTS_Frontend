import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service/retailer_api.dart';

class ManufacturerListController extends GetxController {
  final isLoading = false.obs;

  final manufacturers = <Map<String, dynamic>>[].obs;
  final filteredManufacturers = <Map<String, dynamic>>[].obs;

  final searchController = TextEditingController();

  @override
  void onInit() {
    loadManufacturers();
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadManufacturers() async {
    try {
      isLoading.value = true;

      final data =
      await RetailerApi.getManufacturers();

      manufacturers.assignAll(data);
      filteredManufacturers.assignAll(data);
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchManufacturers(String query) {
    if (query.trim().isEmpty) {
      filteredManufacturers.assignAll(
        manufacturers,
      );
      return;
    }

    final search =
    query.toLowerCase().trim();

    filteredManufacturers.assignAll(
      manufacturers.where((item) {
        final company =
        (item["company_name"] ?? "")
            .toString()
            .toLowerCase();

        final dl =
        (item["drug_license_no"] ?? "")
            .toString()
            .toLowerCase();

        final phone =
        (item["phone"] ?? "")
            .toString()
            .toLowerCase();

        return company.contains(search) ||
            dl.contains(search) ||
            phone.contains(search);
      }).toList(),
    );
  }

  void clearSearch() {
    searchController.clear();
    filteredManufacturers.assignAll(
      manufacturers,
    );
  }
}
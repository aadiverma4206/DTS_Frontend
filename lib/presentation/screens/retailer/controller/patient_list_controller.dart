import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service/retailer_api.dart';

class PatientListController extends GetxController {
  final isLoading = false.obs;

  final patients = <Map<String, dynamic>>[].obs;
  final filteredPatients = <Map<String, dynamic>>[].obs;

  final searchController = TextEditingController();

  @override
  void onInit() {
    loadPatients();
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadPatients() async {
    try {
      isLoading.value = true;

      final data =
      await RetailerApi.getPatients();

      patients.assignAll(data);
      filteredPatients.assignAll(data);
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchPatients(String query) {
    if (query.trim().isEmpty) {
      filteredPatients.assignAll(
        patients,
      );
      return;
    }

    final search =
    query.toLowerCase().trim();

    filteredPatients.assignAll(
      patients.where((item) {
        final name =
        (item["patient_name"] ?? "")
            .toString()
            .toLowerCase();

        final mobile =
        (item["patient_mobile"] ?? "")
            .toString()
            .toLowerCase();

        return name.contains(search) ||
            mobile.contains(search);
      }).toList(),
    );
  }

  void clearSearch() {
    searchController.clear();
    filteredPatients.assignAll(
      patients,
    );
  }
}
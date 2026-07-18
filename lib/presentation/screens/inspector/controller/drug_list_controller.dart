import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service/inspection_api.dart';

class DrugController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<Map<String, dynamic>> drugs =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> filteredDrugs =
      <Map<String, dynamic>>[].obs;

  final TextEditingController searchController =
  TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadDrugs();
  }

  Future<void> loadDrugs() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await InspectionApi.getDrugList();

      drugs.assignAll(data);
      filteredDrugs.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadDrugs();
  }

  void onSearch(String value) {
    final query = value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredDrugs.assignAll(drugs);
      return;
    }

    filteredDrugs.assignAll(
      drugs.where((item) {
        final drugName =
        (item["drug_name"] ?? "")
            .toString()
            .toLowerCase();

        final category =
        (item["category"] ?? "")
            .toString()
            .toLowerCase();

        final composition =
        (item["composition"] ?? "")
            .toString()
            .toLowerCase();

        final strength =
        (item["strength"] ?? "")
            .toString()
            .toLowerCase();

        return drugName.contains(query) ||
            category.contains(query) ||
            composition.contains(query) ||
            strength.contains(query);
      }).toList(),
    );
  }

  String getDrugTitle(Map<String, dynamic> item) {
    return (item["drug_name"] ?? "").toString();
  }

  String getStrength(Map<String, dynamic> item) {
    return (item["strength"] ?? "").toString();
  }

  String getDosageForm(Map<String, dynamic> item) {
    return (item["dosage_form"] ?? "").toString();
  }

  String getCategory(Map<String, dynamic> item) {
    return (item["category"] ?? "").toString();
  }

  String getSource(Map<String, dynamic> item) {
    return (item["drug_source"] ?? "master")
        .toString();
  }

  int getDrugId(Map<String, dynamic> item) {
    return int.tryParse(
      item["drug_id"].toString(),
    ) ??
        0;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
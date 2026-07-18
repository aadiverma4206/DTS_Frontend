import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service/inspection_api.dart';

class StockInfoController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedType = 'retailer'.obs;
  final RxBool hasSearchText = false.obs;

  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTargets();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadTargets({String search = ''}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      List<Map<String, dynamic>> data;

      if (selectedType.value == 'all') {
        final retailers =
        await InspectionApi.getTargets(type: 'retailer', search: search);
        final wholesalers =
        await InspectionApi.getTargets(type: 'wholesaler', search: search);
        for (var item in retailers) {
          item['type'] = 'retailer';
        }
        for (var item in wholesalers) {
          item['type'] = 'wholesaler';
        }
        data = [...retailers, ...wholesalers];
      } else {
        data = await InspectionApi.getTargets(
          type: selectedType.value,
          search: search,
        );
        for (var item in data) {
          item['type'] = selectedType.value;
        }
      }

      users.assignAll(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      users.clear();
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      isLoading.value = false;
    }
  }

  void changeType(String type) {
    if (selectedType.value == type) return;
    selectedType.value = type;
    searchController.clear();
    hasSearchText.value = false;
    loadTargets();
  }

  void onSearch(String value) {
    hasSearchText.value = value.isNotEmpty;
    loadTargets(search: value.trim());
  }

  void clearSearch() {
    searchController.clear();
    hasSearchText.value = false;
    loadTargets();
  }

  Future<void> refreshData() async {
    await loadTargets(search: searchController.text.trim());
  }

  int getUserId(Map<String, dynamic> item) {
    return int.tryParse(item['user_id'].toString()) ?? 0;
  }

  String getBusinessName(Map<String, dynamic> item) {
    return (item['business_name'] ??
        item['shop_name'] ??
        item['company_name'] ??
        '')
        .toString();
  }
}

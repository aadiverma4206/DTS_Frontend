import 'package:get/get.dart';
import '../../../../core/services/api_service/inspection_api.dart';

class StockDetailsController extends GetxController {
  final int userId;

  StockDetailsController(this.userId);

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxList<Map<String, dynamic>> availableStock =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> expiredStock =
      <Map<String, dynamic>>[].obs;

  final RxString availableSearch = ''.obs;
  final RxString expiredSearch = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await InspectionApi.getStockDetails(userId);

      availableStock.assignAll(
        (response['available_stock'] ?? [])
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList(),
      );

      expiredStock.assignAll(
        (response['expired_stock'] ?? [])
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async => loadData();

  void setAvailableSearch(String value) => availableSearch.value = value.trim();

  void setExpiredSearch(String value) => expiredSearch.value = value.trim();

  List<Map<String, dynamic>> get filteredAvailableStock {
    final query = availableSearch.value.toLowerCase();
    if (query.isEmpty) return availableStock;

    return availableStock.where((supplier) {
      final name = (supplier['supplier_name'] ?? '').toString().toLowerCase();
      final shop = (supplier['supplier_shop'] ?? '').toString().toLowerCase();
      final dl =
      (supplier['drug_license_no'] ?? '').toString().toLowerCase();

      if (name.contains(query) || shop.contains(query) || dl.contains(query)) {
        return true;
      }

      final drugs = getDrugs(supplier);
      return drugs.any(
            (d) =>
            (d['drug_name'] ?? '').toString().toLowerCase().contains(query),
      );
    }).toList();
  }

  List<Map<String, dynamic>> get filteredExpiredStock {
    final query = expiredSearch.value.toLowerCase();
    if (query.isEmpty) return expiredStock;

    return expiredStock.where((item) {
      final name = (item['drug_name'] ?? '').toString().toLowerCase();
      final expiry = (item['expiry_date'] ?? '').toString().toLowerCase();
      return name.contains(query) || expiry.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> getDrugs(Map<String, dynamic> supplier) {
    return (supplier['drugs'] ?? [])
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}

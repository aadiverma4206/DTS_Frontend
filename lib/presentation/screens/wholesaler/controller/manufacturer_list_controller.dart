import 'package:get/get.dart';

import '../../../../core/services/api_service/wholesaler_api.dart';

class ManufacturerListController extends GetxController {
  final isLoading = false.obs;

  final manufacturers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    loadManufacturers();
    super.onInit();
  }

  Future<void> loadManufacturers() async {
    try {
      isLoading.value = true;

      final data =
      await WholesalerApi.getManufacturers();

      manufacturers.assignAll(data);
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(String? date) {
    try {
      if (date == null) return "";

      final d = DateTime.parse(date);

      return "${d.day}/${d.month}/${d.year}";
    } catch (_) {
      return "";
    }
  }
}
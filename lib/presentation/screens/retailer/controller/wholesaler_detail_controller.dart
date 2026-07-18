import 'package:get/get.dart';

import '../../../../core/services/api_service/retailer_api.dart';

class WholesalerDetailController extends GetxController {
  final int wholesalerId;

  WholesalerDetailController(
      this.wholesalerId,
      );

  final isLoading = false.obs;

  final wholesaler =
      <String, dynamic>{}.obs;

  final drugs =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    loadWholesalerDetails();
    super.onInit();
  }

  Future<void> loadWholesalerDetails() async {
    try {
      isLoading.value = true;

      final data =
      await RetailerApi.getWholesalerDetails(
        wholesalerId,
      );

      wholesaler.assignAll(
        Map<String, dynamic>.from(
          data["wholesaler"] ?? {},
        ),
      );

      drugs.assignAll(
        List<Map<String, dynamic>>.from(
          data["drugs"] ?? [],
        ),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String value(dynamic value) {
    if (value == null) return "N/A";

    if (value.toString().trim().isEmpty) {
      return "N/A";
    }

    return value.toString();
  }
}
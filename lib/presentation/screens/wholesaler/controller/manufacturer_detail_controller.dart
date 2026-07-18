import 'package:get/get.dart';

import '../../../../core/services/api_service/wholesaler_api.dart';

class ManufacturerDetailController extends GetxController {
  final int manufacturerId;

  ManufacturerDetailController(this.manufacturerId);

  final isLoading = false.obs;

  final manufacturer = <String, dynamic>{}.obs;

  @override
  void onInit() {
    loadManufacturerDetails();
    super.onInit();
  }

  Future<void> loadManufacturerDetails() async {
    try {
      isLoading.value = true;

      final data =
      await WholesalerApi.getManufacturerDetails(
        manufacturerId,
      );

      manufacturer.assignAll(data);
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
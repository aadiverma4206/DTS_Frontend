import 'package:get/get.dart';

import '../../../../core/services/api_service/wholesaler_api.dart';

class RetailerDetailController extends GetxController {
  final int retailerId;

  RetailerDetailController(this.retailerId);

  final isLoading = false.obs;

  final retailer = <String, dynamic>{}.obs;

  @override
  void onInit() {
    loadRetailerDetails();
    super.onInit();
  }

  Future<void> loadRetailerDetails() async {
    try {
      isLoading.value = true;

      final data =
      await WholesalerApi.getRetailerDetails(
        retailerId,
      );

      retailer.assignAll(data);
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
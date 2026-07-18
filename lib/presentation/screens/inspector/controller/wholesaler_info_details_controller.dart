import 'package:get/get.dart';
import '../../../../core/services/api_service/inspection_api.dart';

class WholesalerInfoDetailsController extends GetxController {
  final int userId;

  WholesalerInfoDetailsController(this.userId);

  final isLoading = true.obs;
  final wholesaler = <String, dynamic>{}.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDetails();
  }

  Future<void> loadDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response =
      await InspectionApi.getWholesalerDetails(userId);

      wholesaler.assignAll(
        Map<String, dynamic>.from(
          response['data'] ?? {},
        ),
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadDetails();
  }
}
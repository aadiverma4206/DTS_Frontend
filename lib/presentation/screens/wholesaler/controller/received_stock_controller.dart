import 'package:get/get.dart';
import '../../../../core/services/api_service/wholesaler_api.dart';

class ReceivedStockController extends GetxController {
  final isLoading = false.obs;

  final stockList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    loadReceivedStock();
    super.onInit();
  }

  Future<void> loadReceivedStock() async {
    try {
      isLoading.value = true;

      final data =
      await WholesalerApi.getReceivedStockHistory();

      stockList.assignAll(data);
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(String date) {
    try {
      final d = DateTime.parse(date);

      return "${d.day}/${d.month}/${d.year}";
    } catch (_) {
      return date;
    }
  }
}
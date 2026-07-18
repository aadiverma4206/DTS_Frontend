import 'package:get/get.dart';

import '../../../../core/services/api_service/retailer_api.dart';

class PatientDetailController extends GetxController {
  final String patientMobile;

  PatientDetailController(
      this.patientMobile,
      );

  final isLoading = false.obs;

  final patient =
      <String, dynamic>{}.obs;

  final sales =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    loadPatientDetails();
    super.onInit();
  }

  Future<void> loadPatientDetails() async {
    try {
      isLoading.value = true;

      final data =
      await RetailerApi.getPatientDetails(
        patientMobile,
      );

      patient.assignAll(
        Map<String, dynamic>.from(
          data["patient"] ?? {},
        ),
      );

      sales.assignAll(
        List<Map<String, dynamic>>.from(
          data["sales"] ?? [],
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
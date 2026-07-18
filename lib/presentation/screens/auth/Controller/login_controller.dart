import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service/api_service.dart';
import '../../../../core/services/api_service/auth_api.dart';
import '../../admin/admin_home.dart';
import '../../inspector/inspector_home.dart';
import '../../retailer/retailer_home.dart';
import '../../wholesaler/wholesaler_home.dart';
import '../login/auth_storage.dart';
import '../detail_registration_form/retailer_form.dart';
import '../detail_registration_form/wholesaler_form.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  void togglePassword() => isPasswordHidden.value = !isPasswordHidden.value;

  Future<void> handleLogin(String email, String password) async {
    if (isLoading.value) return;

    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty && trimmedPassword.isEmpty) {
      _showMsg("Email and password are required");
      return;
    }
    if (trimmedEmail.isEmpty) {
      _showMsg("Email is required");
      return;
    }
    if (trimmedPassword.isEmpty) {
      _showMsg("Password is required");
      return;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(trimmedEmail)) {
      _showMsg("Enter a valid email address");
      return;
    }

    if (trimmedPassword.length < 6) {
      _showMsg("Password must be at least 6 characters");
      return;
    }

    isLoading.value = true;

    try {
      final response = await AuthApi.login(trimmedEmail, trimmedPassword);

      if (response["user"] == null) {
        throw Exception(response["message"] ?? "Login failed");
      }

      final user = Map<String, dynamic>.from(response["user"]);
      final role = user["role"]?.toString() ?? "";
      final profileCompleted = response["profile_completed"] == true;
      final token = response["token"]?.toString() ?? "";
      final userId = user["user_id"]?.toString() ?? "";

      if (token.isEmpty) {
        throw Exception("Authentication token missing. Please try again.");
      }

      await AuthStorage.saveLoginData(
        token: token,
        role: role,
        userId: userId,
        profileCompleted: profileCompleted,
      );

      ApiService.setToken(token);
      _navigate(role, profileCompleted);
    } catch (e) {
      final msg = e
          .toString()
          .replaceAll("Exception:", "")
          .replaceAll("exception:", "")
          .trim();
      _showMsg(msg.isNotEmpty ? msg : "Something went wrong. Try again.");
    } finally {
      isLoading.value = false;
    }
  }

  void _navigate(String role, bool profileCompleted) {
    switch (role) {
      case "wholesaler":
        Get.offAll(
              () => profileCompleted
              ? const WholesalerHome()
              : const WholesalerForm(),
        );
        break;
      case "retailer":
        Get.offAll(
              () => profileCompleted ? const RetailerHome() : const RetailerForm(),
        );
        break;
      case "admin":
        Get.offAll(() => const AdminHome());
        break;
      case "inspector":
        Get.offAll(() => const InspectorHome());
        break;
      default:
        _showMsg("Invalid user role. Contact support.");
    }
  }

  void _showMsg(String msg) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      "",
      msg,
      titleText: const SizedBox.shrink(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
    );
  }
}

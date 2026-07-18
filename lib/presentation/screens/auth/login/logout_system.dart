import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service/api_service.dart';
import 'auth_storage.dart';
import 'login_screen.dart';

class LogoutSystem {
  static bool _isLoggingOut = false;

  static Future<void> logout({bool showConfirm = false}) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      if (showConfirm) {
        final confirmed = await _showConfirmDialog();
        if (confirmed != true) {
          _isLoggingOut = false;
          return;
        }
      }

      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      if (Get.isDialogOpen ?? false) Get.back();

      await AuthStorage.logout();
      ApiService.setToken("");
      Get.deleteAll(force: true);
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      debugPrint('[LogoutSystem] error: $e');
    } finally {
      _isLoggingOut = false;
    }
  }

  static Future<bool?> _showConfirmDialog() {
    return Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBE123C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Logout"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}

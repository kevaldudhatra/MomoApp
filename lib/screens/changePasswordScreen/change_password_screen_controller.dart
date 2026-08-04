import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/utils/const_colors_key.dart';

class ChangePasswordScreenController extends GetxController {
  final storage = GetStorage();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  final RxBool obscureCurrentPassword = true.obs;
  final RxBool obscureNewPassword = true.obs;

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }

  void toggleCurrentPasswordVisibility() {
    obscureCurrentPassword.value = !obscureCurrentPassword.value;
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  Future<void> savePassword() async {
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;

    if (currentPassword.isEmpty) {
      Get.snackbar(
        "Oops!",
        "Current password cannot be empty.",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    final passwordRegex = RegExp(r'^.{8,}$');
    if (!passwordRegex.hasMatch(newPassword)) {
      Get.snackbar(
        "Oops!",
        "New password must be at least 8 characters long.",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    print("Password Data => current: $currentPassword, new: $newPassword");
    Get.back();
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:momos/network/api_services.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/widgets/loading_view.dart';

class ResetPasswordScreenController extends GetxController {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString resetToken = "".obs;

  @override
  void onInit() {
    super.onInit();
    resetToken.value = Get.arguments?['resetToken'] ?? "";
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> continueToLogin() async {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final passwordRegex = RegExp(r'^.{8,}$');

    if (!passwordRegex.hasMatch(password)) {
      Get.snackbar(
        "Oops!",
        "Password must be at least 8 characters long.",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (!passwordRegex.hasMatch(confirmPassword)) {
      Get.snackbar(
        "Oops!",
        "Confirm password must be at least 8 characters long.",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        "Oops!",
        "Password & Confirm password does not match.",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    print(
      'continueToLogin Data => $password, $confirmPassword ${resetToken.value}',
    );
    Get.dialog(const LoadingDialog(), barrierDismissible: false);

    try {
      var response = await http.post(
        Uri.parse(ApiServices.resetPassword),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${resetToken.value}",
        },
        body: jsonEncode({"password": password}),
      );
      print('continueToLogin Response status: ${response.statusCode}');
      print('continueToLogin Response body: ${response.body}');

      if (Get.isDialogOpen!) {
        Get.back();
      }

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        Get.snackbar(
          "Success",
          data["message"] ?? "Password reset successfully.",
          icon: const Icon(Icons.done, color: Colors.green),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.startScreen);
      } else {
        Get.snackbar(
          "Oops!",
          data["message"] ?? "Failed to reset password.",
          icon: const Icon(Icons.error, color: Colors.red),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen!) {
        Get.back();
      }
      Get.snackbar(
        "Error",
        e.toString(),
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
    }
  }
}

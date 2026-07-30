import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:momos/network/api_services.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/widgets/loading_view.dart';

class ForgotPasswordScreenController extends GetxController {
  final emailController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> verifyEmail() async {
    final email = emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      Get.snackbar(
        "Oops!",
        "Valid email is required.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    print("verifyEmail input Data: $email");
    Get.dialog(const LoadingDialog(), barrierDismissible: false);

    try {
      var response = await http.post(
        Uri.parse(ApiServices.forgotPassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      print('verifyEmail Response status: ${response.statusCode}');
      print('verifyEmail Response body: ${response.body}');
      if (Get.isDialogOpen!) {
        Get.back();
      }
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        Get.snackbar(
          "Success",
          data["message"] ?? "Verification code sent to your email",
          icon: const Icon(Icons.done, color: Colors.green),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
        Get.toNamed(
          Routes.verifyEmailScreen,
          arguments: {"email": email, "secretId": data["data"]["secretId"]},
        );
      } else {
        Get.snackbar(
          "Oops!",
          data["message"] ?? "Something went wrong",
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

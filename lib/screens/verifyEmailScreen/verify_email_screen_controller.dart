import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:momos/network/api_services.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/widgets/loading_view.dart';

class VerifyEmailScreenController extends GetxController {
  final otpController = TextEditingController();
  final focusNode = FocusNode();
  final RxString otpCode = "".obs;
  final RxBool isOtpFocused = false.obs;
  final RxString email = "".obs;
  final RxString secretId = "".obs;

  @override
  void onInit() {
    super.onInit();
    email.value = Get.arguments?['email'] ?? "";
    secretId.value = Get.arguments?['secretId'] ?? "";
    otpController.addListener(() {
      otpCode.value = otpController.text;
    });
    focusNode.addListener(() {
      isOtpFocused.value = focusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    otpController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  Future<dynamic> continueToResetPassword() async {
    print(
      'continueToResetPassword Data => ${secretId.value}, ${otpCode.value}',
    );
    Get.dialog(const LoadingDialog(), barrierDismissible: false);
    try {
      var response = await http.post(
        Uri.parse(ApiServices.verifyForgotOtp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"secretId": secretId.value, "otp": otpCode.value}),
      );
      print('continueToResetPassword Response status: ${response.statusCode}');
      print('continueToResetPassword Response body: ${response.body}');
      if (Get.isDialogOpen!) {
        Get.back();
      }
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        Get.snackbar(
          "Success",
          data["message"] ?? "OTP verified successfully.",
          icon: const Icon(Icons.done, color: Colors.green),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
        Get.toNamed(
          Routes.resetPasswordScreen,
          arguments: {"resetToken": data["data"]["resetToken"]},
        );
      } else {
        Get.snackbar(
          "Oops!",
          data["message"] ?? "OTP verification failed.",
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

  Future<dynamic> resendOtp() async {
    print("resendOtp input Data => ${email.value}");
    Get.dialog(const LoadingDialog(), barrierDismissible: false);

    try {
      var response = await http.post(
        Uri.parse(ApiServices.forgotPassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email.value}),
      );
      print('resendOtp Response status: ${response.statusCode}');
      print('resendOtp Response body: ${response.body}');
      if (Get.isDialogOpen!) {
        Get.back();
      }
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        if (data["data"] != null && data["data"]["secretId"] != null) {
          secretId.value = data["data"]["secretId"];
        }
        Get.snackbar(
          "Success",
          data["message"] ?? "A new code has been sent to your email address.",
          icon: const Icon(Icons.done, color: Colors.green),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
      } else {
        Get.snackbar(
          "Oops!",
          data["message"] ?? "Failed to resend code.",
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:momos/widgets/loading_view.dart';
import 'package:http/http.dart' as http;

class OtpVerificationScreenController extends GetxController {
  final storage = GetStorage();
  final otpController = TextEditingController();
  final focusNode = FocusNode();
  final RxBool isLogin = false.obs;
  final RxString phoneNumber = ''.obs;
  final RxString email = ''.obs;
  final RxString secretId = ''.obs;
  final RxString otpCode = ''.obs;
  final RxBool isOtpFocused = false.obs;

  @override
  void onInit() {
    super.onInit();
    isLogin.value = Get.arguments?['forLogin'] ?? false;
    phoneNumber.value = Get.arguments?['phoneNumber'] ?? "";
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

  Future<dynamic> otpVerification() async {
    print("otpVerification input Data => ${secretId.value}, ${otpCode.value}, ${isLogin.value}");
    Get.dialog(const LoadingDialog(), barrierDismissible: false);
    var response = await http.post(
      Uri.parse(ApiServices.verifyOtp),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"secretId": secretId.value, "otp": otpCode.value, "type": isLogin.value ? "login" : "register"}),
    );
    print('otpVerification Response status: ${response.statusCode}');
    print('otpVerification Response body: ${response.body}');
    if (Get.isDialogOpen!) {
      Get.back();
    }
    var data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["success"] == true && data["data"]["user"]["isProfileComplete"] == false) {
      await storage.write(userToken, "Bearer ${data["data"]["token"]}");
      Get.toNamed(Routes.completeYourProfileScreen);
    } else if (response.statusCode == 200 && data["success"] == true && data["data"]["user"]["isProfileComplete"] == true) {
      Get.snackbar(
        "Success",
        data["message"],
        icon: const Icon(Icons.done, color: Colors.green),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
      await storage.write(loginTrue, true);
      await storage.write(userToken, "Bearer ${data["data"]["token"]}");
      Get.offAllNamed(Routes.homeScreen);
    } else {
      Get.snackbar(
        "Oops!",
        data["message"],
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
    }
  }

  Future<dynamic> resendOtp() async {
    print("resendOtp input Data => ${secretId.value}, ${isLogin.value}, ${email.value}, ${phoneNumber.value}");
    Get.dialog(const LoadingDialog(), barrierDismissible: false);
    var response = await http.post(
      Uri.parse(ApiServices.resendOtp),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"secretId": secretId.value, "type": email.value != "" ? "email" : "phone"}),
    );
    print('resendOtp Response status: ${response.statusCode}');
    print('resendOtp Response body: ${response.body}');
    if (Get.isDialogOpen!) {
      Get.back();
    }
    var data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["success"] == true) {
      Get.snackbar(
        "OTP Resent",
        "A new code has been sent to your phone number.",
        icon: const Icon(Icons.done, color: Colors.green),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
      secretId.value = data["data"]?["user"]?["secretId"] ?? data["data"]?["secretId"];
    } else {
      Get.snackbar(
        "Oops!",
        data["message"],
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
    }
  }
}

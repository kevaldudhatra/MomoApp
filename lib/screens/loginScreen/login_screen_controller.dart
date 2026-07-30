import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:momos/network/api_services.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:momos/widgets/loading_view.dart';

class LoginScreenController extends GetxController {
  final storage = GetStorage();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool obscurePassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> userLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final passwordRegex = RegExp(r'^.{8,}$');
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

    if (!passwordRegex.hasMatch(password)) {
      Get.snackbar(
        "Oops!",
        "Password must be at least 8 characters long.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }
    await liginApi();
  }

  Future<dynamic> liginApi() async {
    print(
      " liginApi input Data => ${emailController.text}, ${passwordController.text}",
    );
    Get.dialog(const LoadingDialog(), barrierDismissible: false);
    var response = await http.post(
      Uri.parse(ApiServices.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "loginType": "email",
      }),
    );
    print('liginApi Response status: ${response.statusCode}');
    print('liginApi Response body: ${response.body}');
    if (Get.isDialogOpen!) {
      Get.back();
    }
    var data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["success"] == true) {
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
}

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

class CompleteYourProfileScreenController extends GetxController {
  final storage = GetStorage();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> submitProfile() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();

    if (fullName.isEmpty) {
      Get.snackbar(
        "Oops!",
        "Full Name is required.",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      Get.snackbar(
        "Oops!",
        "Valid email is required.",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    try {
      print(
        "completeYourProfile input Data => $email, $fullName, ${storage.read(userToken)}",
      );
      Get.dialog(const LoadingDialog(), barrierDismissible: false);
      var response = await http.put(
        Uri.parse(ApiServices.getAndUpdateProfile),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "${storage.read(userToken)}",
        },
        body: jsonEncode({"email": email, "name": fullName}),
      );
      print('completeYourProfile Response status: ${response.statusCode}');
      print('completeYourProfile Response body: ${response.body}');
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
    } catch (e) {
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/utils/const_colors_key.dart';

class EditProfileScreenController extends GetxController {
  final firstNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Mock avatar image URL
  final avatarUrl =
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150".obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void _loadProfileData() {
    firstNameController.text = "Neha Verma";
    emailController.text = "nehaverma@gmail.com";
    phoneController.text = "+91 123456789";
  }

  void changePassword() {}

  void saveChanges() {
    final name = firstNameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        "Oops!",
        "First Name cannot be empty.",
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
      return;
    }

    Get.back();
  }
}

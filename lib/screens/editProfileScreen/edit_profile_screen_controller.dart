import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:momos/widgets/loading_view.dart';
import 'package:momos/screens/profileScreen/profile_screen_controller.dart';
import 'package:http/http.dart' as http;

class EditProfileScreenController extends GetxController {
  final storage = GetStorage();
  RxMap<String, dynamic> get userData =>
      Get.isRegistered<ProfileScreenController>()
      ? Get.find<ProfileScreenController>().userData
      : <String, dynamic>{}.obs;
  final firstNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final avatarUrl = "".obs;

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
    avatarUrl.value =
        userData['profileImage'] ??
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150";
    firstNameController.text = userData['name'] ?? "";
    emailController.text = userData['email'] ?? "";
    phoneController.text = userData['phoneNumber'] ?? "";
  }

  void changePassword() {}

  Future<void> saveChanges() async {
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
    await updateUserProfile();
  }

  Future<dynamic> updateUserProfile() async {
    Get.dialog(const LoadingDialog(), barrierDismissible: false);
    var response = await http.put(
      Uri.parse(ApiServices.getAndUpdateProfile),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "${storage.read(userToken)}",
      },
      body: jsonEncode({"name": firstNameController.text.trim()}),
    );
    print('updateUserProfile Response status: ${response.statusCode}');
    print('updateUserProfile Response body: ${response.body}');
    if (Get.isDialogOpen!) {
      Get.back();
    }
    var data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["success"] == true) {
      userData.value = data["data"];
      Get.back();
    } else {
      Get.snackbar(
        "Oops!",
        data["message"] ??
            'We\'re unable to update your profile at the moment. Please try again later.',
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
    }
  }
}

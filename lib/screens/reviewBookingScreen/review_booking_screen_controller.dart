import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';

class ReviewBookingScreenController extends GetxController {
  final specialRequestController = TextEditingController();
  final bookingDateTime = "Today at 07:00 PM";
  final guestCount = "1 guests";
  final restaurantName = "Momo I AM";
  final restaurantAddress = "Aditya Mehta, 23 Sunrise Apartments, Yagnik...";

  @override
  void onClose() {
    specialRequestController.dispose();
    super.onClose();
  }

  void bookTable() {
    Get.snackbar(
      "Booking Confirmed",
      "Your table reservation at $restaurantName has been confirmed!",
      snackPosition: SnackPosition.TOP,
      backgroundColor: charcoalGray.withValues(alpha: 0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.done, color: Colors.green),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Get.offAndToNamed(Routes.homeScreen);
    });
  }
}

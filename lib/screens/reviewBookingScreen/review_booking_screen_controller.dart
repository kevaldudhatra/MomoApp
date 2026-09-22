import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/bookTableScreen/book_table_screen_controller.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:momos/widgets/loading_view.dart';
import 'package:http/http.dart' as http;

class ReviewBookingScreenController extends GetxController {
  final storage = GetStorage();
  final specialRequestController = TextEditingController();

  String get restaurantName {
    try {
      final deliveryController = Get.find<DeliveryScreenController>();
      return deliveryController.outlateDetails['name'];
    } catch (_) {
      return "";
    }
  }

  String get restaurantAddress {
    try {
      final deliveryController = Get.find<DeliveryScreenController>();
      return "${deliveryController.outlateDetails['address']}, ${deliveryController.outlateDetails['city']}, ${deliveryController.outlateDetails['state']} - ${deliveryController.outlateDetails['pinCode']}";
    } catch (_) {
      return "";
    }
  }

  String get bookingDateTime {
    try {
      final bookTableController = Get.find<BookTableScreenController>();
      final date = bookTableController.selectedDate.value;
      final selectedIdx = bookTableController.selectedTimeIndex.value;
      final timeSlots = bookTableController.timeSlots;
      if (selectedIdx >= 0 && selectedIdx < timeSlots.length) {
        return "$date at ${timeSlots[selectedIdx]}";
      }
      return date;
    } catch (_) {
      return "";
    }
  }

  String get guestCount {
    try {
      final bookTableController = Get.find<BookTableScreenController>();
      return "${bookTableController.selectedGuests.value} guests";
    } catch (_) {
      return "";
    }
  }

  String formatDate(String dateString) {
    if (dateString == 'Today') {
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    } else {
      final parsedDate = DateFormat('EEE, dd MMM').parse(dateString);
      final now = DateTime.now();
      final date = DateTime(now.year, parsedDate.month, parsedDate.day);
      return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  String formatTime(String timeString) {
    final parsedTime = DateFormat('h:mm a').parse(timeString);
    return DateFormat('HH:mm').format(parsedTime);
  }

  @override
  void onClose() {
    specialRequestController.dispose();
    super.onClose();
  }

  Future<void> bookTable() async {
    try {
      Get.dialog(const LoadingDialog(), barrierDismissible: false);
      final response = await http.post(
        Uri.parse(ApiServices.tableReservations),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode({
          "outlateId":
              Get.find<DeliveryScreenController>().outlateDetails['id'],
          "bookingDate": formatDate(
            Get.find<BookTableScreenController>().selectedDate.value,
          ),
          "bookingTime": formatTime(
            Get.find<BookTableScreenController>().selectedTime.value,
          ),
          "guestCount":
              Get.find<BookTableScreenController>().selectedGuests.value,
          "specialRequest": specialRequestController.text.isEmpty
              ? ""
              : specialRequestController.text,
        }),
      );

      print('tableReservations Response status: ${response.statusCode}');
      print('tableReservations Response body: ${response.body}');
      if (Get.isDialogOpen!) {
        Get.back();
      }
      var data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        Get.snackbar(
          "Booking Confirmed",
          data['message'],
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.done, color: Colors.green),
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAndToNamed(Routes.homeScreen);
        });
      } else {
        Get.snackbar(
          "Error",
          data['message'] ?? "Failed to book table",
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.error, color: Colors.red),
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('tableReservations Error: $e');
      if (Get.isDialogOpen!) {
        Get.back();
      }
      Get.snackbar(
        "Error",
        "Failed to book table",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }
}

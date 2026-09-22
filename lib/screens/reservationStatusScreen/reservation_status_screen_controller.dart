import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/network/socket_service.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/screens/myReservationsScreen/my_reservations_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

class ReservationStatusScreenController extends GetxController {
  StreamSubscription? _reservationStatusSubscription;
  late final Rx<ReservationModel> _reservation;
  ReservationModel get reservation => _reservation.value;
  set reservation(ReservationModel value) => _reservation.value = value;
  final storage = GetStorage();
  final outletId = Get.isRegistered<DeliveryScreenController>()
      ? Get.find<DeliveryScreenController>().outlateDetails['id']
      : 0;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ReservationModel) {
      _reservation = (Get.arguments as ReservationModel).obs;
    } else {
      _reservation = ReservationModel(
        id: "",
        restaurantName: "",
        restaurantAddress: "",
        restaurantImage: "",
        guests: 0,
        scheduledTime: "",
        placedTime: "",
        status: "",
        phoneNumber: "",
      ).obs;
    }
    _listenToReservationStatusUpdate();
  }

  @override
  void onClose() {
    _reservationStatusSubscription?.cancel();
    super.onClose();
  }

  void _listenToReservationStatusUpdate() {
    _reservationStatusSubscription = SocketService().onReservationStatusReceived
        .listen((data) {
          print(
            "📦 Socket bookingStatusUpdate received in ReservationStatusScreenController: $data",
          );
          if (data == null) return;
          if (data is Map &&
              data.isNotEmpty &&
              data['bookingId'].toString() == reservation.id) {
            final newStatus = data['status']?.toString() ?? reservation.status;
            reservation = reservation.copyWith(status: newStatus);
            update();
          }
        });
  }

  Future<bool> addFeedback({int? rating, String? comment}) async {
    print("addFeedback input: $rating, $comment");
    try {
      final response = await http.post(
        Uri.parse(
          ApiServices.addRating.replaceAll('{outlateId}', outletId.toString()),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode({"rate": rating, "message": comment}),
      );
      print('addFeedback Response status: ${response.statusCode}');
      print('addFeedback Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 201 && data["success"] == true) {
        return true;
      } else {
        Get.snackbar(
          "Oops!",
          data["message"] ?? "Something went wrong. Please try again.",
          icon: const Icon(Icons.error, color: Colors.red),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Oops!",
        "Something went wrong. Please try again.",
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
      return false;
    }
  }
}

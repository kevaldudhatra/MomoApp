import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/network/socket_service.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

class OrderStatusScreenController extends GetxController {
  final storage = GetStorage();
  StreamSubscription? _orderStatusSubscription;
  String currentOrderId = "0";
  RxBool isLoading = false.obs;
  RxMap<dynamic, dynamic> orderDetails = {}.obs;
  RxBool isBillDetailsExpanded = true.obs;
  final outletId = Get.isRegistered<DeliveryScreenController>()
      ? Get.find<DeliveryScreenController>().outlateDetails['id']
      : 0;

  @override
  void onInit() {
    super.onInit();
    currentOrderId = (Get.arguments?['orderId'] ?? "0").toString();
    getOrderDetails(orderId: currentOrderId);
    _listenToOrderStatusUpdate();
  }

  @override
  void onClose() {
    _orderStatusSubscription?.cancel();
    super.onClose();
  }

  void _listenToOrderStatusUpdate() {
    _orderStatusSubscription = SocketService().onOrderStatusReceived.listen((
      data,
    ) {
      print(
        "📦 Socket orderStatusUpdate received in OrderStatusScreenController: $data",
      );
      if (data == null) return;
      if (data is Map &&
          data.isNotEmpty &&
          data['orderId'] == orderDetails['id'] &&
          data['orderNumber'] == orderDetails['orderNumber']) {
        getOrderDetails(
          orderId: data['orderId'].toString(),
          showLoading: false,
        );
      }
    });
  }

  String formatStatus(dynamic status) {
    if (status == null) return '';
    return status
        .toString()
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }

  Future<void> getOrderDetails({
    String? orderId,
    bool showLoading = true,
  }) async {
    print("getOrderDetails Input: $orderId");
    try {
      if (showLoading) isLoading.value = true;
      final response = await http.get(
        Uri.parse(
          ApiServices.getOrderDetails.replaceAll('{id}', orderId.toString()),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getOrderDetails Response status: ${response.statusCode}');
      print('getOrderDetails Response body: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        orderDetails.value = data['data'];
      } else {
        if (showLoading) orderDetails.value = {};
      }
    } catch (e) {
      print('getOrderDetails Error: $e');
      if (showLoading) orderDetails.value = {};
    } finally {
      if (showLoading) isLoading.value = false;
    }
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

  void toggleBillDetails() {
    isBillDetailsExpanded.value = !isBillDetailsExpanded.value;
  }

  void downloadInvoice() {}
}

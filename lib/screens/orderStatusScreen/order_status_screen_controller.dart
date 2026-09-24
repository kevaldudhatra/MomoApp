import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/network/socket_service.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class OrderStatusScreenController extends GetxController {
  final storage = GetStorage();
  StreamSubscription? _orderStatusSubscription;
  StreamSubscription? _reconnectSubscription;
  String currentOrderId = "0";
  RxBool isLoading = false.obs;
  RxBool isDownloadingInvoice = false.obs;
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
    _listenToSocketReconnect();
  }

  @override
  void onClose() {
    _orderStatusSubscription?.cancel();
    _reconnectSubscription?.cancel();
    super.onClose();
  }

  void _listenToSocketReconnect() {
    _reconnectSubscription = SocketService().onReconnected.listen((_) {
      debugPrint(
        "OrderStatusScreenController => Socket reconnected: refreshing order details",
      );
      if (currentOrderId != "0") {
        getOrderDetails(orderId: currentOrderId, showLoading: false);
      }
    });
  }

  void _listenToOrderStatusUpdate() {
    _orderStatusSubscription = SocketService().onOrderStatusReceived.listen((
      data,
    ) {
      debugPrint(
        "📦 Socket orderStatusUpdate received in OrderStatusScreenController: $data",
      );
      if (data == null) return;
      if (data is Map && data.isNotEmpty) {
        final incomingOrderId = data['orderId']?.toString();
        final activeOrderId = orderDetails['id']?.toString() ?? currentOrderId;
        if (incomingOrderId != null &&
            (incomingOrderId == activeOrderId ||
                incomingOrderId == currentOrderId)) {
          getOrderDetails(orderId: incomingOrderId, showLoading: false);
        }
      }
    });
  }

  void toggleBillDetails() {
    isBillDetailsExpanded.value = !isBillDetailsExpanded.value;
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

  Future<bool> addFeedback({double? rating, String? comment}) async {
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

  Future<void> downloadInvoice() async {
    final invoiceUrl = (orderDetails['invoiceUrl'] ?? '').toString().trim();
    if (invoiceUrl.isEmpty) {
      Get.snackbar(
        "Oops!",
        "Invoice URL is not available for this order.",
        icon: const Icon(Icons.error, color: Colors.orange),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
      return;
    }
    if (isDownloadingInvoice.value) return;
    try {
      isDownloadingInvoice.value = true;
      final response = await http.get(Uri.parse(invoiceUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/invoice.pdf');
        final downloadedFile = await file.writeAsBytes(response.bodyBytes);
        isDownloadingInvoice.value = false;
        await OpenFilex.open(downloadedFile.path);
      } else {
        Get.snackbar(
          "Oops!",
          "Failed to download PDF",
          icon: const Icon(Icons.error, color: Colors.red),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Oops!",
        "Failed to download or open invoice. Please try again.",
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
    } finally {
      isDownloadingInvoice.value = false;
    }
  }
}

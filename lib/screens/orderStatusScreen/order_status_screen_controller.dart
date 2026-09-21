import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

class OrderStatusScreenController extends GetxController {
  final storage = GetStorage();
  final isLoading = false.obs;
  RxMap<dynamic, dynamic> orderDetails = {}.obs;

  // Accordion state
  final isBillDetailsExpanded = true.obs;

  @override
  void onInit() {
    super.onInit();
    getOrderDetails(orderId: Get.arguments?['orderId'] ?? "0");
  }

  String formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }

  Future<void> getOrderDetails({String? orderId}) async {
    print("getOrderDetails Input: $orderId");
    try {
      isLoading.value = true;
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
        orderDetails.value = {};
      }
    } catch (e) {
      print('getOrderDetails Error: $e');
      orderDetails.value = {};
    } finally {
      isLoading.value = false;
    }
  }

  void toggleBillDetails() {
    isBillDetailsExpanded.value = !isBillDetailsExpanded.value;
  }

  void downloadInvoice() {}
}

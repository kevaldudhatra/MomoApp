import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/myOrdersScreen/my_orders_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';

class OrderStatusScreenController extends GetxController {
  late final OrderModel order;

  // Accordion state
  final isBillDetailsExpanded = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is OrderModel) {
      order = Get.arguments as OrderModel;
    } else {
      order = OrderModel(
        id: "123456",
        restaurantName: "Momo I AM",
        restaurantAddress: "Alipore, Kolkata",
        restaurantImage: "",
        orderDate: "22 Mar, 10:56AM",
        totalAmount: 400.0,
        status: "Ongoing",
        items: [
          OrderItem(name: "Classic Cheeseburgers", quantity: 2, isVeg: true),
          OrderItem(name: "Classic Cheeseburgers", quantity: 2, isVeg: true),
          OrderItem(name: "Classic Cheeseburgers", quantity: 2, isVeg: true),
        ],
      );
    }
  }

  void toggleBillDetails() {
    isBillDetailsExpanded.value = !isBillDetailsExpanded.value;
  }

  void downloadInvoice() {
    Get.snackbar(
      "Download Started",
      "Downloading invoice for order #${order.id}...",
      snackPosition: SnackPosition.TOP,
      backgroundColor: charcoalGray.withValues(alpha: 0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.download, color: Colors.green),
    );
  }
}

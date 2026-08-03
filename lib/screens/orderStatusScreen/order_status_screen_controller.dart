import 'package:get/get.dart';
import 'package:momos/screens/myOrdersScreen/my_orders_screen_controller.dart';

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
}

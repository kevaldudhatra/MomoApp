import 'package:get/get.dart';

class OrderItem {
  final String name;
  final int quantity;
  final bool isVeg;

  OrderItem({required this.name, required this.quantity, required this.isVeg});
}

class OrderModel {
  final String id;
  final String restaurantName;
  final String restaurantAddress;
  final String restaurantImage;
  final String orderDate;
  final double totalAmount;
  final String status;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.restaurantImage,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.items,
  });
}

class MyOrdersScreenController extends GetxController {
  final selectedStatus = "All".obs;
  final statusOptions = ["All", "Pending", "Ongoing", "Delivered", "Cancelled"];
  final ordersList = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockOrders();
  }

  void _loadMockOrders() {
    ordersList.assignAll([
      OrderModel(
        id: "1",
        restaurantName: "Momo I AM",
        restaurantAddress: "Alipore, Kolkata",
        restaurantImage:
            "https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&q=80&w=150",
        orderDate: "22 Mar, 10:56AM",
        totalAmount: 25.0,
        status: "Pending",
        items: [
          OrderItem(name: "Classic Cheeseburgers", quantity: 2, isVeg: true),
          OrderItem(name: "Large Fries", quantity: 1, isVeg: true),
        ],
      ),
      OrderModel(
        id: "2",
        restaurantName: "Momo I AM",
        restaurantAddress: "Alipore, Kolkata",
        restaurantImage:
            "https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&q=80&w=150",
        orderDate: "22 Mar, 10:56AM",
        totalAmount: 25.0,
        status: "Delivered",
        items: [
          OrderItem(name: "Classic Cheeseburgers", quantity: 2, isVeg: true),
          OrderItem(name: "Large Fries", quantity: 1, isVeg: true),
        ],
      ),
      OrderModel(
        id: "3",
        restaurantName: "Momo I AM",
        restaurantAddress: "Alipore, Kolkata",
        restaurantImage:
            "https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&q=80&w=150",
        orderDate: "23 Mar, 01:15PM",
        totalAmount: 350.0,
        status: "Ongoing",
        items: [
          OrderItem(name: "Smokey Chilli Paneer", quantity: 1, isVeg: true),
          OrderItem(name: "Steam Momos", quantity: 2, isVeg: false),
        ],
      ),
      OrderModel(
        id: "4",
        restaurantName: "Momo I AM",
        restaurantAddress: "Alipore, Kolkata",
        restaurantImage:
            "https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&q=80&w=150",
        orderDate: "20 Mar, 08:30PM",
        totalAmount: 120.0,
        status: "Cancelled",
        items: [OrderItem(name: "Spring Rolls", quantity: 1, isVeg: true)],
      ),
    ]);
  }

  List<OrderModel> get filteredOrders {
    if (selectedStatus.value == "All") {
      return ordersList;
    }
    return ordersList
        .where(
          (order) =>
              order.status.toLowerCase() == selectedStatus.value.toLowerCase(),
        )
        .toList();
  }
}

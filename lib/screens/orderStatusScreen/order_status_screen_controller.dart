import 'package:get/get.dart';
import 'package:momos/network/socket_service.dart';
import 'package:momos/screens/myOrdersScreen/my_orders_screen_controller.dart';

class OrderStatusScreenController extends GetxController {
  late final OrderModel order;

  // Accordion state
  final isBillDetailsExpanded = true.obs;

  // Real-time live status updated via Socket.IO
  final RxString liveStatus = "".obs;

  // Memory leak guard: all socket subscriptions are cancelled on controller close
  final SocketSubscriptionBag _socketBag = SocketSubscriptionBag();

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
    liveStatus.value = order.status;
    _subscribeToLiveOrderUpdates();
  }

  void _subscribeToLiveOrderUpdates() {
    if (!Get.isRegistered<SocketService>()) return;

    // Join room for this specific order
    SocketService.to.emit(SocketEvents.subscribeOrder, {'orderId': order.id});

    // Listen for live updates on this order
    final statusSub = SocketService.to.on(SocketEvents.orderStatusUpdate, (
      dynamic data,
    ) {
      final payload = OrderStatusPayload.fromJson(data);
      if (payload.orderId.isEmpty || payload.orderId == order.id) {
        liveStatus.value = payload.status;
      }
    });

    _socketBag.add(statusSub);
  }

  @override
  void onClose() {
    // Unsubscribe from order room on the server and remove client listeners
    if (Get.isRegistered<SocketService>()) {
      SocketService.to.emit(SocketEvents.unsubscribeOrder, {
        'orderId': order.id,
      });
    }
    _socketBag.cancelAll();
    super.onClose();
  }

  void toggleBillDetails() {
    isBillDetailsExpanded.value = !isBillDetailsExpanded.value;
  }

  void downloadInvoice() {}
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/network/socket_service.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String name;
  final int quantity;
  final bool isVeg;

  OrderItem({required this.name, required this.quantity, required this.isVeg});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['itemName'].toString(),
      quantity: int.parse(json['quantity'].toString()),
      isVeg: json['itemType'] == 1 ? true : false,
    );
  }
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems.map<OrderItem>((item) {
      if (item is Map<String, dynamic>) {
        return OrderItem.fromJson(item);
      } else if (item is Map) {
        return OrderItem.fromJson(Map<String, dynamic>.from(item));
      }
      return OrderItem.fromJson({});
    }).toList();
    return OrderModel(
      id: json['id'].toString(),
      restaurantName: json['outlate']['name'].toString(),
      restaurantAddress:
          "${json['outlate']['address']?.toString()}, ${json['outlate']['city']?.toString()}, ${json['outlate']['state']?.toString()}",
      restaurantImage: json['outlate']['brandLogo']?.toString() ?? '',
      orderDate: DateFormat(
        'dd MMM, hh:mm a',
      ).format(DateTime.parse(json['placedAt'].toString()).toLocal()),
      totalAmount: double.parse(json['grandTotal'].toString()),
      status: json['orderStatus'].toString(),
      items: items,
    );
  }

  OrderModel copyWith({
    String? id,
    String? restaurantName,
    String? restaurantAddress,
    String? restaurantImage,
    String? orderDate,
    double? totalAmount,
    String? status,
    List<OrderItem>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      restaurantImage: restaurantImage ?? this.restaurantImage,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }
}

class MyOrdersScreenController extends GetxController {
  final storage = GetStorage();
  StreamSubscription? _orderStatusSubscription;
  StreamSubscription? _reconnectSubscription;
  final scrollController = ScrollController();
  final ordersList = <OrderModel>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final isNextPage = false.obs;
  final activeCount = 0.obs;
  final currentPage = 1.obs;
  final limit = 10.obs;
  final hasError = false.obs;
  final errorMessage = "".obs;
  final selectedStatus = "All".obs;
  final statusOptions = ["All", "Pending", "Ongoing", "Delivered", "Cancelled"];

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchOrders(page: 1, isRefresh: true);
    ever(selectedStatus, (_) {
      fetchOrders(page: 1, isRefresh: true);
    });
    _listenToOrderStatusUpdate();
    _listenToSocketReconnect();
  }

  @override
  void onClose() {
    scrollController.dispose();
    _orderStatusSubscription?.cancel();
    _reconnectSubscription?.cancel();
    super.onClose();
  }

  void _listenToSocketReconnect() {
    _reconnectSubscription = SocketService().onReconnected.listen((_) {
      debugPrint(
        "MyOrdersScreenController => Socket reconnected: refreshing orders",
      );
      fetchOrders(page: 1, isRefresh: true);
    });
  }

  void _scrollListener() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
      if (!isLoading.value && !isMoreLoading.value && isNextPage.value) {
        fetchOrders(page: currentPage.value + 1);
      }
    }
  }

  void _listenToOrderStatusUpdate() {
    _orderStatusSubscription = SocketService().onOrderStatusReceived.listen((
      data,
    ) {
      debugPrint(
        "📦 Socket orderStatusUpdate received in MyOrdersScreenController: $data",
      );
      if (data == null) return;
      try {
        if (data is Map && data.isNotEmpty) {
          final newStatus = data['orderStatus']?.toString();
          final orderId = data['orderId']?.toString();
          if (newStatus != null && orderId != null) {
            final index = ordersList.indexWhere((x) => x.id == orderId);
            if (index != -1) {
              ordersList[index] = ordersList[index].copyWith(status: newStatus);
              if (selectedStatus.value == "All") {
                ordersList.refresh();
              } else if (selectedStatus.value == "Pending") {
                ordersList.removeWhere((x) => x.status != "placed");
                ordersList.refresh();
              } else if (selectedStatus.value == "Ongoing") {
                ordersList.removeWhere(
                  (x) =>
                      x.status == "placed" ||
                      x.status == "delivered" ||
                      x.status == "cancelled",
                );
                ordersList.refresh();
              } else if (selectedStatus.value == "Delivered") {
                ordersList.removeWhere((x) => x.status != "delivered");
                ordersList.refresh();
              } else if (selectedStatus.value == "Cancelled") {
                ordersList.removeWhere((x) => x.status != "cancelled");
                ordersList.refresh();
              } else {
                ordersList.refresh();
              }
              update();
            }
          }
        }
      } catch (e) {
        debugPrint(
          "MyOrdersScreenController => Error updating order status: $e",
        );
      }
    });
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

  Future<void> fetchOrders({int page = 1, bool isRefresh = false}) async {
    if (isLoading.value || isMoreLoading.value) return;
    if (isRefresh || page == 1) {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = "";
    } else {
      isMoreLoading.value = true;
    }
    try {
      final statusParam = selectedStatus.value.toLowerCase() == 'all'
          ? 'all'
          : selectedStatus.value.toLowerCase() == 'pending'
          ? 'pending'
          : selectedStatus.value.toLowerCase() == 'ongoing'
          ? 'ongoing'
          : selectedStatus.value.toLowerCase() == 'delivered'
          ? 'delivered'
          : selectedStatus.value.toLowerCase() == 'cancelled'
          ? 'cancelled'
          : selectedStatus.value.toLowerCase();
      final url = ApiServices.getOrders
          .replaceAll('{page}', page.toString())
          .replaceAll('{status}', statusParam);

      print('fetchOrders URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('fetchOrders Status: ${response.statusCode}');
      print('fetchOrders Body: ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'];
          final rawOrders = data['orders'] as List<dynamic>? ?? [];
          final newItems = rawOrders.map<OrderModel>((item) {
            if (item is Map<String, dynamic>) {
              return OrderModel.fromJson(item);
            } else if (item is Map) {
              return OrderModel.fromJson(Map<String, dynamic>.from(item));
            }
            return OrderModel.fromJson({});
          }).toList();
          currentPage.value = data['page'] is int
              ? data['page']
              : int.tryParse(data['page']?.toString() ?? '') ?? page;
          limit.value = data['limit'] is int
              ? data['limit']
              : int.tryParse(data['limit']?.toString() ?? '') ?? 10;
          isNextPage.value = data['isNextPage'] == true;
          activeCount.value = data['activeCount'] is int
              ? data['activeCount']
              : int.tryParse(data['activeCount']?.toString() ?? '') ?? 0;
          if (isRefresh || page == 1) {
            ordersList.assignAll(newItems);
          } else {
            ordersList.addAll(newItems);
          }
        } else {
          if (isRefresh || page == 1) {
            ordersList.clear();
          }
          isNextPage.value = false;
        }
      } else {
        hasError.value = true;
        errorMessage.value = "Failed to fetch orders";
        if (isRefresh || page == 1) {
          ordersList.clear();
        }
      }
    } catch (e) {
      print('fetchOrders Error: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
      if (isRefresh || page == 1) {
        ordersList.clear();
      }
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  List<OrderModel> get filteredOrders {
    return ordersList;
  }
}

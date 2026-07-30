import 'package:get/get.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final int quantity;
  final bool isVeg;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.isVeg,
  });

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    int? quantity,
    bool? isVeg,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      isVeg: isVeg ?? this.isVeg,
    );
  }
}

class CartController extends GetxController {
  // RxList to maintain cart items reactively
  final cartItems = <CartItem>[].obs;

  // Add an item to the cart, or increase its quantity if it already exists
  void addItem({
    required String id,
    required String name,
    required double price,
    required String image,
    required bool isVeg,
  }) {
    int index = cartItems.indexWhere((element) => element.id == id);
    if (index >= 0) {
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + 1,
      );
    } else {
      cartItems.add(
        CartItem(
          id: id,
          name: name,
          price: price,
          image: image,
          quantity: 1,
          isVeg: isVeg,
        ),
      );
    }
  }

  // Getters for cart details
  bool get isEmpty => cartItems.isEmpty;

  int get totalItemCount {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }
}

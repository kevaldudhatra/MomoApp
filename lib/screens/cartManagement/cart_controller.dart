import 'package:get/get.dart';

class CartItem {
  final int id;
  final String categoryName;
  final String name;
  final String description;
  final double price;
  final String image;
  final int quantity;
  final bool isVeg;

  CartItem({
    required this.id,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.quantity,
    required this.isVeg,
  });

  CartItem copyWith({
    int? id,
    String? categoryName,
    String? name,
    String? description,
    double? price,
    String? image,
    int? quantity,
    bool? isVeg,
  }) {
    return CartItem(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      isVeg: isVeg ?? this.isVeg,
    );
  }
}

class CartController extends GetxController {
  final cartItems = <CartItem>[].obs;

  void addItemToCart({
    required int id,
    required String categoryName,
    required String name,
    required String description,
    required double price,
    required String image,
    required bool isVeg,
  }) {
    cartItems.add(
      CartItem(
        id: id,
        categoryName: categoryName,
        name: name,
        description: description,
        price: price,
        image: image,
        quantity: 0,
        isVeg: isVeg,
      ),
    );
    cartItems.refresh();
  }

  bool get isEmpty => cartItems.isEmpty;

  int get totalItemCount {
    return cartItems.length;
  }
}

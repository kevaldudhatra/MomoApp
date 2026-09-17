import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

class CartController extends GetxController {
  final storage = GetStorage();
  RxList<dynamic> cartItems = [].obs;
  RxMap<dynamic, dynamic> billDetails = {}.obs;

  Future<void> getCartItem() async {
    try {
      cartItems.clear();
      billDetails.value = {};
      final response = await http.get(
        Uri.parse(ApiServices.getCartItem),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getCartItem Response status: ${response.statusCode}');
      print('getCartItem Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        cartItems.addAll(data["data"]["items"]);
        billDetails.value = data["data"]["bill"];
        cartItems.refresh();
        billDetails.refresh();
      } else {
        cartItems.clear();
        cartItems.refresh();
        billDetails.value = {};
        billDetails.refresh();
      }
    } catch (e) {
      print('getCartItem Error: $e');
      cartItems.refresh();
      billDetails.refresh();
    }
  }

  void addItemToCart({
    required List<dynamic> cartItem,
    required Map<dynamic, dynamic> billData,
  }) {
    if (cartItem.isNotEmpty) {
      cartItems.clear();
      cartItems.addAll(cartItem);
      cartItems.refresh();
      billDetails.value = billData;
      billDetails.refresh();
    } else {
      cartItems.clear();
      cartItems.refresh();
      billDetails.value = {};
      billDetails.refresh();
    }
  }

  bool get isEmpty => cartItems.isEmpty;

  int get totalItemCount {
    return cartItems.length;
  }
}

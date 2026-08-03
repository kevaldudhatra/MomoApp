import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/outletScreen/outlet_screen_controller.dart';
import 'package:momos/utils/const_image_key.dart';

class DeliveryScreenController extends GetxController {
  final isSearchEmpty = true.obs;
  final searchController = TextEditingController();
  final categories = <FoodItem>[].obs;

  @override
  void onInit() {
    searchController.addListener(() {
      isSearchEmpty.value = searchController.text.isEmpty;
    });
    categories.assignAll([
      FoodItem(
        id: 1,
        name: "Smokey Chilli Paneer",
        description: "Indulge in our spicy chilli panner flavor",
        price: 350,
        originalPrice: 450,
        isVeg: true,
        isBestseller: true,
        customization: "Choice of noodles(veg/chicken/shrimp/mix)",
        image: AppImages().menuItemOne,
        hasCustomise: true,
      ),
      FoodItem(
        id: 2,
        name: "Smokey Chilli Paneer",
        description: "Indulge in our spicy chilli panner flavor",
        price: 350,
        isVeg: true,
        isBestseller: true,
        customization: "Choice of noodles(veg/chicken/shrimp/mix)",
        image: AppImages().menuItemOne,
        hasCustomise: false,
      ),
      FoodItem(
        id: 3,
        name: "Smokey Chilli Paneer",
        description: "Indulge in our spicy chilli panner flavor",
        price: 350,
        originalPrice: 450,
        isVeg: true,
        customization: "Choice of noodles(veg/chicken/shrimp/mix)",
        image: AppImages().menuItemTwo,
        hasCustomise: true,
      ),
    ]);
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

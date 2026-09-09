import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/screens/outletScreen/outlet_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

class DeliveryScreenController extends GetxController {
  final storage = GetStorage();
  final isSearchEmpty = true.obs;
  final isLoading = true.obs;
  final searchController = TextEditingController();
  final outlateDetails = {}.obs;
  final outletCategories = [].obs;
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
    getCurrentLocation();
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await getOutletDetails(LatLng(22.5687828, 88.4330432));
        Get.snackbar(
          "Location Disabled",
          "Please enable location services in your device settings.",
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.location_off, color: Colors.orange),
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await getOutletDetails(LatLng(22.5687828, 88.4330432));
          Get.snackbar(
            "Permission Denied",
            "Location permissions are denied.",
            snackPosition: SnackPosition.TOP,
            icon: const Icon(Icons.error, color: Colors.red),
            backgroundColor: charcoalGray.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await getOutletDetails(LatLng(22.5687828, 88.4330432));
        Get.snackbar(
          "Permission Denied",
          "Location permissions are permanently denied. Please enable them in app settings.",
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.settings, color: Colors.red),
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);
      await getOutletDetails(currentLatLng);
    } catch (e) {
      await getOutletDetails(LatLng(22.5687828, 88.4330432));
      print("Error fetching current location: $e");
      Get.snackbar(
        "Location Error",
        "Could not fetch current location. Please try again.",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  Future<void> getOutletDetails(LatLng latLng) async {
    try {
      outletCategories.clear();
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(
          ApiServices.getOutlateByLocation
              .replaceAll('{latitude}', latLng.latitude.toString())
              .replaceAll('{longitude}', latLng.longitude.toString()),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getOutletDetails Response status: ${response.statusCode}');
      print('getOutletDetails Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        outletCategories.addAll(data["data"]["categories"]);
        outlateDetails.value = data["data"]["outlate"];
      } else {
        outletCategories.clear();
        outlateDetails.value = {};
      }
    } catch (e) {
      print('getOutletDetails Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

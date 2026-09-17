import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/network/env.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:momos/screens/cartManagement/cart_controller.dart';
import 'package:http/http.dart' as http;

class DeliveryScreenController extends GetxController {
  final storage = GetStorage();
  final searchController = TextEditingController();
  RxBool isSearchEmpty = true.obs;
  RxBool isLoading = true.obs;
  RxMap<dynamic, dynamic> outlateDetails = {}.obs;
  RxList<dynamic> outletBanners = [].obs;
  RxList<dynamic> outletCategories = [].obs;
  RxList<dynamic> outletTopPicks = [].obs;
  RxString selectedAddress = "".obs;
  RxString addressType = "Home".obs;

  @override
  void onInit() {
    searchController.addListener(() {
      isSearchEmpty.value = searchController.text.isEmpty;
    });
    loadData();
    super.onInit();
  }

  Future<void> loadData() async {
    await getCurrentLocation();
    await Get.find<CartController>().getCartItem();
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
      await getAddressFromLatLng(currentLatLng);
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

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$googleMapApiKey',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' &&
            data['results'] is List &&
            (data['results'] as List).isNotEmpty) {
          final formatted =
              data['results'][0]['formatted_address']?.toString() ?? '';
          if (formatted.isNotEmpty) {
            addressType.value = "Home";
            selectedAddress.value = formatted;
          }
        }
      }
    } catch (e) {
      print("Error fetching address from LatLng: $e");
    }
  }

  Future<void> getOutletDetails(LatLng latLng) async {
    print('getOutletDetails Input: $latLng');
    try {
      outletBanners.clear();
      outletCategories.clear();
      outletTopPicks.clear();
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
        outlateDetails.value = data["data"]["outlate"] ?? {};
        outletBanners.assignAll(data["data"]["banners"] ?? []);
        outletCategories.addAll(data["data"]["categories"] ?? []);
        outletTopPicks.addAll(data["data"]["topPicks"] ?? []);
      } else {
        outlateDetails.value = {};
        outletBanners.clear();
        outletCategories.clear();
        outletTopPicks.clear();
      }
    } catch (e) {
      print('getOutletDetails Error: $e');
      outlateDetails.value = {};
      outletBanners.clear();
      outletCategories.clear();
      outletTopPicks.clear();
    } finally {
      isLoading.value = false;
    }
  }
}

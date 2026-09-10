import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:momos/network/env.dart';
import 'package:momos/screens/searchAddressScreen/search_address_screen_controller.dart';
import 'package:momos/utils/const_key.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:http/http.dart' as http;

class SavedAddress {
  final int id;
  final String type;
  final String address;
  final String icon;
  final bool isDefault;

  SavedAddress({
    required this.id,
    required this.type,
    required this.address,
    required this.icon,
    required this.isDefault,
  });
}

class SavedAddressWithLatLng {
  final int id;
  final String type;
  final String address;
  final String icon;
  final bool isDefault;
  final double latitude;
  final double longitude;

  SavedAddressWithLatLng({
    required this.id,
    required this.type,
    required this.address,
    required this.icon,
    required this.isDefault,
    required this.latitude,
    required this.longitude,
  });
}

class AddressSelectionScreenController extends GetxController {
  final storage = GetStorage();
  final searchController = TextEditingController();
  final savedAddresses = <SavedAddressWithLatLng>[].obs;
  RxBool mainLoading = false.obs;
  RxBool currentLocationLoading = false.obs;
  Timer? _debounceTimer;
  final placePredictions = <PlacePrediction>[].obs;
  final isSearchingPlaces = false.obs;
  final showSuggestions = false.obs;

  @override
  void onInit() {
    getUserAddress();
    super.onInit();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> getUserAddress() async {
    try {
      mainLoading.value = true;
      savedAddresses.clear();
      final response = await http.get(
        Uri.parse(ApiServices.userAddress),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getUserAddress Response status: ${response.statusCode}');
      print('getUserAddress Response body: ${response.body}');
      mainLoading.value = false;
      if (response.statusCode != 200) {
        savedAddresses.clear();
        return;
      }
      final data = jsonDecode(response.body);
      if (data['success'] != true || data['data'] is! List) {
        savedAddresses.clear();
        return;
      }
      final addresses = data['data'] as List;
      savedAddresses.assignAll(
        addresses.map<SavedAddressWithLatLng>((address) {
          final type = address['type']?.toString() ?? '';
          final icon = switch (type) {
            'Home' => AppImages().homeIcon,
            'Work' => AppImages().workIcon,
            _ => AppImages().locationIcon,
          };
          final subtitle =
              [
                    address['houseNo'],
                    address['appartment'],
                    address['landmark'],
                    address['city'],
                  ]
                  .where(
                    (value) =>
                        value != null && value.toString().trim().isNotEmpty,
                  )
                  .join(', ');
          final pinCode = address['pinCode']?.toString() ?? '';
          return SavedAddressWithLatLng(
            id: address['id'],
            type: type,
            address: '$subtitle - $pinCode.',
            icon: icon,
            isDefault: address['isDefault'],
            latitude: address['latitude'],
            longitude: address['longitude'],
          );
        }),
      );
    } catch (e) {
      savedAddresses.clear();
      mainLoading.value = false;
      print('getUserAddress Error: $e');
    }
  }

  Future<void> useCurrentLocation() async {
    try {
      currentLocationLoading.value = true;
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final currentLatLng = LatLng(position.latitude, position.longitude);
      await getAddressFromLatLng(currentLatLng);
    } catch (e) {
      print("Error fetching current location: $e");
    }
  }

  void addNewAddress() {
    Get.toNamed(Routes.searchAddressScreen);
  }

  void selectAddress(SavedAddressWithLatLng address) {
    Get.back(
      result: {
        "selectedAddress": address.address,
        "addressType": address.type,
        "latitude": address.latitude,
        "longitude": address.longitude,
      },
    );
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
            Get.back(
              result: {
                "selectedAddress": formatted,
                "addressType": "Home",
                "latitude": latLng.latitude,
                "longitude": latLng.longitude,
              },
            );
          }
        }
      }
    } catch (e) {
      print("Error fetching address from LatLng: $e");
    } finally {
      currentLocationLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      placePredictions.clear();
      showSuggestions.value = false;
      isSearchingPlaces.value = false;
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      isSearchingPlaces.value = true;
      try {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(query.trim())}&key=$googleMapApiKey',
        );
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'OK' && data['predictions'] != null) {
            final list = (data['predictions'] as List)
                .map((item) => PlacePrediction.fromJson(item))
                .toList();
            placePredictions.assignAll(list);
            showSuggestions.value = placePredictions.isNotEmpty;
          } else {
            placePredictions.clear();
            showSuggestions.value = false;
          }
        }
      } catch (e) {
        print("Error fetching autocomplete places: $e");
      } finally {
        isSearchingPlaces.value = false;
      }
    });
  }

  Future<void> selectPlace(PlacePrediction prediction) async {
    searchController.text = prediction.mainText;
    showSuggestions.value = false;
    placePredictions.clear();
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${prediction.placeId}&fields=name,geometry,formatted_address,address_components&key=$googleMapApiKey',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          final result = data['result'];
          final location = result['geometry']['location'];
          final double lat = (location['lat'] as num).toDouble();
          final double lng = (location['lng'] as num).toDouble();
          final String formattedAddress =
              result['formatted_address'] ?? prediction.description;
          Get.back(
            result: {
              "selectedAddress": formattedAddress,
              "addressType": "Home",
              "latitude": lat,
              "longitude": lng,
            },
          );
        }
      }
    } catch (e) {
      print("Error fetching place details: $e");
    }
  }

  void clearSearch() {
    searchController.clear();
    placePredictions.clear();
    showSuggestions.value = false;
  }
}

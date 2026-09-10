import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/network/env.dart';
import 'package:momos/screens/addressSelectionScreen/address_selection_screen_controller.dart';
import 'package:momos/screens/orderDetailScreen/order_detail_screen_controller.dart';
import 'package:momos/screens/profileScreen/profile_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/widgets/custom_text_field.dart';
import 'package:momos/widgets/loading_view.dart';
import 'package:http/http.dart' as http;

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting =
        json['structured_formatting'] as Map<String, dynamic>? ?? {};
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText:
          structuredFormatting['main_text'] ?? (json['description'] ?? ''),
      secondaryText: structuredFormatting['secondary_text'] ?? '',
    );
  }
}

class SearchAddressScreenController extends GetxController {
  GoogleMapController? mapController;
  Timer? _debounceTimer;
  final storage = GetStorage();
  final searchController = TextEditingController();
  final houseNumberController = TextEditingController();
  final apartmentController = TextEditingController();
  final landmarkController = TextEditingController();
  final addressType = "Home".obs;
  final addressTitle = "".obs;
  final addressSubtitle = "".obs;
  final city = "".obs;
  final state = "".obs;
  final country = "".obs;
  final pinCode = "".obs;
  final markers = <Marker>{}.obs;
  final selectedLocation = const LatLng(0.0, 0.0).obs;
  final placePredictions = <PlacePrediction>[].obs;
  final isSearchingPlaces = false.obs;
  final showSuggestions = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    houseNumberController.dispose();
    apartmentController.dispose();
    landmarkController.dispose();
    mapController?.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void updateMarker(LatLng location, String title, String snippet) {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: location,
        infoWindow: InfoWindow(title: title, snippet: snippet),
      ),
    );
  }

  void animateCameraTo(LatLng location, {double zoom = 16.0}) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: zoom),
      ),
    );
  }

  void clearSearch() {
    searchController.clear();
    placePredictions.clear();
    showSuggestions.value = false;
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
    addressTitle.value = "Fetching address...";
    addressSubtitle.value = "";
    houseNumberController.clear();
    apartmentController.clear();
    landmarkController.clear();
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
          final String name = result['name'] ?? prediction.mainText;
          final String formattedAddress =
              result['formatted_address'] ?? prediction.description;
          final newLatLng = LatLng(lat, lng);
          selectedLocation.value = newLatLng;
          addressTitle.value = name;
          addressSubtitle.value = formattedAddress;

          String streetNumber = "";
          String route = "";
          String sublocality = "";
          String extractedCity = "";
          String extractedState = "";
          String extractedCountry = "";
          String extractedPinCode = "";

          final components =
              result['address_components'] as List<dynamic>? ?? [];
          for (var comp in components) {
            final types =
                (comp['types'] as List<dynamic>?)?.cast<String>() ?? [];
            if (types.contains('street_number')) {
              streetNumber = comp['long_name'] ?? "";
            } else if (types.contains('route')) {
              route = comp['long_name'] ?? "";
            } else if (types.contains('sublocality') ||
                types.contains('sublocality_level_1')) {
              sublocality = comp['long_name'] ?? "";
            } else if (types.contains('locality')) {
              extractedCity = comp['long_name'] ?? "";
            } else if (types.contains('administrative_area_level_2') &&
                extractedCity.isEmpty) {
              extractedCity = comp['long_name'] ?? "";
            } else if (types.contains('administrative_area_level_1')) {
              extractedState = comp['long_name'] ?? "";
            } else if (types.contains('country')) {
              extractedCountry = comp['long_name'] ?? "";
            } else if (types.contains('postal_code')) {
              extractedPinCode = comp['long_name'] ?? "";
            }
          }

          city.value = extractedCity;
          state.value = extractedState;
          country.value = extractedCountry;
          pinCode.value = extractedPinCode;

          if (streetNumber.isNotEmpty) {
            houseNumberController.text = streetNumber;
          }
          if (sublocality.isNotEmpty || route.isNotEmpty) {
            apartmentController.text = [
              route,
              sublocality,
            ].where((s) => s.isNotEmpty).join(", ");
          } else {
            apartmentController.text = formattedAddress;
          }
          if (name != extractedCity &&
              name != extractedState &&
              name.isNotEmpty) {
            landmarkController.text = name;
          }
          updateMarker(newLatLng, name, formattedAddress);
          animateCameraTo(newLatLng);
        }
      }
    } catch (e) {
      print("Error fetching place details: $e");
    }
  }

  Future<void> onMapTapped(LatLng position) async {
    selectedLocation.value = position;
    updateMarker(position, "Selected Location", "Fetching address...");
    addressTitle.value = "Fetching address...";
    addressSubtitle.value = "";
    houseNumberController.clear();
    apartmentController.clear();
    landmarkController.clear();
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapApiKey',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          final firstResult = data['results'][0];
          final formatted = firstResult['formatted_address'] ?? '';
          String title = "Selected Location";
          String extractedCity = "";
          String extractedState = "";
          String extractedCountry = "";
          String extractedPinCode = "";

          final components =
              firstResult['address_components'] as List<dynamic>? ?? [];
          for (var comp in components) {
            final types =
                (comp['types'] as List<dynamic>?)?.cast<String>() ?? [];
            if (types.contains('sublocality') ||
                types.contains('locality') ||
                types.contains('neighborhood') ||
                types.contains('point_of_interest')) {
              if (title == "Selected Location") {
                title = comp['long_name'] ?? title;
              }
            }
            if (types.contains('locality')) {
              extractedCity = comp['long_name'] ?? "";
            } else if (types.contains('administrative_area_level_2') &&
                extractedCity.isEmpty) {
              extractedCity = comp['long_name'] ?? "";
            } else if (types.contains('administrative_area_level_1')) {
              extractedState = comp['long_name'] ?? "";
            } else if (types.contains('country')) {
              extractedCountry = comp['long_name'] ?? "";
            } else if (types.contains('postal_code')) {
              extractedPinCode = comp['long_name'] ?? "";
            }
          }

          city.value = extractedCity;
          state.value = extractedState;
          country.value = extractedCountry;
          pinCode.value = extractedPinCode;

          addressTitle.value = title;
          addressSubtitle.value = formatted;
          apartmentController.text = formatted;
          updateMarker(position, title, formatted);
        }
      }
    } catch (e) {
      print("Error reverse geocoding: $e");
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
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

      Get.snackbar(
        "Current Location",
        "Fetching current location...",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.my_location, color: orange),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);
      await onMapTapped(currentLatLng);
      animateCameraTo(currentLatLng);
    } catch (e) {
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

  Future<void> saveAddress() async {
    if (houseNumberController.text.trim().isEmpty) {
      Get.snackbar(
        "Required Field",
        "Please enter House / Flat No",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }
    if (apartmentController.text.trim().isEmpty) {
      Get.snackbar(
        "Required Field",
        "Please enter Appartment / road / area",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    print("house Number : ${houseNumberController.text}");
    print("apartment : ${apartmentController.text}");
    print("landmark : ${landmarkController.text}");
    print("addressType : ${addressType.value}");
    print("addressTitle : ${addressTitle.value}");
    print("addressSubtitle : ${addressSubtitle.value}");
    print("city : ${city.value}");
    print("state : ${state.value}");
    print("country : ${country.value}");
    print("pinCode : ${pinCode.value}");

    await addUserAddress();
  }

  Future<void> addUserAddress() async {
    try {
      Get.dialog(const LoadingDialog(), barrierDismissible: false);
      final response = await http.post(
        Uri.parse(ApiServices.userAddress),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode({
          "address": apartmentController.text,
          "type": addressType.value,
          "latitude": selectedLocation.value.latitude,
          "longitude": selectedLocation.value.longitude,
          "houseNo": houseNumberController.text,
          "appartment": apartmentController.text,
          "landmark": landmarkController.text,
          "city": city.value,
          "State": state.value,
          "country": country.value,
          "pinCode":
              int.tryParse(pinCode.value) ??
              (pinCode.value.isNotEmpty ? pinCode.value : 0),
          "isDefault": addressType.value == 'Home' ? true : false,
        }),
      );
      print('addUserAddress Response status: ${response.statusCode}');
      print('addUserAddress Response body: ${response.body}');
      if (Get.isDialogOpen!) {
        Get.back();
      }
      if (response.statusCode == 201) {
        Get.back();
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (storage.read(isFromProfile) == true) {
            storage.remove(isFromProfile);
            if (Get.isRegistered<ProfileScreenController>()) {
              await Get.find<ProfileScreenController>().getUserAddress();
            }
          } else if (storage.read(isFromOrder) == true) {
            storage.remove(isFromOrder);
            if (Get.isRegistered<OrderDetailScreenController>()) {
              await Get.find<OrderDetailScreenController>().getUserAddress();
            }
          } else {
            if (Get.isRegistered<AddressSelectionScreenController>()) {
              await Get.find<AddressSelectionScreenController>()
                  .getUserAddress();
            }
          }
          Get.back();
        });
      } else {
        Get.snackbar(
          "Error",
          "Failed to add address",
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.error, color: Colors.red),
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('addUserAddress Error: $e');
      if (Get.isDialogOpen!) {
        Get.back();
      }
      Get.snackbar(
        "Error",
        "Failed to add address",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  void showAddAddressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: dialogBarrierColor,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 55),
                decoration: const BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address details row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            AppImages().addressPinIcon,
                            width: 32,
                            height: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(
                                  () => Text(
                                    addressTitle.value,
                                    style: const TextStyle(
                                      color: black,
                                      fontSize: 16,
                                      fontFamily: natoBold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(
                                  () => Text(
                                    addressSubtitle.value,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: charcoalGray,
                                      fontSize: 13,
                                      fontFamily: natoRegular,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, thickness: 1, color: borderGray),
                      const SizedBox(height: 16),

                      // Category selection title
                      const Text(
                        "Save address as",
                        style: TextStyle(
                          color: charcoalGray,
                          fontSize: 14,
                          fontFamily: natoMedium,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Segmented category picker
                      Container(
                        decoration: BoxDecoration(
                          color: segmentedBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Obx(
                          () => Row(
                            children: [
                              buildSegmentedItem(
                                title: "Home",
                                iconPath: AppImages().homeIcon,
                                isSelected: addressType.value == "Home",
                                onTap: () => addressType.value = "Home",
                              ),
                              buildSegmentedItem(
                                title: "Work",
                                iconPath: AppImages().workIcon,
                                isSelected: addressType.value == "Work",
                                onTap: () => addressType.value = "Work",
                              ),
                              buildSegmentedItem(
                                title: "Other",
                                iconPath: AppImages().locationIcon,
                                isSelected: addressType.value == "Other",
                                onTap: () => addressType.value = "Other",
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input Fields
                      CustomTextField(
                        labelText: "House / Flat No*",
                        hintText: "House / Flat No",
                        textEditingController: houseNumberController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        labelText: "Appartment / road / area*",
                        hintText: "Appartment / road / area",
                        textEditingController: apartmentController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        labelText: "Nearby Landmark",
                        hintText: "Nearby Landmark",
                        textEditingController: landmarkController,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      CustomButton(
                        width: MediaQuery.of(context).size.width,
                        label: "Save Address",
                        onTap: () => saveAddress(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Floating circular close button
              Positioned(
                top: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: black,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        AppImages().closeIcon,
                        width: 18,
                        height: 18,
                        color: white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildSegmentedItem({
    required String title,
    required String iconPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: cardShadow,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 18,
                height: 18,
                color: isSelected ? orange : textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? orange : textSecondary,
                  fontSize: 14,
                  fontFamily: isSelected ? natoMedium : natoRegular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/addressSelectionScreen/address_selection_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/widgets/custom_text_field.dart';
import 'package:momos/widgets/loading_view.dart';
import 'package:http/http.dart' as http;

class SearchAddressScreenController extends GetxController {
  final storage = GetStorage();
  final searchController = TextEditingController();
  final houseNumberController = TextEditingController();
  final apartmentController = TextEditingController();
  final landmarkController = TextEditingController();
  final addressType = "Home".obs;
  final addressTitle = "".obs;
  final addressSubtitle = "".obs;

  @override
  void onClose() {
    searchController.dispose();
    houseNumberController.dispose();
    apartmentController.dispose();
    landmarkController.dispose();
    super.onClose();
  }

  void getCurrentLocation() {
    Get.snackbar(
      "Current Location",
      "Updating map to current location...",
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.done, color: Colors.green),
      backgroundColor: charcoalGray.withValues(alpha: 0.9),
      colorText: Colors.white,
    );

    // Simulate location update
    Future.delayed(const Duration(milliseconds: 800), () {
      addressTitle.value = "Rajkot";
      addressSubtitle.value =
          "Galaxy complex, Near race course circle, Rajkot, Gujarat, 360001.";
      houseNumberController.text = "Flat A1";
      apartmentController.text = "Galaxy complex";
      landmarkController.text = "Near race course circle";
    });
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

    await addUserAddress();
  }

  Future<void> addUserAddress() async {
    try {
      Get.dialog(const LoadingDialog(), barrierDismissible: false);
      final response = await http.post(
        Uri.parse(ApiServices.addUserAddress),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode({
          "address": apartmentController.text,
          "type": addressType.value,
          "latitude": 22.312842,
          "longitude": 70.826378,
          "houseNo": houseNumberController.text,
          "appartment": apartmentController.text,
          "landmark": landmarkController.text,
          "city": "Rajkot",
          "State": "Gujarat",
          "country": "India",
          "pinCode": 360003,
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
        Future.delayed(const Duration(milliseconds: 500), () {
          if (Get.isRegistered<AddressSelectionScreenController>()) {
            Get.delete<AddressSelectionScreenController>();
          }
          Get.toNamed(Routes.addressSelectionScreen);
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

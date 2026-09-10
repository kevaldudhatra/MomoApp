import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/accountAccessScreen/account_access_screen_controller.dart';
import 'package:momos/screens/addressSelectionScreen/address_selection_screen_controller.dart';
import 'package:momos/screens/orderDetailScreen/order_detail_screen_controller.dart';
import 'package:momos/screens/searchAddressScreen/search_address_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:http/http.dart' as http;

class ProfileScreenController extends GetxController {
  final storage = GetStorage();
  RxBool mainLoading = false.obs;
  RxList<SavedAddress> userAddressList = <SavedAddress>[].obs;
  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  RxInt selectedAddressId = 0.obs;
  RxString addressTitle = "".obs;

  @override
  void onInit() {
    loadUserDetails();
    super.onInit();
  }

  void loadUserDetails() async {
    mainLoading.value = true;
    await getUserProfile();
    await getUserAddress();
    mainLoading.value = false;
  }

  void showAddressBottomSheet(BuildContext ctx) {
    AddressSelectionBottomSheet.show(
      ctx,
      addresses: userAddressList,
      selectedTitle: addressTitle,
      selectedAddressId: selectedAddressId,
      onDeleteAddress: (address) async {
        bool isDeleted = await deleteUserAddress(address.id);
        if (isDeleted) {
          userAddressList.removeWhere((element) => element.id == address.id);
          if (userAddressList.isNotEmpty) {
            final defaultAddress = userAddressList.firstWhere(
              (element) => element.isDefault,
              orElse: () => userAddressList.first,
            );
            selectedAddressId.value = defaultAddress.id;
            addressTitle.value = defaultAddress.type;
          }
        }
      },
      onSelect: (address) {
        selectedAddressId.value = address.id;
        addressTitle.value = address.type;
        Get.back();
      },
      onAddNewAddress: () async {
        await storage.write(isFromProfile, true);
        await storage.write(isFromOrder, false);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (Get.isRegistered<SearchAddressScreenController>()) {
            Get.delete<SearchAddressScreenController>();
          }
          Get.toNamed(Routes.searchAddressScreen);
        });
      },
    );
  }

  void showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: dialogBarrierColor,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular icon background
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: logoutIconBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  AppImages().logoutIcon,
                  width: 24,
                  height: 24,
                  color: orange,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "We are sad to see you go!",
                style: TextStyle(
                  color: black,
                  fontSize: 18,
                  fontFamily: natoBold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Are you sure you want to logout?",
                style: TextStyle(
                  color: charcoalGray,
                  fontSize: 14,
                  fontFamily: natoRegular,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: "Cancel",
                      isEnabled: false,
                      onTap: () => Get.back(),
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      label: "Logout",
                      onTap: () async {
                        Get.back();
                        final google = GoogleAuthService();
                        await google.signOutWithGoogle();
                        final storage = GetStorage();
                        await storage.erase();
                        Get.offAllNamed(Routes.startScreen);
                      },
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> getUserProfile() async {
    var response = await http.get(
      Uri.parse(ApiServices.getAndUpdateProfile),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "${storage.read(userToken)}",
      },
    );
    print('getUserProfile Response status: ${response.statusCode}');
    print('getUserProfile Response body: ${response.body}');
    var data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["success"] == true) {
      userData.value = data["data"];
    } else {
      userData.value = {};
    }
  }

  Future<void> getUserAddress() async {
    try {
      final response = await http.get(
        Uri.parse(ApiServices.userAddress),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getUserAddress Response status: ${response.statusCode}');
      print('getUserAddress Response body: ${response.body}');
      if (response.statusCode != 200) {
        userAddressList.clear();
        return;
      }
      final data = jsonDecode(response.body);
      if (data['success'] != true || data['data'] is! List) {
        userAddressList.clear();
        return;
      }
      final addresses = data['data'] as List;
      userAddressList.assignAll(
        addresses.map<SavedAddress>((address) {
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
          return SavedAddress(
            id: address['id'],
            type: type,
            address: '$subtitle - $pinCode.',
            icon: icon,
            isDefault: address['isDefault'],
          );
        }),
      );
      if (userAddressList.isNotEmpty) {
        final defaultAddress = userAddressList.firstWhere(
          (element) => element.isDefault,
          orElse: () => userAddressList.first,
        );
        selectedAddressId.value = defaultAddress.id;
        addressTitle.value = defaultAddress.type;
      }
    } catch (e) {
      userAddressList.clear();
      print('getUserAddress Error: $e');
    }
  }

  Future<bool> deleteUserAddress(int addressId) async {
    try {
      var response = await http.delete(
        Uri.parse(
          ApiServices.deleteUserAddress.replaceFirst(
            "{addressId}",
            addressId.toString(),
          ),
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "${storage.read(userToken)}",
        },
      );
      print('deleteUserAddress Response status: ${response.statusCode}');
      print('deleteUserAddress Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('deleteUserAddress Error: $e');
      return false;
    }
  }
}

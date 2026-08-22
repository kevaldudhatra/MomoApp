import 'dart:convert';
import 'package:get/get.dart';
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

class AddressSelectionScreenController extends GetxController {
  final storage = GetStorage();
  final savedAddresses = <SavedAddress>[].obs;
  RxBool mainLoading = false.obs;

  @override
  void onInit() {
    getUserAddress();
    super.onInit();
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
    } catch (e) {
      savedAddresses.clear();
      mainLoading.value = false;
      print('getUserAddress Error: $e');
    }
  }

  void useCurrentLocation() {
    Get.toNamed(Routes.searchAddressScreen);
  }

  void addNewAddress() {
    Get.toNamed(Routes.searchAddressScreen);
  }

  void selectAddress(SavedAddress address) {
    print("Selected: $address");
  }
}

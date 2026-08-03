import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_image_key.dart';

class SavedAddress {
  final String id;
  final String type;
  final String address;
  final String icon;

  SavedAddress({
    required this.id,
    required this.type,
    required this.address,
    required this.icon,
  });
}

class AddressSelectionScreenController extends GetxController {
  final savedAddresses = <SavedAddress>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAddresses();
  }

  void _loadAddresses() {
    savedAddresses.assignAll([
      SavedAddress(
        id: "1",
        type: "Home",
        address:
            "Aditya Mehta, 123, Sunrise Apartments, Yagnik Road, Rajkot - 360001",
        icon: AppImages().homeIcon,
      ),
      SavedAddress(
        id: "2",
        type: "Work",
        address:
            "201 Jaynath Complex, Gondal Rd, Makkam Chowk, Rajkot, Gujarat 360002",
        icon: AppImages().workIcon,
      ),
      SavedAddress(
        id: "3",
        type: "Other",
        address:
            "201 Jaynath Complex, Gondal Rd, Makkam Chowk, Rajkot, Gujarat 360002",
        icon: AppImages().locationIcon,
      ),
    ]);
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

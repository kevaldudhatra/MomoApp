import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/accountAccessScreen/account_access_screen_controller.dart';
import 'package:momos/screens/orderDetailScreen/order_detail_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';

class ProfileScreenController extends GetxController {
  final userAddressList = <SavedAddress>[].obs;
  final addressTitle = "Other".obs;
  final addressSubtitle =
      "201 Jaynath Complex, Gondal Rd, Makkam Chowk, Rajkot, Gujarat 360002"
          .obs;

  @override
  void onInit() {
    super.onInit();
    _loadAddress();
  }

  void _loadAddress() {
    userAddressList.assignAll([
      SavedAddress(
        title: "Home",
        subtitle:
            "Aditya Mehta, 123, Sunrise Apartments, Yagnik Road, Rajkot - 360001",
        icon: AppImages().homeIcon,
      ),
      SavedAddress(
        title: "Other",
        subtitle:
            "201 Jaynath Complex, Gondal Rd, Makkam Chowk, Rajkot, Gujarat 360002",
        icon: AppImages().homeIcon,
      ),
    ]);
  }

  void showAddressBottomSheet(BuildContext ctx) {
    AddressSelectionBottomSheet.show(
      ctx,
      addresses: userAddressList,
      selectedTitle: addressTitle.value,
      onSelect: (address) {
        addressTitle.value = address.title;
        addressSubtitle.value = address.subtitle;
        Get.back();
      },
      onAddNewAddress: () {
        Get.back();
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
}

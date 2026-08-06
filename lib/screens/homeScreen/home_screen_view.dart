import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/screens/homeScreen/home_screen_controller.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_view.dart';
import 'package:momos/screens/diningScreen/dining_screen_view.dart';
import 'package:momos/screens/profileScreen/profile_screen_view.dart';

class HomeScreen extends GetView<HomeScreenController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: SafeArea(
        child: Obx(
          () => Scaffold(
            body: IndexedStack(
              index: controller.selectedIndex.value,
              children: const [
                DeliveryScreen(),
                DiningScreen(),
                ProfileScreen(),
              ],
            ),
            bottomNavigationBar: Container(
              height: 65,
              width: MediaQuery.of(context).size.width,
              color: white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (controller.selectedIndex.value != 0) {
                        controller.changeIndex(0);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages().deliveryIcon,
                          height: 25,
                          width: 25,
                          color: controller.selectedIndex.value == 0
                              ? orange
                              : charcoalGray,
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          "Delivery",
                          style: TextStyle(
                            color: controller.selectedIndex.value == 0
                                ? orange
                                : charcoalGray,
                            fontFamily: dmRegular,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (controller.selectedIndex.value != 1) {
                        controller.changeIndex(1);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages().diningIcon,
                          height: 25,
                          width: 25,
                          color: controller.selectedIndex.value == 1
                              ? orange
                              : charcoalGray,
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          "Dining",
                          style: TextStyle(
                            color: controller.selectedIndex.value == 1
                                ? orange
                                : charcoalGray,
                            fontFamily: dmRegular,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (controller.selectedIndex.value != 2) {
                        controller.changeIndex(2);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages().profileIcon,
                          height: 25,
                          width: 25,
                          color: controller.selectedIndex.value == 2
                              ? orange
                              : charcoalGray,
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          "Profile",
                          style: TextStyle(
                            color: controller.selectedIndex.value == 2
                                ? orange
                                : charcoalGray,
                            fontFamily: dmRegular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

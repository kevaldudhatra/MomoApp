import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/searchAddressScreen/search_address_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/widgets/custom_text_field.dart';

class SearchAddressScreen extends GetView<SearchAddressScreenController> {
  const SearchAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: white,
        body: Column(
          children: [
            // Header / App Bar
            Container(
              width: double.infinity,
              color: white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Image.asset(
                      AppImages().backArrowIcon,
                      width: 20,
                      height: 20,
                      color: black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Select delivery address",
                    style: TextStyle(
                      color: black,
                      fontSize: 20,
                      fontFamily: natoBold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: borderGray),

            // Map and Floating Actions Stack
            Expanded(
              child: Stack(
                children: [
                  // Map Background Image
                  Positioned.fill(
                    child: Image.asset(AppImages().mapImg, fit: BoxFit.cover),
                  ),

                  // Floating Search Bar at the Top
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: cardShadow,
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomTextField(
                        hintText: "Search location",
                        textEditingController: controller.searchController,
                        keyboardType: TextInputType.webSearch,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(right: 5, left: 15),
                          child: Image.asset(
                            AppImages().searchIcon,
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Docked Address Details Card
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () => controller.getCurrentLocation(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: cardShadow,
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    AppImages().currentLocationIcon,
                                    width: 18,
                                    height: 18,
                                    color: orange,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Current Location",
                                    style: TextStyle(
                                      color: black,
                                      fontSize: 14,
                                      fontFamily: natoMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cardShadow,
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: Offset(0, -2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Address Pin Icon
                                  Image.asset(
                                    AppImages().addressPinIcon,
                                    width: 36,
                                    height: 36,
                                  ),
                                  const SizedBox(width: 10),
                                  // Address Details Block
                                  Expanded(
                                    child: Obx(
                                      () => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            controller.addressTitle.value,
                                            style: const TextStyle(
                                              color: black,
                                              fontSize: 16,
                                              fontFamily: natoBold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            controller.addressSubtitle.value,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: charcoalGray,
                                              fontSize: 13,
                                              fontFamily: natoRegular,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              // Confirm & Proceed Action Button
                              CustomButton(
                                width: MediaQuery.of(context).size.width,
                                label: "Confirm & Proceed",
                                onTap: () => controller
                                    .showAddAddressBottomSheet(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

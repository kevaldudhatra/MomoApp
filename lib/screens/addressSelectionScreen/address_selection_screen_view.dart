import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/screens/addressSelectionScreen/address_selection_screen_controller.dart';

class AddressSelectionScreen extends GetView<AddressSelectionScreenController> {
  const AddressSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: background,
          body: Column(
            children: [
              // Header / App Bar
              Container(
                width: double.infinity,
                color: white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.offAndToNamed(Routes.homeScreen);
                      },
                      child: Image.asset(
                        AppImages().backArrowIcon,
                        width: 20,
                        height: 20,
                        color: black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Select Location",
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

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Actions Card (Current Location & Add New Address)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: cardShadow,
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              // Current Location Row
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => controller.useCurrentLocation(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          AppImages().currentLocationIcon,
                                          width: 22,
                                          height: 22,
                                          color: orange,
                                        ),
                                        const SizedBox(width: 16),
                                        const Text(
                                          "Use my current location",
                                          style: TextStyle(
                                            color: orange,
                                            fontSize: 15,
                                            fontFamily: natoMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: borderGray,
                              ),
                              // Add New Address Row
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => controller.addNewAddress(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          AppImages().addIcon,
                                          width: 20,
                                          height: 20,
                                          color: orange,
                                        ),
                                        const SizedBox(width: 16),
                                        const Text(
                                          "Add new address",
                                          style: TextStyle(
                                            color: orange,
                                            fontSize: 15,
                                            fontFamily: natoMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // List of Saved Address Cards
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            "Saved Address",
                            style: const TextStyle(
                              color: charcoalGray,
                              fontSize: 14,
                              fontFamily: natoMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Column(
                            children: controller.savedAddresses.map((address) {
                              return _buildAddressCard(address);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Saved Address Card Item
  Widget _buildAddressCard(SavedAddress address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: cardShadow,
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.selectAddress(address),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Classified Icon
                Image.asset(
                  address.icon,
                  width: 22,
                  height: 22,
                  color: charcoalGray,
                ),
                const SizedBox(width: 16),
                // Text details block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.type,
                        style: const TextStyle(
                          color: black,
                          fontSize: 16,
                          fontFamily: natoBold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        address.address,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

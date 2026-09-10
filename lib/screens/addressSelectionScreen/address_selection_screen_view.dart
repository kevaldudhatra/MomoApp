import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/screens/addressSelectionScreen/address_selection_screen_controller.dart';
import 'package:momos/widgets/custom_text_field.dart';
import 'package:momos/widgets/loading_view.dart';

class AddressSelectionScreen extends GetView<AddressSelectionScreenController> {
  const AddressSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: background,
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
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
                Obx(
                  () => controller.mainLoading.value
                      ? SizedBox(
                          height: Get.height * 0.70,
                          width: double.infinity,
                          child: const Center(child: LoadingDialog()),
                        )
                      : Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
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
                                      textEditingController:
                                          controller.searchController,
                                      keyboardType: TextInputType.webSearch,
                                      textInputAction: TextInputAction.done,
                                      onChanged: controller.onSearchChanged,
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 5,
                                          left: 15,
                                        ),
                                        child: Image.asset(
                                          AppImages().searchIcon,
                                          height: 20,
                                          width: 20,
                                        ),
                                      ),
                                      suffixIcon: Obx(() {
                                        if (controller
                                            .isSearchingPlaces
                                            .value) {
                                          return Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(orange),
                                              ),
                                            ),
                                          );
                                        }
                                        if (controller
                                            .searchController
                                            .text
                                            .isNotEmpty) {
                                          return GestureDetector(
                                            onTap: controller.clearSearch,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 5,
                                                right: 15,
                                              ),
                                              child: const Icon(
                                                Icons.clear,
                                                color: charcoalGray,
                                                size: 20,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      }),
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  !controller.showSuggestions.value ||
                                          controller.placePredictions.isEmpty
                                      ? const SizedBox.shrink()
                                      : Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 15,
                                          ),
                                          constraints: const BoxConstraints(
                                            maxHeight: 240,
                                          ),
                                          decoration: BoxDecoration(
                                            color: white,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: cardShadow,
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: ListView.separated(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              itemCount: controller
                                                  .placePredictions
                                                  .length,
                                              separatorBuilder:
                                                  (context, index) =>
                                                      const Divider(
                                                        height: 1,
                                                        thickness: 1,
                                                        color: borderGray,
                                                      ),
                                              itemBuilder: (context, index) {
                                                final prediction = controller
                                                    .placePredictions[index];
                                                return ListTile(
                                                  dense: true,
                                                  leading: const Icon(
                                                    Icons.location_on_outlined,
                                                    color: orange,
                                                    size: 22,
                                                  ),
                                                  title: Text(
                                                    prediction.mainText,
                                                    style: const TextStyle(
                                                      fontFamily: natoMedium,
                                                      fontSize: 14,
                                                      color: black,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  subtitle:
                                                      prediction
                                                          .secondaryText
                                                          .isNotEmpty
                                                      ? Text(
                                                          prediction
                                                              .secondaryText,
                                                          style: const TextStyle(
                                                            fontFamily:
                                                                natoRegular,
                                                            fontSize: 12,
                                                            color: charcoalGray,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      : null,
                                                  onTap: () {
                                                    FocusScope.of(
                                                      context,
                                                    ).unfocus();
                                                    controller.selectPlace(
                                                      prediction,
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),

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
                                            onTap: () =>
                                                controller.useCurrentLocation(),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                16.0,
                                              ),
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    AppImages()
                                                        .currentLocationIcon,
                                                    width: 22,
                                                    height: 22,
                                                    color: orange,
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: const Text(
                                                      "Use my current location",
                                                      style: TextStyle(
                                                        color: orange,
                                                        fontSize: 15,
                                                        fontFamily: natoMedium,
                                                      ),
                                                    ),
                                                  ),
                                                  controller
                                                          .currentLocationLoading
                                                          .value
                                                      ? SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child:
                                                              CircularProgressIndicator(
                                                                color: orange,
                                                                strokeWidth:
                                                                    2.5,
                                                              ),
                                                        )
                                                      : Container(),
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
                                            onTap: () =>
                                                controller.addNewAddress(),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                16.0,
                                              ),
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
                                  const SizedBox(height: 15),

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
                                  controller.savedAddresses.isNotEmpty
                                      ? Column(
                                          children: controller.savedAddresses
                                              .map((address) {
                                                return _buildAddressCard(
                                                  address,
                                                );
                                              })
                                              .toList(),
                                        )
                                      : SizedBox(
                                          height: Get.height * 0.35,
                                          width: double.infinity,
                                          child: Center(
                                            child: Text(
                                              "Oops!\nNo saved address found.",
                                              style: TextStyle(
                                                color: charcoalGray,
                                                fontSize: 16,
                                                fontFamily: natoMedium,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Saved Address Card Item
  Widget _buildAddressCard(SavedAddressWithLatLng address) {
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

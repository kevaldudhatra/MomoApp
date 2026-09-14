import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_text_field.dart';
import 'package:momos/screens/cartManagement/cart_button.dart';
import 'package:momos/widgets/loading_view.dart';

class CarouselSlider extends StatefulWidget {
  const CarouselSlider({super.key, required this.outletBanners});

  final List<dynamic> outletBanners;

  @override
  State<CarouselSlider> createState() => _CarouselSliderState();
}

class _CarouselSliderState extends State<CarouselSlider> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 155,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.outletBanners.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.outletBanners[index]["image"],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.outletBanners.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isActive ? orange : lightGray,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class DeliveryScreen extends GetView<DeliveryScreenController> {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      floatingActionButton: const GlobalCartButton(horizontalMargin: 16),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Obx(() {
        return controller.isLoading.value
            ? const Center(child: LoadingDialog())
            : GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              orangeGradientStart,
                              orangeGradientEnd,
                              orangeGradientStart,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: black.withValues(alpha: 0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    final result = await Get.toNamed(
                                      Routes.addressSelectionScreen,
                                    );
                                    if (result != null) {
                                      controller.selectedAddress.value =
                                          result!["selectedAddress"];
                                      controller.addressType.value =
                                          result["addressType"];
                                      await controller.getOutletDetails(
                                        LatLng(
                                          result["latitude"],
                                          result["longitude"],
                                        ),
                                      );
                                    }
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            AppImages().locationIcon,
                                            width: 20,
                                            height: 20,
                                            color: white,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            controller.addressType.value,
                                            style: const TextStyle(
                                              fontFamily: natoSemiBold,
                                              fontSize: 18,
                                              color: white,
                                            ),
                                          ),
                                          Image.asset(
                                            AppImages().dropDownArrowIcon,
                                            width: 22,
                                            height: 22,
                                            color: white,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      SizedBox(
                                        width: Get.width - 70,
                                        child: Text(
                                          " ${controller.selectedAddress.value}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: natoRegular,
                                            fontSize: 12,
                                            color: white.withValues(
                                              alpha: 0.85,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.toNamed(Routes.offersScreen);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      AppImages().discountIcon,
                                      width: 18,
                                      height: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            CustomTextField(
                              hintText: "Search for dishes",
                              textEditingController:
                                  controller.searchController,
                              keyboardType: TextInputType.webSearch,
                              textInputAction: TextInputAction.done,
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
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          CarouselSlider(
                            outletBanners: controller.outletBanners,
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
                              "List of category",
                              style: TextStyle(
                                fontFamily: natoSemiBold,
                                fontSize: 18,
                                color: black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.outletCategories.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 5,
                                    crossAxisSpacing: 5,
                                    childAspectRatio: 0.90,
                                  ),
                              itemBuilder: (context, index) {
                                final item = controller.outletCategories[index];
                                return InkWell(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    Future.delayed(
                                      Duration(milliseconds: 500),
                                      () {
                                        Get.toNamed(Routes.outletScreen);
                                      },
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 75,
                                        height: 75,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: cardShadow,
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: ClipOval(
                                              child:
                                                  item["categoryImage"] == null
                                                  ? Image.asset(
                                                      AppImages().momoImg,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.network(
                                                      item["categoryImage"],
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item["name"],
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: natoMedium,
                                          fontSize: 11,
                                          color: charcoalGray,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Top Picks",
                              style: TextStyle(
                                fontFamily: natoSemiBold,
                                fontSize: 18,
                                color: black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(left: 16, right: 4),
                            child: Row(
                              children: controller.outletTopPicks.map((item) {
                                return Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.70,
                                  margin: const EdgeInsets.only(
                                    right: 12,
                                    bottom: 12,
                                    top: 4,
                                    left: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: cardShadow,
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(12),
                                                ),
                                            child: item["itemImage"] == null
                                                ? Image.asset(
                                                    AppImages().momoImg,
                                                    height: 110,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    item["itemImage"],
                                                    height: 110,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Image.asset(
                                              AppImages().vegIcon,
                                              width: 18,
                                              height: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item["name"],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: natoSemiBold,
                                                fontSize: 13,
                                                color: black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item["description"],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: natoRegular,
                                                fontSize: 10,
                                                color: charcoalGray.withValues(
                                                  alpha: 0.8,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "₹${item["defaultPrice"]["sellingPrice"]}",
                                                  style: const TextStyle(
                                                    fontFamily: natoBold,
                                                    fontSize: 14,
                                                    color: black,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {},
                                                  child: Container(
                                                    height: 26,
                                                    width: 55,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: white,
                                                      border: Border.all(
                                                        color: orange,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      "Add",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            natoSemiBold,
                                                        fontSize: 11,
                                                        color: orange,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }
}

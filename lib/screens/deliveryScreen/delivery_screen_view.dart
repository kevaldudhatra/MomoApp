import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/cartManagement/cart_controller.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_text_field.dart';
import 'package:momos/screens/cartManagement/cart_button.dart';
import 'package:momos/widgets/loading_view.dart';
import 'package:readmore_flutter/readmore_flutter.dart';
import 'package:shimmer/shimmer.dart';

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
                    widget.outletBanners[index]["image"] ?? "",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 155,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        AppImages().momoImg,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
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
                      // Address and Search container
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
                              keyboardType: TextInputType.text,
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
                              suffixIcon: !controller.isSearchEmpty.value
                                  ? GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        controller.clearSearch();
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.only(right: 12),
                                        child: Icon(
                                          Icons.clear,
                                          size: 20,
                                          color: textSecondary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      controller.isSearchEmpty.value
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Carousel Slider
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: CarouselSlider(
                                    outletBanners: controller.outletBanners,
                                  ),
                                ),

                                // Food Categories
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        controller.outletCategories.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 5,
                                          crossAxisSpacing: 5,
                                          childAspectRatio: 0.90,
                                        ),
                                    itemBuilder: (context, index) {
                                      final item =
                                          controller.outletCategories[index];
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
                                                  padding: const EdgeInsets.all(
                                                    2.0,
                                                  ),
                                                  child: ClipOval(
                                                    child: Image.network(
                                                      item["categoryImage"] ??
                                                          "",
                                                      fit: BoxFit.cover,
                                                      loadingBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            loadingProgress,
                                                          ) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return Shimmer.fromColors(
                                                              baseColor: Colors
                                                                  .grey
                                                                  .shade300,
                                                              highlightColor:
                                                                  Colors
                                                                      .grey
                                                                      .shade100,
                                                              child: Container(
                                                                height: 75,
                                                                width: double
                                                                    .infinity,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            );
                                                          },
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Image.asset(
                                                              AppImages()
                                                                  .momoImg,
                                                              fit: BoxFit.cover,
                                                            );
                                                          },
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

                                // Top Picks
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
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 4,
                                  ),
                                  child: Row(
                                    children: controller.outletTopPicks.map((
                                      item,
                                    ) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.70,
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                          bottom: 12,
                                          top: 4,
                                          left: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                                        top: Radius.circular(
                                                          12,
                                                        ),
                                                      ),
                                                  child: Image.network(
                                                    item["itemImage"] ?? "",
                                                    height: 110,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder:
                                                        (
                                                          context,
                                                          child,
                                                          loadingProgress,
                                                        ) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          }
                                                          return Shimmer.fromColors(
                                                            baseColor: Colors
                                                                .grey
                                                                .shade300,
                                                            highlightColor:
                                                                Colors
                                                                    .grey
                                                                    .shade100,
                                                            child: Container(
                                                              height: 110,
                                                              width: double
                                                                  .infinity,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          );
                                                        },
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Image.asset(
                                                            AppImages().momoImg,
                                                            height: 110,
                                                            width:
                                                                double.infinity,
                                                            fit: BoxFit.cover,
                                                          );
                                                        },
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 8,
                                                  left: 8,
                                                  child: Image.asset(
                                                    item["itemType"] == 1
                                                        ? AppImages().vegIcon
                                                        : AppImages()
                                                              .nonVegIcon,
                                                    width: 18,
                                                    height: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item["name"],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontFamily: natoRegular,
                                                      fontSize: 10,
                                                      color: charcoalGray
                                                          .withValues(
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
                                                        "₹${item["defaultPrice"]["comparePrice"] == 0 ? item["defaultPrice"]["sellingPrice"] : item["defaultPrice"]["comparePrice"]}",
                                                        style: const TextStyle(
                                                          fontFamily: natoBold,
                                                          fontSize: 14,
                                                          color: black,
                                                        ),
                                                      ),
                                                      item["cartCount"] > 0
                                                          ? Container(
                                                              width: 70,
                                                              height: 26,
                                                              decoration: BoxDecoration(
                                                                color: white,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                                border:
                                                                    Border.all(
                                                                      color:
                                                                          orange,
                                                                      width: 1,
                                                                    ),
                                                                boxShadow: const [
                                                                  BoxShadow(
                                                                    color:
                                                                        cardShadow,
                                                                    blurRadius:
                                                                        4,
                                                                    offset:
                                                                        Offset(
                                                                          0,
                                                                          2,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () async {
                                                                      await controller.decrimentQuantity(
                                                                        itemData:
                                                                            item,
                                                                      );
                                                                    },
                                                                    child: const Icon(
                                                                      Icons
                                                                          .remove,
                                                                      color:
                                                                          charcoalGray,
                                                                      size: 16,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    item["cartCount"]
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                      color:
                                                                          charcoalGray,
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          natoBold,
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () async {
                                                                      await controller.incrementQuantity(
                                                                        itemData:
                                                                            item,
                                                                      );
                                                                    },
                                                                    child: const Icon(
                                                                      Icons.add,
                                                                      color:
                                                                          charcoalGray,
                                                                      size: 16,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : GestureDetector(
                                                              onTap: () async {
                                                                await controller
                                                                    .addItemToCart(
                                                                      itemQuantity:
                                                                          1,
                                                                      itemData:
                                                                          item,
                                                                      modifierOption:
                                                                          [],
                                                                    );
                                                              },
                                                              child: Container(
                                                                height: 26,
                                                                width: 55,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                  color: white,
                                                                  border:
                                                                      Border.all(
                                                                        color:
                                                                            orange,
                                                                        width:
                                                                            1,
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
                                                                    fontSize:
                                                                        11,
                                                                    color:
                                                                        orange,
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
                                SizedBox(
                                  height:
                                      Get.find<CartController>()
                                          .cartItems
                                          .isEmpty
                                      ? 15
                                      : 80,
                                ),
                              ],
                            )
                          : controller.searchLoading.value
                          ? Container(
                              height: MediaQuery.of(context).size.height * 0.40,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                color: orange,
                              ),
                            )
                          : controller.foodItems.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.foodItems.length,
                              padding: const EdgeInsets.only(bottom: 90),
                              itemBuilder: (context, index) {
                                final item = controller.foodItems[index];
                                return _buildFoodItemCard(context, item);
                              },
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height * 0.60,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.center,
                              child: Text(
                                "No dishes found.\nTry searching for something else!",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: textSecondary,
                                  fontSize: 15,
                                  fontFamily: natoBold,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              );
      }),
    );
  }

  // Single Food Item Card Widget
  Widget _buildFoodItemCard(BuildContext context, dynamic item) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        controller
            .getFoodItemDetails(outletId: item["outlateId"], itemId: item["id"])
            .then(
              (value) => {
                FoodItemDetailsBottomSheet.show(
                  Get.context!,
                  foodItem: controller.foodItemsDetails,
                ),
              },
            );
      },
      child: Container(
        color: white,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Details (Left)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Veg / Non-Veg Indicator
                      Image.asset(
                        item["itemType"] == 1
                            ? AppImages().vegIcon
                            : AppImages().nonVegIcon,
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(height: 6),

                      // Item Name
                      Text(
                        item["name"],
                        style: const TextStyle(
                          color: black,
                          fontSize: 16,
                          fontFamily: natoBold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Price & Strikethrough Discount Price
                      Row(
                        children: [
                          item["defaultPrice"]["comparePrice"] == 0
                              ? Text(
                                  "₹${item["defaultPrice"]["sellingPrice"]}",
                                  style: const TextStyle(
                                    color: black,
                                    fontSize: 15,
                                    fontFamily: natoBold,
                                  ),
                                )
                              : Text(
                                  "₹${item["defaultPrice"]["comparePrice"]}",
                                  style: const TextStyle(
                                    color: black,
                                    fontSize: 15,
                                    fontFamily: natoBold,
                                  ),
                                ),
                          if (item["defaultPrice"]["comparePrice"] != 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              "₹${item["defaultPrice"]["sellingPrice"]}",
                              style: const TextStyle(
                                color: charcoalGray,
                                fontSize: 15,
                                fontFamily: natoRegular,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Item Description
                      Theme(
                        data: Theme.of(context).copyWith(
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              splashFactory: NoSplash.splashFactory,
                              overlayColor: Colors.transparent,
                            ),
                          ),
                        ),
                        child: ReadMore(
                          item["description"] ?? "",
                          style: const TextStyle(
                            color: charcoalGray,
                            fontSize: 13,
                            fontFamily: natoRegular,
                          ),
                          minLines: 2,
                          readMoreText: 'Read more',
                          readLessText: 'Read less',
                          readMoreStyle: const TextStyle(
                            color: charcoalGray,
                            fontSize: 13,
                            fontFamily: natoMedium,
                          ),
                          readMoreIconVisible: false,
                          alignCenter: false,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Item Image & Floating Add Button (Right)
                Column(
                  children: [
                    SizedBox(
                      height: 128,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Food Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item["itemImage"] ?? "",
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(
                                        width: 110,
                                        height: 110,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    AppImages().momoImg,
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                            ),
                          ),

                          // Add Button (Overlapping)
                          item["cartCount"] > 0
                              ? Positioned(
                                  bottom: 0,
                                  child: Container(
                                    width: 70,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: orange,
                                        width: 1,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: cardShadow,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            await controller.decrimentQuantity(
                                              itemData: item,
                                            );
                                          },
                                          child: const Icon(
                                            Icons.remove,
                                            color: charcoalGray,
                                            size: 16,
                                          ),
                                        ),
                                        Text(
                                          item["cartCount"].toString(),
                                          style: const TextStyle(
                                            color: charcoalGray,
                                            fontSize: 14,
                                            fontFamily: natoBold,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            await controller.incrementQuantity(
                                              itemData: item,
                                            );
                                          },
                                          child: const Icon(
                                            Icons.add,
                                            color: charcoalGray,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Positioned(
                                  bottom: 0,
                                  child: InkWell(
                                    onTap: () async {
                                      if (item["hasCustomisation"]) {
                                        await controller
                                            .getFoodItemDetails(
                                              outletId: item["outlateId"],
                                              itemId: item["id"],
                                            )
                                            .then(
                                              (value) => {
                                                FoodItemDetailsBottomSheet.show(
                                                  Get.context!,
                                                  foodItem: controller
                                                      .foodItemsDetails,
                                                ),
                                              },
                                            );
                                      } else {
                                        await controller.addItemToCart(
                                          itemQuantity: 1,
                                          itemData: item,
                                          modifierOption: [],
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 70,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: orange,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: cardShadow,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Add",
                                        style: TextStyle(
                                          color: white,
                                          fontSize: 14,
                                          fontFamily: natoBold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (item["hasCustomisation"])
                      const Text(
                        "Customise",
                        style: TextStyle(
                          color: charcoalGray,
                          fontSize: 11,
                          fontFamily: natoRegular,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: borderGray),
          ],
        ),
      ),
    );
  }
}

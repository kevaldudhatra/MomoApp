import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/outletScreen/outlet_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/screens/cartManagement/cart_button.dart';
import 'package:momos/widgets/loading_view.dart';
import 'package:readmore_flutter/readmore_flutter.dart';
import 'package:shimmer/shimmer.dart';

class OutletScreen extends GetView<OutletScreenController> {
  const OutletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        bottomNavigationBar: const SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GlobalCartButton(),
          ),
        ),
        floatingActionButton: Obx(
          () => GestureDetector(
            onTap: () {
              if (controller.isMenuOpen.value) {
                Navigator.of(context).pop();
              } else {
                controller.showMenuPopup(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: cardShadow,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  controller.isMenuOpen.value
                      ? Image.asset(
                          AppImages().closeIcon,
                          width: 18,
                          height: 18,
                          color: white,
                        )
                      : Image.asset(
                          AppImages().menuIcon,
                          width: 18,
                          height: 18,
                          color: white,
                        ),
                  const SizedBox(width: 6),
                  Text(
                    controller.isMenuOpen.value ? "Close" : "Menu",
                    style: TextStyle(
                      color: white,
                      fontSize: 14,
                      fontFamily: natoMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            controller: controller.scrollController,
            physics: const BouncingScrollPhysics(),
            child: Obx(
              () => controller.isLoading.value
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.85,
                      child: const Center(child: LoadingDialog()),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Outlet info view
                        Stack(
                          alignment: AlignmentDirectional.topCenter,
                          children: [
                            Container(
                              height: 150,
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
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: 20,
                                left: 16,
                                right: 16,
                                bottom: 20,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => Get.back(),
                                    child: Image.asset(
                                      AppImages().backArrowIcon,
                                      width: 18,
                                      height: 18,
                                      color: white,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: Image.asset(
                                          AppImages().shareIcon,
                                          width: 22,
                                          height: 22,
                                          color: white,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () {
                                          Get.toNamed(
                                            Routes.outletDetailScreen,
                                          );
                                        },
                                        child: Image.asset(
                                          AppImages().infoIcon,
                                          width: 22,
                                          height: 22,
                                          color: white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 20,
                                top: 60,
                              ),
                              decoration: BoxDecoration(
                                color: white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: cardShadow,
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Outlet Thumbnail Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          controller.outletInfo['brandLogo'] ??
                                              "",
                                          width: 85,
                                          height: 85,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade100,
                                                  child: Container(
                                                    width: 85,
                                                    height: 85,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                                    AppImages().momoImg,
                                                    width: 85,
                                                    height: 85,
                                                    fit: BoxFit.cover,
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      // Title, Cuisines & Open Badge
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller.outletInfo['name'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: black,
                                                fontSize: 18,
                                                fontFamily: natoBold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              controller
                                                  .outletInfo['cuisineType'],
                                              style: const TextStyle(
                                                color: charcoalGray,
                                                fontSize: 13,
                                                fontFamily: natoRegular,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Open Status Badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    controller
                                                        .outletInfo['isOpen']
                                                    ? greenBadge
                                                    : red,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                controller.outletInfo['isOpen']
                                                    ? "Open"
                                                    : "Closed",
                                                style: TextStyle(
                                                  color: white,
                                                  fontSize: 11,
                                                  fontFamily: natoMedium,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: borderGray,
                                  ),
                                  const SizedBox(height: 12),
                                  // Rating & Delivery Time Row
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Star Rating & Reviews
                                      Image.asset(
                                        AppImages().starIcon,
                                        width: 18,
                                        height: 18,
                                        color: greenBadge,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        controller.outletInfo['averageRate']
                                            .toString(),
                                        style: const TextStyle(
                                          color: black,
                                          fontSize: 14,
                                          fontFamily: natoBold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "(${controller.outletInfo['totalRatings']} Reviews)",
                                        style: const TextStyle(
                                          color: charcoalGray,
                                          fontSize: 13,
                                          fontFamily: natoRegular,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Horizontal Filter Chips Row
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: controller.foodTypes.length,
                            separatorBuilder: (context, index) {
                              return const SizedBox(width: 10);
                            },
                            itemBuilder: (context, index) {
                              final item = controller.foodTypes[index];
                              return _buildFilterChip(item);
                            },
                          ),
                        ),

                        // Menu Categories List
                        controller.filterLoading.value
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.40,
                                child: const Center(child: LoadingDialog()),
                              )
                            : controller.foodItems.isEmpty
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.45,
                                child: Center(
                                  child: Text(
                                    "Oops!\nNo Items Found",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: natoBold,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: controller.foodItems
                                    .map(
                                      (category) => _buildCategorySection(
                                        context,
                                        category,
                                      ),
                                    )
                                    .toList(),
                              ),

                        const SizedBox(height: 80),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // Single Filter Chip Widget
  Widget _buildFilterChip(dynamic foodType) {
    return GestureDetector(
      onTap: () {
        if (!foodType['isSelected']) {
          controller.toggleFilter(foodType);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: foodType["isSelected"] ? orange.withValues(alpha: 0.1) : white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: foodType["isSelected"] ? orange : chipBorder,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          foodType["name"],
          textAlign: TextAlign.center,
          style: TextStyle(
            color: foodType["isSelected"] ? orange : black,
            fontSize: 13.5,
            fontFamily: foodType["isSelected"] ? natoSemiBold : natoMedium,
          ),
        ),
      ),
    );
  }

  // Category Section Widget
  Widget _buildCategorySection(BuildContext context, dynamic category) {
    final catId = category["category"]?["id"];
    return Container(
      key: catId != null ? controller.getCategoryKey(catId) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header Bar
          GestureDetector(
            onTap: () => controller.toggleCategory(category),
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category["category"]["name"],
                    style: const TextStyle(
                      color: black,
                      fontSize: 18,
                      fontFamily: natoBold,
                    ),
                  ),
                  AnimatedRotation(
                    turns: category["isExpanded"] ? 0 : 0.5,
                    duration: const Duration(milliseconds: 250),
                    child: Image.asset(
                      AppImages().dropDownArrowIcon,
                      width: 25,
                      height: 25,
                      color: black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1, color: borderGray),

          // Food Item Cards inside Category
          if (category["isExpanded"])
            ...category["items"].map(
              (item) => _buildFoodItemCard(
                context,
                item,
                category["category"]["name"],
              ),
            ),
        ],
      ),
    );
  }

  // Single Food Item Card Widget
  Widget _buildFoodItemCard(
    BuildContext context,
    dynamic item,
    String categoryName,
  ) {
    final itemId = item["id"];
    return GestureDetector(
      key: itemId != null ? controller.getItemKey(itemId) : null,
      onTap: () {
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

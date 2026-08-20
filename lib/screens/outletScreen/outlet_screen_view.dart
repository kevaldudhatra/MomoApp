import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/outletScreen/outlet_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/screens/cartManagement/cart_controller.dart';
import 'package:momos/screens/cartManagement/cart_button.dart';

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
              controller.isMenuOpen.value = true;
              controller.showMenuPopup(context);
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
            physics: const BouncingScrollPhysics(),
            child: Column(
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
                                  Get.toNamed(Routes.outletDetailScreen);
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Outlet Thumbnail Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  AppImages().topPicksImg,
                                  width: 85,
                                  height: 85,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Title, Cuisines & Open Badge
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.outletName,
                                      style: const TextStyle(
                                        color: black,
                                        fontSize: 18,
                                        fontFamily: natoBold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.cuisines,
                                      style: const TextStyle(
                                        color: charcoalGray,
                                        fontSize: 13,
                                        fontFamily: natoRegular,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Open Status Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: greenBadge,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        "Open",
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
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                controller.rating,
                                style: const TextStyle(
                                  color: black,
                                  fontSize: 14,
                                  fontFamily: natoBold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                controller.reviewsCount,
                                style: const TextStyle(
                                  color: charcoalGray,
                                  fontSize: 13,
                                  fontFamily: natoRegular,
                                ),
                              ),
                              const Spacer(),
                              // Delivery Time
                              Image.asset(
                                AppImages().timerIcon,
                                width: 18,
                                height: 18,
                                color: charcoalGray,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                controller.deliveryTime,
                                style: const TextStyle(
                                  color: black,
                                  fontSize: 13,
                                  fontFamily: natoMedium,
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(
                    () => Row(
                      children: [
                        _buildFilterChip(
                          label: "Veg",
                          icon: AppImages().vegIcon,
                          isSelected: controller.isVegSelected.value,
                          onTap: () => controller.toggleFilter('veg'),
                        ),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          label: "Non veg",
                          icon: AppImages().nonVegIcon,
                          isSelected: controller.isNonVegSelected.value,
                          onTap: () => controller.toggleFilter('nonveg'),
                        ),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          label: "Bestseller",
                          icon: AppImages().bestsellerIcon,
                          isSelected: controller.isBestsellerSelected.value,
                          onTap: () => controller.toggleFilter('bestseller'),
                        ),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          label: "New",
                          isSelected: controller.isNewSelected.value,
                          onTap: () => controller.toggleFilter('new'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Menu Categories List
                Obx(
                  () => Column(
                    children: controller.categories
                        .map((category) => _buildCategorySection(category))
                        .toList(),
                  ),
                ),

                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Single Filter Chip Widget
  Widget _buildFilterChip({
    required String label,
    String? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? orange.withValues(alpha: 0.1) : white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? orange : chipBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Image.asset(icon, width: 16, height: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? orange : black,
                fontSize: 13,
                fontFamily: isSelected ? natoSemiBold : natoMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Category Section Widget
  Widget _buildCategorySection(MenuCategory category) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header Bar
          GestureDetector(
            onTap: () => controller.toggleCategory(category),
            child: Container(
              margin: EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      color: black,
                      fontSize: 18,
                      fontFamily: natoBold,
                    ),
                  ),
                  AnimatedRotation(
                    turns: category.isExpanded.value ? 0 : 0.5,
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
          if (category.isExpanded.value)
            ...category.items.map(
              (item) => _buildFoodItemCard(item, category.title),
            ),
        ],
      ),
    );
  }

  // Single Food Item Card Widget
  Widget _buildFoodItemCard(FoodItem item, String categoryName) {
    return GestureDetector(
      onTap: () {
        FoodItemDetailsBottomSheet.show(Get.context!, foodItem: item);
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
                        item.isVeg
                            ? AppImages().vegIcon
                            : AppImages().nonVegIcon,
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(height: 6),

                      // Item Name
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: black,
                          fontSize: 16,
                          fontFamily: natoBold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Item Description
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: charcoalGray,
                          fontSize: 13,
                          fontFamily: natoRegular,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price & Strikethrough Discount Price
                      Row(
                        children: [
                          Text(
                            "₹${item.price.toInt()}",
                            style: const TextStyle(
                              color: black,
                              fontSize: 15,
                              fontFamily: natoBold,
                            ),
                          ),
                          if (item.originalPrice != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              "₹${item.originalPrice!.toInt()}",
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
                      const SizedBox(height: 8),

                      // Customization text
                      Text(
                        item.customization,
                        style: const TextStyle(
                          color: charcoalGray,
                          fontSize: 12,
                          fontFamily: natoRegular,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Read More Link
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Read More",
                          style: TextStyle(
                            color: charcoalGray,
                            fontSize: 12,
                            fontFamily: natoMedium,
                          ),
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
                            child: Image.asset(
                              item.image,
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // Add Button (Overlapping)
                          item.quantity > 0
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
                                          onTap: () {
                                            Get.find<OutletScreenController>()
                                                .decrimentQuantity(
                                                  categoryName,
                                                  item.id,
                                                );
                                          },
                                          child: const Icon(
                                            Icons.remove,
                                            color: charcoalGray,
                                            size: 16,
                                          ),
                                        ),
                                        Text(
                                          item.quantity.toString(),
                                          style: const TextStyle(
                                            color: charcoalGray,
                                            fontSize: 14,
                                            fontFamily: natoBold,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Get.find<OutletScreenController>()
                                                .incrementQuantity(
                                                  categoryName,
                                                  item.id,
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
                                    onTap: () {
                                      Get.find<CartController>().addItemToCart(
                                        id: item.id,
                                        categoryName: categoryName,
                                        name: item.name,
                                        description: item.description,
                                        price: item.price,
                                        image: item.image,
                                        isVeg: item.isVeg,
                                      );
                                      Get.find<OutletScreenController>()
                                          .incrementQuantity(
                                            categoryName,
                                            item.id,
                                          );
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
                    if (item.hasCustomise)
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

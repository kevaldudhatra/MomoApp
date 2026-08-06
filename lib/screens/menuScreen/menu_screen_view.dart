import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/menuScreen/menu_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_text_field.dart';

class MenuScreen extends GetView<MenuScreenController> {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        body: Column(
          children: [
            // Top Bar Header
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
                    "Menu",
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

            // Search Bar area
            Container(
              color: white,
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                hintText: "Search items",
                onChanged: (value) => controller.searchQuery.value = value,
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

            // Filters Checkbox Row
            Container(
              color: white,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Row(
                children: [
                  _buildFilterCheckbox(
                    label: "Veg",
                    isChecked: controller.isVegSelected,
                    onTap: () => controller.isVegSelected.toggle(),
                  ),
                  const SizedBox(width: 24),
                  _buildFilterCheckbox(
                    label: "Non veg",
                    isChecked: controller.isNonVegSelected,
                    onTap: () => controller.isNonVegSelected.toggle(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: borderGray),

            // Categories list
            Expanded(
              child: Obx(() {
                final items = controller.filteredItems;

                // Group by categories
                final recommendations = items
                    .where((i) => i.category == "Recommendations")
                    .toList();
                final combos = items
                    .where((i) => i.category == "Combo foods")
                    .toList();

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      "No items found matching filters",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 15,
                        fontFamily: natoMedium,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recommendations Section
                      if (recommendations.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "Recommendations",
                            style: TextStyle(
                              color: black,
                              fontSize: 15,
                              fontFamily: natoBold,
                            ),
                          ),
                        ),
                        ...recommendations.map(
                          (item) => _buildMenuItemCard(item),
                        ),
                      ],

                      // Combo foods Section
                      if (combos.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Text(
                            "Combo foods",
                            style: TextStyle(
                              color: black,
                              fontSize: 15,
                              fontFamily: natoBold,
                            ),
                          ),
                        ),
                        ...combos.map((item) => _buildMenuItemCard(item)),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCheckbox({
    required String label,
    required RxBool isChecked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Obx(
            () => Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isChecked.value ? orange : white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isChecked.value ? orange : borderGray,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: isChecked.value
                  ? const Icon(Icons.check, size: 12, color: white)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: black,
              fontSize: 14,
              fontFamily: natoMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItemModel item) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left thumbnail image with overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  item.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Image.asset(
                  item.isVeg ? AppImages().vegIcon : AppImages().nonVegIcon,
                  width: 18,
                  height: 18,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Right item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: black,
                    fontSize: 15,
                    fontFamily: natoBold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${item.price.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: black,
                    fontSize: 14,
                    fontFamily: natoBold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: charcoalGray,
                    fontSize: 12.5,
                    fontFamily: natoRegular,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

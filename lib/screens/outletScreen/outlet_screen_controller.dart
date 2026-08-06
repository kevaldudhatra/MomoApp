import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/cartManagement/cart_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';

class FoodItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final bool isVeg;
  final bool isBestseller;
  final String customization;
  final String image;
  final bool hasCustomise;
  final int quantity;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.isVeg,
    this.isBestseller = false,
    required this.customization,
    required this.image,
    this.hasCustomise = false,
    this.quantity = 0,
  });

  FoodItem copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    bool? isVeg,
    bool? isBestseller,
    String? customization,
    String? image,
    bool? hasCustomise,
    int? quantity,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      isVeg: isVeg ?? this.isVeg,
      isBestseller: isBestseller ?? this.isBestseller,
      customization: customization ?? this.customization,
      image: image ?? this.image,
      hasCustomise: hasCustomise ?? this.hasCustomise,
      quantity: quantity ?? this.quantity,
    );
  }
}

class MenuCategory {
  final String title;
  final List<FoodItem> items;
  RxBool isExpanded;

  MenuCategory({
    required this.title,
    required this.items,
    bool isExpanded = true,
  }) : isExpanded = isExpanded.obs;
}

class MenuPopupCategoryItem {
  final String title;
  final int itemCount;
  final List<MenuPopupCategoryItem>? subCategories;
  final RxBool isExpanded;

  MenuPopupCategoryItem({
    required this.title,
    required this.itemCount,
    this.subCategories,
    bool isExpanded = false,
  }) : isExpanded = isExpanded.obs;
}

class MenuPopupWidget extends StatelessWidget {
  const MenuPopupWidget({
    super.key,
    required this.categories,
    this.onCategorySelected,
  });

  final List<MenuPopupCategoryItem> categories;
  final Function(MenuPopupCategoryItem category)? onCategorySelected;

  // Helper static method to display the popup using custom general dialog
  static Future<void> show(
    BuildContext context, {
    required List<MenuPopupCategoryItem> categories,
    Function(MenuPopupCategoryItem category)? onCategorySelected,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'MenuPopup',
      barrierColor: dialogBarrierColor,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return MenuPopupWidget(
          categories: categories,
          onCategorySelected: (category) {
            onCategorySelected?.call(category);
            Navigator.of(context).pop();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          ),
        );
      },
    );
  }

  // Builds a single category row (Parent & Subcategories)
  Widget _buildCategoryRow(MenuPopupCategoryItem category) {
    final hasSubCategories =
        category.subCategories != null && category.subCategories!.isNotEmpty;
    return Obx(() {
      final isExpanded = category.isExpanded.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parent Category Row
          GestureDetector(
            onTap: () {
              if (hasSubCategories) {
                category.isExpanded.value = !category.isExpanded.value;
              } else {
                onCategorySelected?.call(category);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  // Title + Dropdown Icon
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            category.title,
                            style: const TextStyle(
                              color: black,
                              fontSize: 16,
                              fontFamily: natoMedium,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasSubCategories) ...[
                          const SizedBox(width: 3),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Image.asset(
                              AppImages().dropDownArrowIcon,
                              width: 20,
                              height: 20,
                              color: black,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Item Count
                  Text(
                    "${category.itemCount}",
                    style: const TextStyle(
                      color: black,
                      fontSize: 16,
                      fontFamily: natoMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Subcategories List
          if (hasSubCategories && isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 2, bottom: 6),
              child: Column(
                children: category.subCategories!.map((subCat) {
                  return GestureDetector(
                    onTap: () => onCategorySelected?.call(subCat),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              subCat.title,
                              style: const TextStyle(
                                color: charcoalGray,
                                fontSize: 15,
                                fontFamily: natoRegular,
                                height: 1.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${subCat.itemCount}",
                            style: const TextStyle(
                              color: charcoalGray,
                              fontSize: 15,
                              fontFamily: natoRegular,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.72,
            maxWidth: screenWidth > 500 ? 400 : screenWidth * 0.88,
          ),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: cardShadow,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 24,
                right: 12,
                bottom: 20,
              ),
              child: RawScrollbar(
                thumbColor: lightGray,
                radius: const Radius.circular(6),
                thickness: 3,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: categories
                        .map((category) => _buildCategoryRow(category))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FoodItemDetailsBottomSheet extends StatefulWidget {
  final FoodItem foodItem;
  final VoidCallback? onClose;

  const FoodItemDetailsBottomSheet({
    super.key,
    required this.foodItem,
    this.onClose,
  });

  // Helper static method to display the bottom sheet cleanly
  static Future<void> show(
    BuildContext context, {
    required FoodItem foodItem,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: dialogBarrierColor,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return FoodItemDetailsBottomSheet(
          foodItem: foodItem,
          onClose: () {
            onClose?.call();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  State<FoodItemDetailsBottomSheet> createState() =>
      _FoodItemDetailsBottomSheetState();
}

class _FoodItemDetailsBottomSheetState
    extends State<FoodItemDetailsBottomSheet> {
  // Option lists tracking state
  int _selectedToppingIndex = 0;
  final Set<int> _selectedAddons = {0};

  final List<Map<String, dynamic>> _customOptions = [
    {"name": "Regular (serves 1, 17.7 cm)", "price": 350},
    {"name": "Regular (serves 1, 17.7 cm)", "price": 350},
    {"name": "Regular (serves 1, 17.7 cm)", "price": 350},
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.90),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pinned Floating Close Button above bottom sheet
          GestureDetector(
            onTap: widget.onClose ?? () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: const BoxDecoration(
                color: black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cardShadow,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  AppImages().closeIcon,
                  width: 18,
                  height: 18,
                  color: white,
                ),
              ),
            ),
          ),

          // Main Bottom Sheet Card Body
          Flexible(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Main Food Item Details Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: cardShadow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Food Image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.asset(
                                AppImages().topPicksImg,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Veg/Non-Veg Badge Icon
                                  Image.asset(
                                    widget.foodItem.isVeg
                                        ? AppImages().vegIcon
                                        : AppImages().nonVegIcon,
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(height: 8),

                                  // Food Item Title
                                  Text(
                                    widget.foodItem.name,
                                    style: const TextStyle(
                                      fontFamily: natoBold,
                                      fontSize: 18,
                                      color: black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // Description text
                                  Text(
                                    "${widget.foodItem.description} ${widget.foodItem.description}",
                                    style: const TextStyle(
                                      fontFamily: natoRegular,
                                      fontSize: 13.5,
                                      color: textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Food Item Price
                                  Text(
                                    "₹${widget.foodItem.price.toInt()}",
                                    style: const TextStyle(
                                      fontFamily: natoBold,
                                      fontSize: 16,
                                      color: black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2. Toppings Card (Radio selection)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: cardShadow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Toppings",
                                    style: TextStyle(
                                      fontFamily: natoBold,
                                      fontSize: 15.5,
                                      color: black,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Required • select any 1 option",
                                    style: TextStyle(
                                      fontFamily: natoRegular,
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: borderGray,
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _customOptions.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: borderGray,
                                  ),
                              itemBuilder: (context, index) {
                                final option = _customOptions[index];
                                final isSelected =
                                    _selectedToppingIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedToppingIndex = index;
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            option["name"],
                                            style: const TextStyle(
                                              fontFamily: natoRegular,
                                              fontSize: 14.5,
                                              color: black,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "₹${option["price"]}",
                                          style: const TextStyle(
                                            fontFamily: natoBold,
                                            fontSize: 14.5,
                                            color: black,
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Custom Radio Button Widget
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? orange
                                                  : lightGray,
                                              width: isSelected ? 6 : 1.5,
                                            ),
                                            color: white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. Add-ons Card (Checkbox selection)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: cardShadow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add ons",
                                    style: TextStyle(
                                      fontFamily: natoBold,
                                      fontSize: 15.5,
                                      color: black,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Optional",
                                    style: TextStyle(
                                      fontFamily: natoRegular,
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: borderGray,
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _customOptions.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: borderGray,
                                  ),
                              itemBuilder: (context, index) {
                                final option = _customOptions[index];
                                final isSelected = _selectedAddons.contains(
                                  index,
                                );

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedAddons.remove(index);
                                      } else {
                                        _selectedAddons.add(index);
                                      }
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            option["name"],
                                            style: const TextStyle(
                                              fontFamily: natoRegular,
                                              fontSize: 14.5,
                                              color: black,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "₹${option["price"]}",
                                          style: const TextStyle(
                                            fontFamily: natoBold,
                                            fontSize: 14.5,
                                            color: black,
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Custom Checkbox Widget
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            color: isSelected ? orange : white,
                                            border: Border.all(
                                              color: isSelected
                                                  ? orange
                                                  : lightGray,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: white,
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
        ],
      ),
    );
  }
}

class OutletScreenController extends GetxController {
  RxList<CartItem> get cartItems => Get.isRegistered<CartController>()
      ? Get.find<CartController>().cartItems
      : <CartItem>[].obs;
  final searchController = TextEditingController();
  final isVegSelected = false.obs;
  final isNonVegSelected = false.obs;
  final isBestsellerSelected = false.obs;
  final isNewSelected = false.obs;
  final isMenuOpen = false.obs;
  final outletName = "Momo I AM gol park";
  final cuisines = "Chinese • Seafood • Thai • Pan-Asian";
  final isOpen = true;
  final rating = "4.2";
  final reviewsCount = "(456 Reviews)";
  final deliveryTime = "34-39 mins";
  final categories = <MenuCategory>[].obs;
  final menuPopupCategories = <MenuPopupCategoryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMenuData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _loadMenuData() {
    categories.assignAll([
      MenuCategory(
        title: "Bestseller",
        items: [
          FoodItem(
            id: 1,
            name: "Smokey Chilli Paneer",
            description: "Indulge in our spicy chilli panner flavor",
            price: 350,
            quantity: 0,
            originalPrice: 450,
            isVeg: true,
            isBestseller: true,
            customization: "Choice of noodles(veg/chicken/shrimp/mix)",
            image: AppImages().menuItemOne,
            hasCustomise: true,
          ),
          FoodItem(
            id: 2,
            name: "Smokey Chilli Paneer",
            description: "Indulge in our spicy chilli panner flavor",
            price: 350,
            quantity: 0,
            isVeg: true,
            isBestseller: true,
            customization: "Choice of noodles(veg/chicken/shrimp/mix)",
            image: AppImages().menuItemOne,
            hasCustomise: false,
          ),
        ],
      ),
      MenuCategory(
        title: "Items @ 149",
        items: [
          FoodItem(
            id: 3,
            name: "Smokey Chilli Paneer",
            description: "Indulge in our spicy chilli panner flavor",
            price: 350,
            quantity: 0,
            originalPrice: 450,
            isVeg: true,
            customization: "Choice of noodles(veg/chicken/shrimp/mix)",
            image: AppImages().menuItemTwo,
            hasCustomise: true,
          ),
        ],
      ),
    ]);
    menuPopupCategories.assignAll([
      MenuPopupCategoryItem(title: "Bestseller", itemCount: 5),
      MenuPopupCategoryItem(title: "Items @149", itemCount: 12),
      MenuPopupCategoryItem(title: "Items @299", itemCount: 20),
      MenuPopupCategoryItem(title: "Classic veg bites", itemCount: 8),
      MenuPopupCategoryItem(
        title: "Soup",
        itemCount: 15,
        isExpanded: true,
        subCategories: [
          MenuPopupCategoryItem(title: "Veg soup", itemCount: 10),
          MenuPopupCategoryItem(title: "Non-veg soup", itemCount: 5),
        ],
      ),
      MenuPopupCategoryItem(
        title: "Starter",
        itemCount: 15,
        isExpanded: false,
        subCategories: [],
      ),
      MenuPopupCategoryItem(
        title: "Drinks & Desserts",
        itemCount: 15,
        isExpanded: false,
        subCategories: [],
      ),
      MenuPopupCategoryItem(title: "Items @149", itemCount: 5),
    ]);
  }

  void toggleFilter(String filterType) {
    switch (filterType) {
      case 'veg':
        isVegSelected.value = !isVegSelected.value;
        break;
      case 'nonveg':
        isNonVegSelected.value = !isNonVegSelected.value;
        break;
      case 'bestseller':
        isBestsellerSelected.value = !isBestsellerSelected.value;
        break;
      case 'new':
        isNewSelected.value = !isNewSelected.value;
        break;
    }
  }

  void toggleCategory(MenuCategory category) {
    category.isExpanded.value = !category.isExpanded.value;
  }

  void showMenuPopup(BuildContext context) {
    MenuPopupWidget.show(
      context,
      categories: menuPopupCategories,
      onCategorySelected: (selectedCategory) {
        isMenuOpen.value = false;
      },
    );
  }

  void incrementQuantity(String categoryTitle, int itemId) {
    int categoryIndex = categories.indexWhere(
      (element) => element.title == categoryTitle,
    );
    int itemIndex = categories[categoryIndex].items.indexWhere(
      (element) => element.id == itemId,
    );
    if (categoryIndex >= 0 && itemIndex >= 0) {
      categories[categoryIndex].items[itemIndex] = categories[categoryIndex]
          .items[itemIndex]
          .copyWith(
            quantity: categories[categoryIndex].items[itemIndex].quantity + 1,
          );
    }
    int index = cartItems.indexWhere(
      (element) =>
          element.categoryName == categoryTitle && element.id == itemId,
    );
    if (index >= 0) {
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + 1,
      );
    }
    cartItems.refresh();
    categories.refresh();
  }

  void decrimentQuantity(String categoryTitle, int itemId) {
    int categoryIndex = categories.indexWhere(
      (element) => element.title == categoryTitle,
    );
    int itemIndex = categories[categoryIndex].items.indexWhere(
      (element) => element.id == itemId,
    );
    if (categoryIndex >= 0 && itemIndex >= 0) {
      if (categories[categoryIndex].items[itemIndex].quantity > 0) {
        categories[categoryIndex].items[itemIndex] = categories[categoryIndex]
            .items[itemIndex]
            .copyWith(
              quantity: categories[categoryIndex].items[itemIndex].quantity - 1,
            );
      }
    }
    int index = cartItems.indexWhere(
      (element) =>
          element.categoryName == categoryTitle && element.id == itemId,
    );
    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index] = cartItems[index].copyWith(
          quantity: cartItems[index].quantity - 1,
        );
      } else {
        cartItems.removeAt(index);
      }
    }
    cartItems.refresh();
    categories.refresh();
  }
}

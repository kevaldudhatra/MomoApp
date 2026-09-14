import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/screens/cartManagement/cart_controller.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

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
  final int catId;
  final String title;
  final int itemCount;

  MenuPopupCategoryItem({
    required this.catId,
    required this.title,
    required this.itemCount,
  });
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
      barrierDismissible: true,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent Category Row
        GestureDetector(
          onTap: () {
            onCategorySelected?.call(category);
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                // Title + Dropdown Icon
                Expanded(
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
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
            BoxShadow(color: cardShadow, blurRadius: 24, offset: Offset(0, 10)),
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
    );
  }
}

class FoodItemDetailsBottomSheet extends StatefulWidget {
  final dynamic foodItem;
  final VoidCallback? onClose;

  const FoodItemDetailsBottomSheet({
    super.key,
    required this.foodItem,
    this.onClose,
  });

  // Helper static method to display the bottom sheet cleanly
  static Future<void> show(
    BuildContext context, {
    required dynamic foodItem,
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
  int _selectedToppingIndex = 0;
  final Set<int> _selectedAddons = {-1};
  int quantity = 1;
  double totalPrice = 0.0;
  double itemPrice = 0.0;

  final List<Map<String, dynamic>> _customOptions = [
    {"name": "Regular (serves 1, 17.7 cm)", "price": 350},
    {"name": "Regular (serves 1, 17.7 cm)", "price": 450},
    {"name": "Regular (serves 1, 17.7 cm)", "price": 550},
  ];

  @override
  void initState() {
    super.initState();
    itemPrice = widget.foodItem["defaultPrice"]["comparePrice"] == 0
        ? double.parse(
            widget.foodItem["defaultPrice"]["sellingPrice"].toString(),
          )
        : double.parse(
            widget.foodItem["defaultPrice"]["comparePrice"].toString(),
          );
    calculateFinalPrice();
  }

  void calculateFinalPrice() {
    setState(() {
      double finalItemPrice = itemPrice;
      double addonPrice = 0;
      for (int index in _selectedAddons) {
        if (index != -1) {
          addonPrice += _customOptions[index]["price"];
        }
      }
      totalPrice = (finalItemPrice + addonPrice) * quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
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
              height: double.infinity,
              decoration: const BoxDecoration(
                color: background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Stack(
                  children: [
                    // Main Food Item View
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 65),
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
                                  child: widget.foodItem["itemImage"] == null
                                      ? Image.asset(
                                          AppImages().momoImg,
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          widget.foodItem["itemImage"],
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Veg/Non-Veg Badge Icon
                                      Image.asset(
                                        AppImages().vegIcon,
                                        width: 20,
                                        height: 20,
                                      ),
                                      const SizedBox(height: 8),

                                      // Food Item Title
                                      Text(
                                        widget.foodItem["name"],
                                        style: const TextStyle(
                                          fontFamily: natoBold,
                                          fontSize: 18,
                                          color: black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),

                                      // Description text
                                      Text(
                                        widget.foodItem["description"],
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
                                        "₹${widget.foodItem["defaultPrice"]["comparePrice"] == 0 ? widget.foodItem["defaultPrice"]["sellingPrice"] : widget.foodItem["defaultPrice"]["comparePrice"]}",
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          itemPrice = double.parse(
                                            option["price"].toString(),
                                          );
                                          calculateFinalPrice();
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            calculateFinalPrice();
                                          } else {
                                            _selectedAddons.add(index);
                                            calculateFinalPrice();
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
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: isSelected
                                                    ? orange
                                                    : white,
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

                    // Cart Button
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width,
                        color: white,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 40,
                              decoration: BoxDecoration(
                                color: white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: orange, width: 1),
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (quantity > 1) {
                                        setState(() {
                                          quantity--;
                                          calculateFinalPrice();
                                        });
                                      }
                                    },
                                    child: const Icon(
                                      Icons.remove,
                                      color: charcoalGray,
                                      size: 16,
                                    ),
                                  ),
                                  Text(
                                    quantity.toString(),
                                    style: const TextStyle(
                                      color: charcoalGray,
                                      fontSize: 14,
                                      fontFamily: natoBold,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        quantity++;
                                        calculateFinalPrice();
                                      });
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

                            Expanded(
                              child: Container(
                                height: 40,
                                margin: EdgeInsets.only(left: 16),
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
                                child: Text(
                                  "Add Item ₹${totalPrice.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: white,
                                    fontSize: 14,
                                    fontFamily: natoBold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
  final storage = GetStorage();

  RxList<CartItem> get cartItems => Get.isRegistered<CartController>()
      ? Get.find<CartController>().cartItems
      : <CartItem>[].obs;

  RxMap<dynamic, dynamic> get outletDetails =>
      Get.isRegistered<DeliveryScreenController>()
      ? Get.find<DeliveryScreenController>().outlateDetails
      : {}.obs;
  RxBool isLoading = true.obs;
  RxBool filterLoading = false.obs;
  final searchController = TextEditingController();
  final categories = <MenuCategory>[].obs;
  RxBool isMenuOpen = false.obs;
  RxMap<dynamic, dynamic> outletInfo = {}.obs;
  RxList<MenuPopupCategoryItem> menuItems = <MenuPopupCategoryItem>[].obs;
  RxList<dynamic> foodTypes = [].obs;
  RxList<dynamic> foodItems = [].obs;
  RxMap<dynamic, dynamic> foodItemsDetails = {}.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await getFoodData(outletId: outletDetails['id'], typeId: 0);
      await getFoodTypes(outletId: outletDetails['id']);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getFoodData({int? outletId, int? typeId}) async {
    print('getFoodData Input: $outletId');
    print('getFoodData Input: $typeId');
    try {
      menuItems.clear();
      foodItems.clear();
      filterLoading.value = true;
      final response = await http.get(
        Uri.parse(
          ApiServices.getFoodData
              .replaceAll('{outletId}', outletId.toString())
              .replaceAll('{typeId}', typeId.toString()),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getFoodData Response status: ${response.statusCode}');
      print('getFoodData Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        outletInfo.value = data["data"]["outlate"] ?? {};
        for (var item in data["data"]["sections"] ?? []) {
          menuItems.add(
            MenuPopupCategoryItem(
              catId: item["category"]["id"],
              title: item["category"]["name"],
              itemCount: item["itemCount"],
            ),
          );
        }
        for (var item in data["data"]["sections"] ?? []) {
          foodItems.add({...item, "isExpanded": true});
        }
      } else {
        outletInfo.value = {};
        menuItems.clear();
        foodItems.clear();
      }
    } catch (e) {
      print('getFoodData Error: $e');
      outletInfo.value = {};
      menuItems.clear();
      foodItems.clear();
    } finally {
      filterLoading.value = false;
    }
  }

  Future<void> getFoodTypes({int? outletId}) async {
    print('getFoodTypes Input: $outletId');
    try {
      final response = await http.get(
        Uri.parse(
          ApiServices.getFoodTypes.replaceAll(
            '{outletId}',
            outletId.toString(),
          ),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getFoodTypes Response status: ${response.statusCode}');
      print('getFoodTypes Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        for (var item in data["data"] ?? []) {
          foodTypes.add({...item, "isSelected": false});
        }
      } else {
        foodTypes.clear();
      }
    } catch (e) {
      print('getFoodTypes Error: $e');
      foodTypes.clear();
    }
  }

  Future<void> getFoodItemDetails({int? outletId, int? itemId}) async {
    print('getFoodItemDetails Input: $outletId, $itemId');
    try {
      final response = await http.get(
        Uri.parse(
          ApiServices.getFoodItemDetails
              .replaceAll('{outletId}', outletId.toString())
              .replaceAll('{itemId}', itemId.toString()),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getFoodItemDetails Response status: ${response.statusCode}');
      print('getFoodItemDetails Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        foodItemsDetails.value = data["data"] ?? {};
      } else {
        foodItemsDetails.value = {};
      }
    } catch (e) {
      print('getFoodItemDetails Error: $e');
      foodItemsDetails.value = {};
    }
  }

  Future<void> toggleFilter(dynamic foodType) async {
    for (var item in foodTypes) {
      if (item["id"] == foodType["id"]) {
        item["isSelected"] = !item["isSelected"];
        if (item["isSelected"]) {
          await getFoodData(outletId: outletDetails['id'], typeId: item["id"]);
        } else {
          await getFoodData(outletId: outletDetails['id'], typeId: 0);
        }
      } else {
        item["isSelected"] = false;
      }
    }
    foodTypes.refresh();
  }

  void toggleCategory(dynamic category) {
    category["isExpanded"] = !(category["isExpanded"] ?? false);
    foodItems.refresh();
  }

  void showMenuPopup(BuildContext context) {
    isMenuOpen.value = true;
    MenuPopupWidget.show(
      context,
      categories: menuItems,
      onCategorySelected: (selectedCategory) {
        print(
          "Selected Item from Menu Popup : ${selectedCategory.title} ${selectedCategory.itemCount}",
        );
      },
    ).then((_) {
      isMenuOpen.value = false;
    });
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

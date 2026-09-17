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
  int quantity = 1;
  double totalPrice = 0.0;
  double itemPrice = 0.0;
  final Map<String, dynamic> _selectedRadioOptions = {};
  final Map<String, Set<String>> _selectedCheckboxOptionIds = {};
  final Map<String, dynamic> _allOptionsMap = {};
  List<dynamic> get modifierGroups =>
      widget.foodItem["modifierGroups"] as List<dynamic>? ?? [];

  @override
  void initState() {
    super.initState();
    final defaultPrice = widget.foodItem["defaultPrice"];
    if (defaultPrice != null) {
      final comparePrice =
          double.tryParse(defaultPrice["comparePrice"]?.toString() ?? "0") ??
          0.0;
      final sellingPrice =
          double.tryParse(defaultPrice["sellingPrice"]?.toString() ?? "0") ??
          0.0;
      itemPrice = comparePrice == 0 ? sellingPrice : comparePrice;
    } else {
      itemPrice = 0.0;
    }

    // Cache options and set default selections for required groups
    for (var group in modifierGroups) {
      final groupId = group["id"]?.toString() ?? "";
      final isRequired = group["isRequired"] == true;
      final options = group["options"] as List<dynamic>? ?? [];

      for (var option in options) {
        final optId = option["id"]?.toString() ?? "";
        _allOptionsMap[optId] = option;
      }

      if (isRequired && options.isNotEmpty) {
        final defaultOption = options.firstWhere(
          (opt) => opt["isAvailable"] != false,
          orElse: () => options.first,
        );
        _selectedRadioOptions[groupId] = defaultOption;
      }
    }

    calculateFinalPrice();
  }

  void calculateFinalPrice() {
    setState(() {
      double modifierPrice = 0.0;

      // Add radio options price
      _selectedRadioOptions.forEach((groupId, option) {
        if (option != null && option["price"] != null) {
          modifierPrice += double.tryParse(option["price"].toString()) ?? 0.0;
        }
      });

      // Add checkbox options price
      _selectedCheckboxOptionIds.forEach((groupId, optionIds) {
        for (var optId in optionIds) {
          final opt = _allOptionsMap[optId];
          if (opt != null && opt["price"] != null) {
            modifierPrice += double.tryParse(opt["price"].toString()) ?? 0.0;
          }
        }
      });

      totalPrice = (itemPrice + modifierPrice) * quantity;
    });
  }

  // Get all selected modifier option/item IDs from _buildModifierGroupCard
  List<int> get selectedModifierOptionIds {
    final List<int> ids = [];
    _selectedRadioOptions.forEach((groupId, option) {
      if (option != null && option["id"] != null) {
        ids.add(option["id"]);
      }
    });
    _selectedCheckboxOptionIds.forEach((groupId, optionIds) {
      for (var id in optionIds) {
        final rawId = _allOptionsMap[id]?["id"] ?? id;
        ids.add(rawId);
      }
    });
    return ids;
  }

  // Dynamic Modifier Group Card (Radio for isRequired == true, Checkbox for isRequired == false)
  Widget _buildModifierGroupCard(dynamic group) {
    final groupId = group["id"]?.toString() ?? "";
    final isRequired = group["isRequired"] == true;
    final options = group["options"] as List<dynamic>? ?? [];
    final selectedCheckboxSet = _selectedCheckboxOptionIds[groupId] ?? {};

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: cardShadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group["name"]?.toString() ?? "",
                  style: const TextStyle(
                    fontFamily: natoBold,
                    fontSize: 15.5,
                    color: black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isRequired ? "Required • select any 1 option" : "Optional",
                  style: const TextStyle(
                    fontFamily: natoRegular,
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: borderGray),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, thickness: 1, color: borderGray),
            itemBuilder: (context, index) {
              final option = options[index];
              final optId = option["id"]?.toString() ?? "";
              final isAvailable = option["isAvailable"] != false;
              final selectedRadio = _selectedRadioOptions[groupId];
              final isSelected = isRequired
                  ? (selectedRadio != null &&
                        selectedRadio["id"]?.toString() == optId)
                  : selectedCheckboxSet.contains(optId);

              return GestureDetector(
                onTap: () {
                  if (!isAvailable) return;
                  setState(() {
                    if (isRequired) {
                      _selectedRadioOptions[groupId] = option;
                    } else {
                      final currentSet = _selectedCheckboxOptionIds.putIfAbsent(
                        groupId,
                        () => <String>{},
                      );
                      if (currentSet.contains(optId)) {
                        currentSet.remove(optId);
                      } else {
                        final max = group["max"];
                        if (max != null) {
                          final maxInt = int.tryParse(max.toString());
                          if (maxInt != null &&
                              maxInt > 0 &&
                              currentSet.length >= maxInt) {
                            return;
                          }
                        }
                        currentSet.add(optId);
                      }
                    }
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
                          option["name"]?.toString() ?? "",
                          style: TextStyle(
                            fontFamily: natoRegular,
                            fontSize: 14.5,
                            color: isAvailable ? black : lightGray,
                          ),
                        ),
                      ),
                      Text(
                        "₹${option["price"] ?? 0}",
                        style: TextStyle(
                          fontFamily: natoBold,
                          fontSize: 14.5,
                          color: isAvailable ? black : lightGray,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Radio or Checkbox based on isRequired
                      if (isRequired)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? orange : lightGray,
                              width: isSelected ? 6 : 1.5,
                            ),
                            color: white,
                          ),
                        )
                      else
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isSelected ? orange : white,
                            border: Border.all(
                              color: isSelected ? orange : lightGray,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 14, color: white)
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
    );
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
                                        widget.foodItem["itemType"] == 1
                                            ? AppImages().vegIcon
                                            : AppImages().nonVegIcon,
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

                          // Dynamic Modifier Group Cards
                          ...modifierGroups.map(
                            (group) => _buildModifierGroupCard(group),
                          ),
                        ],
                      ),
                    ),

                    // Cart Button
                    widget.foodItem["hasCustomisation"]
                        ? Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: Container(
                              height: 55,
                              width: MediaQuery.of(context).size.width,
                              color: white,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 70,
                                    height: 40,
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
                                    child: GestureDetector(
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        await Get.find<OutletScreenController>()
                                            .addItemToCart(
                                              itemQuantity: quantity,
                                              itemData: widget.foodItem,
                                              modifierOption:
                                                  selectedModifierOptionIds,
                                            );
                                      },
                                      child: Container(
                                        height: 40,
                                        margin: EdgeInsets.only(left: 16),
                                        decoration: BoxDecoration(
                                          color: orange,
                                          borderRadius: BorderRadius.circular(
                                            8,
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
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
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
  final searchController = TextEditingController();
  final scrollController = ScrollController();
  final Map<int, GlobalKey> categoryKeys = {};
  final Map<int, GlobalKey> itemKeys = {};
  RxBool isLoading = true.obs;
  RxBool filterLoading = false.obs;
  RxBool isMenuOpen = false.obs;
  RxMap<dynamic, dynamic> outletInfo = {}.obs;
  RxList<MenuPopupCategoryItem> menuItems = <MenuPopupCategoryItem>[].obs;
  RxList<dynamic> foodTypes = [].obs;
  RxList<dynamic> foodItems = [].obs;
  RxMap<dynamic, dynamic> foodItemsDetails = {}.obs;
  RxMap<dynamic, dynamic> get outletDetails =>
      Get.isRegistered<DeliveryScreenController>()
      ? Get.find<DeliveryScreenController>().outlateDetails
      : {}.obs;

  GlobalKey getCategoryKey(dynamic catId) {
    final id = int.tryParse(catId.toString()) ?? 0;
    return categoryKeys.putIfAbsent(id, () => GlobalKey());
  }

  GlobalKey getItemKey(dynamic itemId) {
    final id = int.tryParse(itemId.toString()) ?? 0;
    return itemKeys.putIfAbsent(id, () => GlobalKey());
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
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
      categoryKeys.clear();
      itemKeys.clear();
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
        foodItems.refresh();
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
        foodTypes.add({
          "id": 0,
          "outlateId": outletId,
          "name": "All",
          "isActive": true,
          "isSelected": true,
        });
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

  Future<void> addItemToCart({
    required int itemQuantity,
    required dynamic itemData,
    required List<int> modifierOption,
  }) async {
    print('addItemToCart Input: $itemQuantity, $modifierOption, $itemData');
    try {
      final response = await http.post(
        Uri.parse(ApiServices.addItemToCart),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode({
          "outlateId": itemData["outlateId"],
          "itemId": itemData["id"],
          "itemPriceId": itemData["defaultPrice"]["id"],
          "quantity": itemQuantity,
          "modifierOptionIds": modifierOption,
        }),
      );
      print('addItemToCart Response status: ${response.statusCode}');
      print('addItemToCart Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 201 && data["success"] == true) {
        Get.find<CartController>().addItemToCart(
          cartItem: data["data"]["items"],
          billData: data["data"]["bill"],
        );
        for (var element in foodItems) {
          if (element["category"]["id"] == itemData["categoryId"]) {
            for (var item in element["items"]) {
              if (item["id"] == itemData["id"]) {
                item["cartCount"] = itemQuantity;
              }
            }
          }
        }
        foodItems.refresh();
      } else {
        foodItems.refresh();
        Get.snackbar(
          "Oops!",
          data['message'] ?? "Something went wrong. Please try again.",
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.error, color: Colors.red),
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('addItemToCart Error: $e');
      foodItems.refresh();
    }
  }

  Future<void> incrementQuantity({required dynamic itemData}) async {
    print('incrementQuantity Input: ${itemData['cartCount']}');
    try {
      final response = await http.patch(
        Uri.parse(
          ApiServices.updateItemQuantity.replaceAll(
            '{itemId}',
            itemData['id'].toString(),
          ),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode({
          "quantity": itemData["cartCount"] + 1,
          "itemPriceId": itemData["defaultPrice"]["id"],
        }),
      );
      print('incrementQuantity Response status: ${response.statusCode}');
      print('incrementQuantity Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        Get.find<CartController>().addItemToCart(
          cartItem: data["data"]["items"],
          billData: data["data"]["bill"],
        );
        for (var element in foodItems) {
          if (element["category"]["id"] == itemData["categoryId"]) {
            for (var item in element["items"]) {
              if (item["id"] == itemData["id"]) {
                item["cartCount"] = itemData["cartCount"] + 1;
              }
            }
          }
        }
        foodItems.refresh();
      } else {
        foodItems.refresh();
        Get.snackbar(
          "Oops!",
          data['message'] ?? "Something went wrong. Please try again.",
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.error, color: Colors.red),
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('incrementQuantity Error: $e');
      foodItems.refresh();
    }
  }

  Future<void> decrimentQuantity({required dynamic itemData}) async {
    print('decrimentQuantity Input: ${itemData['cartCount']}');
    try {
      final response = await http.patch(
        Uri.parse(
          ApiServices.updateItemQuantity.replaceAll(
            '{itemId}',
            itemData['id'].toString(),
          ),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode({
          "quantity": itemData["cartCount"] - 1,
          "itemPriceId": itemData["defaultPrice"]["id"],
        }),
      );
      print('decrimentQuantity Response status: ${response.statusCode}');
      print('decrimentQuantity Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        Get.find<CartController>().addItemToCart(
          cartItem: data["data"]["items"],
          billData: data["data"]["bill"],
        );
        for (var element in foodItems) {
          if (element["category"]["id"] == itemData["categoryId"]) {
            for (var item in element["items"]) {
              if (item["id"] == itemData["id"]) {
                item["cartCount"] = itemData["cartCount"] - 1;
              }
            }
          }
        }
        foodItems.refresh();
      } else {
        foodItems.refresh();
      }
    } catch (e) {
      print('decrimentQuantity Error: $e');
      foodItems.refresh();
    }
  }

  Future<void> toggleFilter(dynamic foodType) async {
    for (var item in foodTypes) {
      if (item["id"] == foodType["id"]) {
        item["isSelected"] = true;
        if (item["isSelected"]) {
          await getFoodData(outletId: outletDetails['id'], typeId: item["id"]);
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
        scrollToCategory(selectedCategory.catId);
      },
    ).then((_) {
      isMenuOpen.value = false;
    });
  }

  void scrollToCategory(dynamic catId) {
    final id = int.tryParse(catId.toString()) ?? 0;
    final catIndex = foodItems.indexWhere(
      (item) =>
          (int.tryParse(item["category"]?["id"]?.toString() ?? "") ?? -1) == id,
    );
    if (catIndex != -1) {
      if (foodItems[catIndex]["isExpanded"] != true) {
        foodItems[catIndex]["isExpanded"] = true;
        foodItems.refresh();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = categoryKeys[id];
      if (key?.currentContext != null && key!.currentContext!.mounted) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    });
  }
}

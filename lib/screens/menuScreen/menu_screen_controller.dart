import 'package:get/get.dart';
import 'package:momos/utils/const_image_key.dart';

class MenuItemModel {
  final String name;
  final double price;
  final String description;
  final String image;
  final bool isVeg;
  final String category;

  MenuItemModel({
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.isVeg,
    required this.category,
  });
}

class MenuScreenController extends GetxController {
  final searchQuery = "".obs;
  final isVegSelected = true.obs;
  final isNonVegSelected = false.obs;
  final menuItems = <MenuItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMenuItems();
  }

  void _loadMenuItems() {
    menuItems.assignAll([
      // Recommendations Section
      MenuItemModel(
        name: "Smokey Chilli Paneer",
        price: 350.0,
        description:
            "Choice of noodles(veg/chicken/shrimp/mixbxcv dgfdf\ncjasdasgdgskud",
        image: AppImages().foodItemOne,
        isVeg: true,
        category: "Recommendations",
      ),
      MenuItemModel(
        name: "Smokey Chilli Paneer",
        price: 350.0,
        description:
            "Choice of noodles(veg/chicken/shrimp/mixbxcv dgfdf\ncjasdasgdgskud",
        image: AppImages().foodItemOne,
        isVeg: true,
        category: "Recommendations",
      ),
      MenuItemModel(
        name: "Smokey Chilli Paneer",
        price: 350.0,
        description:
            "Choice of noodles(veg/chicken/shrimp/mixbxcv dgfdf\ncjasdasgdgskud",
        image: AppImages().foodItemOne,
        isVeg: false,
        category: "Recommendations",
      ),

      // Combo foods Section
      MenuItemModel(
        name: "Smokey Chilli Paneer",
        price: 350.0,
        description:
            "Choice of noodles(veg/chicken/shrimp/mixbxcv dgfdf\ncjasdasgdgskud",
        image: AppImages().foodItemOne,
        isVeg: true,
        category: "Combo foods",
      ),
      MenuItemModel(
        name: "Smokey Chilli Paneer",
        price: 350.0,
        description:
            "Choice of noodles(veg/chicken/shrimp/mixbxcv dgfdf\ncjasdasgdgskud",
        image: AppImages().foodItemOne,
        isVeg: true,
        category: "Combo foods",
      ),
      MenuItemModel(
        name: "Smokey Chilli Paneer",
        price: 350.0,
        description:
            "Choice of noodles(veg/chicken/shrimp/mixbxcv dgfdf\ncjasdasgdgskud",
        image: AppImages().foodItemOne,
        isVeg: false,
        category: "Combo foods",
      ),
    ]);
  }

  List<MenuItemModel> get filteredItems {
    return menuItems.where((item) {
      // 1. Search Query Filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchesQuery =
            item.name.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query);
        if (!matchesQuery) return false;
      }

      // 2. Veg / Non Veg Filters
      if (isVegSelected.value && isNonVegSelected.value) {
        return true;
      }
      if (isVegSelected.value) {
        return item.isVeg;
      }
      if (isNonVegSelected.value) {
        return !item.isVeg;
      }
      return false; // Show nothing if neither is selected
    }).toList();
  }
}

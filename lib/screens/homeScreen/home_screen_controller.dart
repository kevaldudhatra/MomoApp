import 'package:get/get.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/screens/diningScreen/dining_screen_controller.dart';
import 'package:momos/screens/profileScreen/profile_screen_controller.dart';

class HomeScreenController extends GetxController {
  final selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
    if (index == 0) {
      Get.find<DeliveryScreenController>().onInit();
    } else if (index == 1) {
      Get.find<DiningScreenController>().onInit();
    } else if (index == 2) {
      Get.find<ProfileScreenController>().onInit();
    }
  }
}

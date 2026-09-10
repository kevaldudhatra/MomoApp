import 'package:get/get.dart';
import 'package:momos/screens/bookTableScreen/book_table_screen_controller.dart';
import 'package:momos/screens/profileScreen/profile_screen_controller.dart';

class HomeScreenController extends GetxController {
  final selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
    if (index == 1) {
      Get.find<BookTableScreenController>().onInit();
    } else if (index == 2) {
      Get.find<ProfileScreenController>().onInit();
    }
  }
}

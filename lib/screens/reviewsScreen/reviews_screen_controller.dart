import 'package:get/get.dart';
import 'package:momos/screens/outletDetailScreen/outlet_detail_screen_controller.dart';

class ReviewsScreenController extends GetxController {
  RxList<OutletReview> reviews =
      Get.isRegistered<OutletDetailScreenController>()
      ? Get.find<OutletDetailScreenController>().reviews.toList().obs
      : <OutletReview>[].obs;
}

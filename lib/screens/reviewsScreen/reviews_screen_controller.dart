import 'package:get/get.dart';
import 'package:momos/screens/outletDetailScreen/outlet_detail_screen_controller.dart';

class ReviewsScreenController extends GetxController {
  final reviews = <OutletReview>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadReviewsData();
  }

  void _loadReviewsData() {
    reviews.assignAll([
      OutletReview(
        userName: "Sandipan",
        userInitial: "S",
        timeAgo: "16h ago",
        rating: 5,
        comment:
            "Great experience as always! The food was delivered hot and the quality was top-notch. Truly one of the best Chinese restaurants in the area.",
      ),
      OutletReview(
        userName: "Sandipan",
        userInitial: "S",
        timeAgo: "16h ago",
        rating: 5,
        comment:
            "Great experience as always! The food was delivered hot and the quality was top-notch. Truly one of the best Chinese restaurants in the area.",
      ),
      OutletReview(
        userName: "Sandipan",
        userInitial: "S",
        timeAgo: "16h ago",
        rating: 5,
        comment:
            "Great experience as always! The food was delivered hot and the quality was top-notch. Truly one of the best Chinese restaurants in the area.",
      ),
      OutletReview(
        userName: "Sandipan",
        userInitial: "S",
        timeAgo: "16h ago",
        rating: 5,
        comment:
            "Great experience as always! The food was delivered hot and the quality was top-notch. Truly one of the best Chinese restaurants in the area.",
      ),
      OutletReview(
        userName: "Sandipan",
        userInitial: "S",
        timeAgo: "16h ago",
        rating: 5,
        comment:
            "Great experience as always! The food was delivered hot and the quality was top-notch. Truly one of the best Chinese restaurants in the area.",
      ),
      OutletReview(
        userName: "Sandipan",
        userInitial: "S",
        timeAgo: "16h ago",
        rating: 5,
        comment:
            "Great experience as always! The food was delivered hot and the quality was top-notch. Truly one of the best Chinese restaurants in the area.",
      ),
    ]);
  }
}

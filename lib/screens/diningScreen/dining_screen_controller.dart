import 'package:get/get.dart';

class DiningReview {
  final String userInitial;
  final String userName;
  final String timeAgo;
  final int rating;
  final String comment;

  DiningReview({
    required this.userInitial,
    required this.userName,
    required this.timeAgo,
    required this.rating,
    required this.comment,
  });
}

class DiningScreenController extends GetxController {
  final activeTab = "Offers".obs;
  final carouselPage = 0.obs;
  final reviewsList = <DiningReview>[].obs;

  final List<String> tabOptions = ["Offers", "Photos", "Reviews"];

  @override
  void onInit() {
    super.onInit();
    _loadReviews();
  }

  void _loadReviews() {
    reviewsList.assignAll([
      DiningReview(
        userInitial: "S",
        userName: "Sandipan",
        timeAgo: "16h ago",
        rating: 5,
        comment:
            "Great experience as always! The food was delivered hot and the quality was top-notch. Truly one of the best Chinese restaurants in the area.",
      ),
      DiningReview(
        userInitial: "S",
        userName: "Sandipan",
        timeAgo: "10h ago",
        rating: 5,
        comment:
            "Great experience as always! The food was delivered hot and the quality was top-notch. Truly one of the best Chinese restaurants in the area.",
      ),
      DiningReview(
        userInitial: "S",
        userName: "Sandipan",
        timeAgo: "16h ago",
        rating: 5,
        comment:
            "Great experience as always! The food was delivered hot and the quality was top-notch. Truly one of the best Chinese restaurants in the area.",
      ),
    ]);
  }
}

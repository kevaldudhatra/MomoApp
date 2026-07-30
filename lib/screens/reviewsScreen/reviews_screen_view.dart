import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/outletDetailScreen/outlet_detail_screen_controller.dart';
import 'package:momos/screens/reviewsScreen/reviews_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';

class ReviewsScreen extends GetView<ReviewsScreenController> {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Image.asset(AppImages().backArrowIcon, width: 18, height: 18, color: black),
                    ),
                  ),
                  const Text(
                    "Reviews",
                    style: TextStyle(fontFamily: natoBold, fontSize: 18, color: black),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: borderGray),

            // Scrollable Reviews List
            Expanded(
              child: Obx(
                () => ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  itemCount: controller.reviews.length,
                  itemBuilder: (context, index) {
                    final review = controller.reviews[index];
                    return _buildReviewCard(review);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Single Review Card Widget
  Widget _buildReviewCard(OutletReview review) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top User Row: Avatar Circle, User Name, Time Ago
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(color: avatarBg, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    review.userInitial,
                    style: const TextStyle(fontFamily: natoBold, fontSize: 15, color: avatarTextColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                review.userName,
                style: const TextStyle(fontFamily: natoBold, fontSize: 16, color: black),
              ),
              const Spacer(),
              Text(
                review.timeAgo,
                style: const TextStyle(fontFamily: natoRegular, fontSize: 13, color: textSecondary),
              ),
            ],
          ),

          // Rating Stars Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: List.generate(
                review.rating,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Image.asset(AppImages().starIcon, width: 15, height: 15, color: greenBadge),
                ),
              ),
            ),
          ),

          // Review Comment Text
          Text(
            review.comment,
            style: const TextStyle(fontFamily: natoRegular, fontSize: 13.5, color: sectionHeaderColor, height: 1.4),
          ),
        ],
      ),
    );
  }
}

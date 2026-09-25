import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/outletDetailScreen/outlet_detail_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/loading_view.dart';

class OutletDetailScreen extends GetView<OutletDetailScreenController> {
  const OutletDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar Header
            Container(
              color: white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Image.asset(
                        AppImages().backArrowIcon,
                        width: 18,
                        height: 18,
                        color: black,
                      ),
                    ),
                  ),
                  Obx(
                    () => Text(
                      controller.outletName.value,
                      style: const TextStyle(
                        fontFamily: natoBold,
                        fontSize: 18,
                        color: black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Obx(
              () => controller.isLoading.value
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: const Center(child: LoadingDialog()),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Outlet Map
                            SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: GoogleMap(
                                zoomControlsEnabled: false,
                                initialCameraPosition: CameraPosition(
                                  target: controller.outletLocation.value,
                                  zoom: 15,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('location'),
                                    position: controller.outletLocation.value,
                                    infoWindow: const InfoWindow(
                                      title: 'My Location',
                                    ),
                                  ),
                                },
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Address Section
                            _buildSectionHeader("Address"),
                            _buildAddressCard(controller),
                            const SizedBox(height: 12),

                            // Restaurant Contact Section
                            _buildSectionHeader("Restaurant contact"),
                            _buildContactCard(controller),
                            const SizedBox(height: 12),

                            // Opening Hours Section
                            _buildSectionHeader("Opening hours"),
                            _buildOpeningHoursCard(context, controller),
                            const SizedBox(height: 12),

                            // Reviews Section
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Reviews",
                                    style: TextStyle(
                                      fontFamily: natoMedium,
                                      fontSize: 15,
                                      color: sectionHeaderColor,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(Routes.reviewsScreen);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: const Text(
                                      "View all",
                                      style: TextStyle(
                                        fontFamily: natoMedium,
                                        fontSize: 14,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            controller.reviews.isNotEmpty
                                ? Column(
                                    children: controller.reviews
                                        .take(3)
                                        .map(
                                          (review) => _buildReviewCard(review),
                                        )
                                        .toList(),
                                  )
                                : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 16,
                                        bottom: 16,
                                      ),
                                      child: Text(
                                        "No reviews yet",
                                        style: TextStyle(
                                          fontFamily: natoMedium,
                                          fontSize: 15,
                                          color: sectionHeaderColor,
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Section Header Widget
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: natoMedium,
          fontSize: 15,
          color: sectionHeaderColor,
        ),
      ),
    );
  }

  // Address Card Container Widget
  Widget _buildAddressCard(OutletDetailScreenController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppImages().locationIcon,
            color: charcoalGray,
            width: 22,
            height: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.fullAddress.value,
              style: const TextStyle(
                fontFamily: natoRegular,
                fontSize: 13.5,
                color: textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Restaurant Contact Card Container Widget
  Widget _buildContactCard(OutletDetailScreenController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(AppImages().phoneIcon, width: 20, height: 20),
          const SizedBox(width: 12),
          Text(
            controller.contactNumber.value,
            style: const TextStyle(
              fontFamily: natoBold,
              fontSize: 16,
              color: black,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              controller.makePhoneCall();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Call now",
                style: TextStyle(
                  fontFamily: natoMedium,
                  fontSize: 14,
                  color: white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Opening Hours Card Container Widget
  Widget _buildOpeningHoursCard(
    BuildContext context,
    OutletDetailScreenController controller,
  ) {
    return GestureDetector(
      onTap: () => controller.showOpeningHoursBottomSheet(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Image.asset(AppImages().clockIcon, width: 22, height: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.openingStatus.value,
                    style: const TextStyle(
                      fontFamily: natoBold,
                      fontSize: 16,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.openingHoursInfo.value,
                    style: const TextStyle(
                      fontFamily: natoRegular,
                      fontSize: 13.5,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => controller.showOpeningHoursBottomSheet(context),
              child: Image.asset(
                AppImages().infoIcon,
                width: 20,
                height: 20,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Single Review Card Widget
  Widget _buildReviewCard(OutletReview review) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar, User Name, Time Ago
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userInitial,
                    style: const TextStyle(
                      fontFamily: natoBold,
                      fontSize: 15,
                      color: avatarTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                review.userName,
                style: const TextStyle(
                  fontFamily: natoBold,
                  fontSize: 16,
                  color: black,
                ),
              ),
              const Spacer(),
              Text(
                review.timeAgo,
                style: const TextStyle(
                  fontFamily: natoRegular,
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
            ],
          ),

          // Rating Stars Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: RatingBarIndicator(
              rating: double.tryParse(review.rating.toString()) ?? 0.0,
              itemBuilder: (context, index) =>
                  const Icon(Icons.star, color: greenBadge),
              itemCount: 5,
              itemSize: 24.0,
              direction: Axis.horizontal,
            ),
          ),

          // Review Comment Content Text
          Text(
            review.comment,
            style: const TextStyle(
              fontFamily: natoRegular,
              fontSize: 13.5,
              color: sectionHeaderColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

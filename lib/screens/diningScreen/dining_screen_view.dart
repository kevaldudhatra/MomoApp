import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/diningScreen/dining_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';

class DiningScreen extends GetView<DiningScreenController> {
  const DiningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        body: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Outlet info view
                    _buildOverlappingHeaderCard(),

                    // View Menu Button
                    _buildViewMenuButton(),

                    // Tab Pill Buttons Row
                    _buildTabPillsRow(),

                    Obx(
                      () => controller.activeTab.value == "Offers"
                          ? _buildCarouselSlider()
                          : _buildReviewsSection(),
                    ),

                    // Book a Table Button
                    _buildBookTableButton(),

                    // Address Section
                    _buildAddressSection(),

                    // Opening Hours Section
                    _buildOpeningHoursSection(),

                    // Contact Section
                    _buildContactSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlappingHeaderCard() {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                orangeGradientStart,
                orangeGradientEnd,
                orangeGradientStart,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: black.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 15, top: 30),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: cardShadow,
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Outlet Thumbnail Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      AppImages().outletOneImg,
                      width: 85,
                      height: 85,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title, Cuisines & Open Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Momo I AM gol park',
                          style: const TextStyle(
                            color: black,
                            fontSize: 18,
                            fontFamily: natoBold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chinese • Seafood • Thai • Pan-Asian',
                          style: const TextStyle(
                            color: charcoalGray,
                            fontSize: 13,
                            fontFamily: natoRegular,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Open Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: greenBadge,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Open",
                            style: TextStyle(
                              color: white,
                              fontSize: 11,
                              fontFamily: natoMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 1, color: borderGray),
              const SizedBox(height: 12),
              // Rating & Delivery Time Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Star Rating & Reviews
                  Image.asset(
                    AppImages().starIcon,
                    width: 18,
                    height: 18,
                    color: greenBadge,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '4.2',
                    style: const TextStyle(
                      color: black,
                      fontSize: 14,
                      fontFamily: natoBold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "|  (455 Reviews)",
                    style: const TextStyle(
                      color: charcoalGray,
                      fontSize: 13,
                      fontFamily: natoRegular,
                    ),
                  ),
                  const Spacer(),
                  // Delivery Time
                  Image.asset(
                    AppImages().timerIcon,
                    width: 18,
                    height: 18,
                    color: charcoalGray,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "34-39 mins",
                    style: const TextStyle(
                      color: black,
                      fontSize: 13,
                      fontFamily: natoMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewMenuButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: CustomButton(
        label: "View Menu",
        height: 45,
        width: double.infinity,
        onTap: () => Get.toNamed(Routes.menuScreen),
      ),
    );
  }

  Widget _buildTabPillsRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      child: Obx(
        () => Row(
          children: controller.tabOptions.map((tab) {
            final isSelected = controller.activeTab.value == tab;
            return GestureDetector(
              onTap: () => controller.activeTab.value = tab,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? orange : borderGray,
                    width: 1,
                  ),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isSelected ? orange : black,
                    fontSize: 13.5,
                    fontFamily: isSelected ? natoMedium : natoRegular,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCarouselSlider() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            onPageChanged: (index) {
              controller.carouselPage.value = index;
            },
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    AppImages().carouselImg,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isActive = index == controller.carouselPage.value;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isActive ? orange : lightGray,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Reviews",
                style: TextStyle(
                  color: black,
                  fontSize: 16,
                  fontFamily: natoBold,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.reviewsScreen),
                child: const Text(
                  "View all",
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    fontFamily: natoRegular,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.reviewsList.length,
            itemBuilder: (context, index) {
              final review = controller.reviewsList[index];
              return Container(
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: cardShadow,
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                color: avatarTextColor,
                                fontSize: 14,
                                fontFamily: natoBold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          review.userName,
                          style: const TextStyle(
                            color: black,
                            fontSize: 15,
                            fontFamily: natoBold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          review.timeAgo,
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 13,
                            fontFamily: natoRegular,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        review.rating,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Image.asset(
                            AppImages().starIcon,
                            width: 15,
                            height: 15,
                            color: greenBadge,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.comment,
                      style: const TextStyle(
                        color: charcoalGray,
                        fontSize: 13.5,
                        fontFamily: natoRegular,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookTableButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: CustomButton(
        label: "Book a table",
        height: 45,
        width: double.infinity,
        onTap: () => Get.toNamed(Routes.bookTableScreen),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 10.0,
            bottom: 10.0,
          ),
          child: Text(
            "Address",
            style: TextStyle(color: black, fontSize: 16, fontFamily: natoBold),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: cardShadow,
                blurRadius: 8,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      AppImages().locationIcon,
                      width: 22,
                      height: 22,
                      color: charcoalGray,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Aditya Mehta, 28 Sunrise Apartments, Near Race Course Circle, Alipore, Kolkata 360001",
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13.5,
                          fontFamily: natoMedium,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                AppImages().mapImg,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpeningHoursSection() {
    final List<Map<String, dynamic>> schedules = [
      {
        "day": "Monday",
        "times": ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      },
      {
        "day": "Tuesday",
        "times": ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      },
      {
        "day": "Wednesday",
        "times": ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      },
      {
        "day": "Thursday",
        "times": ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      },
      {
        "day": "Friday",
        "times": ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      },
      {
        "day": "Saturday",
        "times": ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      },
      {
        "day": "Sunday",
        "times": ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text(
            "Opening Hours",
            style: TextStyle(color: black, fontSize: 16, fontFamily: natoBold),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: cardShadow,
                blurRadius: 8,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: schedules
                .map((s) => _buildOpeningHoursRow(s["day"], s["times"]))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOpeningHoursRow(String day, List<dynamic> times) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              day,
              style: const TextStyle(
                color: black,
                fontSize: 14,
                fontFamily: natoBold,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: times
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        t,
                        style: const TextStyle(
                          color: charcoalGray,
                          fontSize: 14,
                          fontFamily: natoRegular,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text(
            "Restaurant contact",
            style: TextStyle(color: black, fontSize: 16, fontFamily: natoBold),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: cardShadow,
                blurRadius: 8,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(
                AppImages().callIcon,
                width: 20,
                height: 20,
                color: charcoalGray,
              ),
              const SizedBox(width: 12),
              const Text(
                "09830158943",
                style: TextStyle(
                  color: black,
                  fontSize: 16,
                  fontFamily: natoMedium,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: orange,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text(
                    "Call",
                    style: TextStyle(
                      color: white,
                      fontSize: 14,
                      fontFamily: natoMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

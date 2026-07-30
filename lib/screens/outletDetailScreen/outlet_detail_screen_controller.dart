import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';

class OutletReview {
  final String userName;
  final String userInitial;
  final String timeAgo;
  final int rating;
  final String comment;

  OutletReview({
    required this.userName,
    required this.userInitial,
    required this.timeAgo,
    required this.rating,
    required this.comment,
  });
}

/// Data model representing opening hours for a day
class DayOpeningHours {
  final String day;
  final List<String> timeSlots;

  DayOpeningHours({required this.day, required this.timeSlots});
}

/// Bottom Sheet Widget displaying Outlet Opening Hours
class OpeningHoursBottomSheet extends StatelessWidget {
  final List<DayOpeningHours> openingHours;
  final VoidCallback? onClose;

  const OpeningHoursBottomSheet({
    super.key,
    required this.openingHours,
    this.onClose,
  });

  /// Helper static method to show the bottom sheet cleanly
  static Future<void> show(
    BuildContext context, {
    required List<DayOpeningHours> openingHours,
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
        return OpeningHoursBottomSheet(
          openingHours: openingHours,
          onClose: () {
            onClose?.call();
            Navigator.of(context).pop();
          },
        );
      },
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
          // Floating Circular Close Button positioned above the bottom sheet
          GestureDetector(
            onTap: onClose ?? () => Navigator.of(context).pop(),
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

          // Main White Bottom Sheet Container
          Flexible(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Text(
                        "Opening Hours",
                        style: TextStyle(
                          fontFamily: natoBold,
                          fontSize: 18,
                          color: black,
                        ),
                      ),
                    ),

                    // Header Bottom Line Divider
                    const Divider(height: 1, thickness: 1, color: borderGray),

                    // Scrollable List of Days and Time Slots
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: List.generate(openingHours.length, (index) {
                            final dayItem = openingHours[index];
                            final isLast = index == openingHours.length - 1;
                            return _buildDayRow(dayItem, showDivider: !isLast);
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single day timing row with divider
  Widget _buildDayRow(DayOpeningHours dayItem, {required bool showDivider}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Day Name Text
              Text(
                dayItem.day,
                style: const TextStyle(
                  fontFamily: natoBold,
                  fontSize: 16,
                  color: black,
                ),
              ),

              // Time Slots List
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dayItem.timeSlots.map((slot) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      slot,
                      style: const TextStyle(
                        fontFamily: natoRegular,
                        fontSize: 14.5,
                        color: black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: borderGray),
      ],
    );
  }
}

class OutletDetailScreenController extends GetxController {
  final outletName = "Chowman Gouribari".obs;
  final fullAddress =
      "Liitle russel st, Ho chi minhi sarashni roas,opp. Indiam Post office,kolkata Liitle russel st, Ho"
          .obs;
  final contactNumber = "09830158945".obs;
  final openingStatus = "Closed right now".obs;
  final openingHoursInfo = "Opens at 12:00 PM".obs;
  final reviews = <OutletReview>[].obs;
  final openingHoursList = <DayOpeningHours>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadOutletDetails();
  }

  void _loadOutletDetails() {
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
    ]);
    openingHoursList.assignAll([
      DayOpeningHours(
        day: "Monday",
        timeSlots: ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      ),
      DayOpeningHours(
        day: "Tuesday",
        timeSlots: ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      ),
      DayOpeningHours(
        day: "Wednesday",
        timeSlots: ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      ),
      DayOpeningHours(
        day: "Thursday",
        timeSlots: ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      ),
      DayOpeningHours(
        day: "Friday",
        timeSlots: ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      ),
      DayOpeningHours(
        day: "Saturday",
        timeSlots: ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      ),
      DayOpeningHours(
        day: "Sunday",
        timeSlots: ["12:30 PM - 12:45 PM", "12:30 PM - 12:45 PM"],
      ),
    ]);
  }

  void showOpeningHoursBottomSheet(BuildContext context) {
    OpeningHoursBottomSheet.show(context, openingHours: openingHoursList);
  }
}

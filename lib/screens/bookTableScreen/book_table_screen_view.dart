import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/bookTableScreen/book_table_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';

class BookTableScreen extends GetView<BookTableScreenController> {
  const BookTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: Container(
        color: white,
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          label: "Continue",
          height: 45,
          width: double.infinity,
          onTap: () => Get.toNamed(Routes.reviewBookingScreen),
        ),
      ),
      body: Obx(() {
        // Calculate the width of each dropdown to fit exactly below the field.
        final fieldWidth = (MediaQuery.of(context).size.width - 44) / 2;
        return Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              color: white,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 16,
              ),
              child: const Text(
                "Book a table",
                style: TextStyle(
                  color: black,
                  fontSize: 22,
                  fontFamily: natoBold,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: borderGray),

            // Scrollable Body Stack
            Expanded(
              child: Stack(
                children: [
                  // Main Scroll Content
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selectors Row (Date & Guests)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Date Selector
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    controller.isGuestDropdownOpen.value =
                                        false;
                                    controller.isDateDropdownOpen.toggle();
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: borderGray,
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          AppImages().calendarTodayIcon,
                                          width: 20,
                                          height: 20,
                                          color: charcoalGray,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            controller.selectedDate.value,
                                            style: const TextStyle(
                                              color: black,
                                              fontSize: 14,
                                              fontFamily: natoMedium,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Image.asset(
                                          AppImages().dropDownArrowIcon,
                                          width: 16,
                                          height: 16,
                                          color: charcoalGray,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Guest Selector
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    controller.isDateDropdownOpen.value = false;
                                    controller.isGuestDropdownOpen.toggle();
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: borderGray,
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          AppImages().guestIcon,
                                          width: 20,
                                          height: 20,
                                          color: charcoalGray,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "${controller.selectedGuests.value} guests",
                                            style: const TextStyle(
                                              color: black,
                                              fontSize: 14,
                                              fontFamily: natoMedium,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Image.asset(
                                          AppImages().dropDownArrowIcon,
                                          width: 16,
                                          height: 16,
                                          color: charcoalGray,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Select time of day Header
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Select time of day",
                            style: TextStyle(
                              color: charcoalGray,
                              fontSize: 14,
                              fontFamily: natoBold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Time Slot Selection Card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: cardShadow,
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Periods Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: controller.periodsList.map((period) {
                                  final isSelected =
                                      controller.selectedPeriod.value == period;
                                  return GestureDetector(
                                    onTap: () =>
                                        controller.selectPeriod(period),
                                    child: Container(
                                      width: 90,
                                      height: 38,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected
                                              ? orange
                                              : borderGray,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        period,
                                        style: TextStyle(
                                          color: isSelected ? orange : black,
                                          fontSize: 13.5,
                                          fontFamily: isSelected
                                              ? natoMedium
                                              : natoRegular,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const Divider(
                                height: 32,
                                thickness: 1,
                                color: borderGray,
                              ),

                              // Time Grid (2 rows of 3 columns)
                              Column(
                                children: [
                                  _buildTimeRow(0, 3),
                                  const SizedBox(height: 8),
                                  _buildTimeRow(3, 6),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Custom Date Dropdown Overlay List
                  if (controller.isDateDropdownOpen.value)
                    Positioned(
                      top: 64,
                      left: 16,
                      width: fieldWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderGray, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: cardShadow,
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: controller.datesList.map((date) {
                            final isSelected =
                                controller.selectedDate.value == date;
                            return GestureDetector(
                              onTap: () => controller.selectDate(date),
                              child: Container(
                                color: isSelected ? segmentedBg : white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                    color: black,
                                    fontSize: 14,
                                    fontFamily: natoMedium,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                  // Custom Guest Dropdown Overlay List
                  if (controller.isGuestDropdownOpen.value)
                    Positioned(
                      top: 64,
                      right: 16,
                      width: fieldWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderGray, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: cardShadow,
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: controller.guestsList.map((count) {
                            final isSelected =
                                controller.selectedGuests.value == count;
                            return GestureDetector(
                              onTap: () => controller.selectGuests(count),
                              child: Container(
                                color: isSelected ? segmentedBg : white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    color: black,
                                    fontSize: 14,
                                    fontFamily: natoMedium,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTimeRow(int startIndex, int endIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(endIndex - startIndex, (index) {
        final actualIndex = startIndex + index;
        if (actualIndex >= controller.timeSlots.length) {
          return const Expanded(child: SizedBox());
        }
        final isSelected = controller.selectedTimeIndex.value == actualIndex;
        final timeString = controller.timeSlots[actualIndex];

        return Expanded(
          child: GestureDetector(
            onTap: () {
              controller.selectedTimeIndex.value = actualIndex;
              controller.selectedTime.value = timeString;
            },
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 4,
                right: index == 2 ? 0 : 4,
              ),
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? orange : borderGray,
                  width: 1.5,
                ),
              ),
              child: Text(
                timeString,
                style: TextStyle(
                  color: isSelected ? orange : black,
                  fontSize: 13,
                  fontFamily: isSelected ? natoMedium : natoRegular,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/reviewBookingScreen/review_booking_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/widgets/custom_text_field.dart';

class ReviewBookingScreen extends GetView<ReviewBookingScreenController> {
  const ReviewBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        bottomNavigationBar: Container(
          color: white,
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            label: "Book a table",
            height: 45,
            width: double.infinity,
            onTap: () => controller.bookTable(),
          ),
        ),
        body: Column(
          children: [
            // Top Bar Header
            Container(
              width: double.infinity,
              color: white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Image.asset(
                      AppImages().backArrowIcon,
                      width: 20,
                      height: 20,
                      color: black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Review Booking Details",
                    style: TextStyle(
                      color: black,
                      fontSize: 20,
                      fontFamily: natoBold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: borderGray),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Booking Summary Card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16.0),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Time Slot Row
                          Row(
                            children: [
                              Image.asset(
                                AppImages().calendarTodayIcon,
                                width: 20,
                                height: 20,
                                color: charcoalGray,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                controller.bookingDateTime,
                                style: const TextStyle(
                                  color: black,
                                  fontSize: 15,
                                  fontFamily: natoBold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Guests Count Row
                          Row(
                            children: [
                              Image.asset(
                                AppImages().guestIcon,
                                width: 20,
                                height: 20,
                                color: charcoalGray,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                controller.guestCount,
                                style: const TextStyle(
                                  color: black,
                                  fontSize: 15,
                                  fontFamily: natoBold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Location Address Details Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                AppImages().locationIcon,
                                width: 20,
                                height: 20,
                                color: charcoalGray,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.restaurantName,
                                      style: const TextStyle(
                                        color: black,
                                        fontSize: 15,
                                        fontFamily: natoBold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.restaurantAddress,
                                      style: const TextStyle(
                                        color: textSecondary,
                                        fontSize: 13,
                                        fontFamily: natoRegular,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Special request Textfield
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: CustomTextField(
                        labelText: 'Add Special request',
                        hintText: "Add special request",
                        textEditingController:
                            controller.specialRequestController,
                        fillColor: white,
                      ),
                    ),

                    // Heading: Notes
                    const Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 5),
                      child: Text(
                        "Notes",
                        style: TextStyle(
                          color: black,
                          fontSize: 14,
                          fontFamily: natoMedium,
                        ),
                      ),
                    ),

                    // Static Notes Container View
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderGray, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: const Text(
                        "Cancellations made at least 2 hours before the reservation time are free of charge. Late cancellations or no-shows may incur a fee of ₹200 per guest.",
                        style: TextStyle(
                          color: charcoalGray,
                          fontSize: 13.5,
                          fontFamily: natoRegular,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

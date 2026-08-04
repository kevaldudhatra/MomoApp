import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/reservationStatusScreen/reservation_status_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';

class ReservationStatusScreen
    extends GetView<ReservationStatusScreenController> {
  const ReservationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservation = controller.reservation;

    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        body: Column(
          children: [
            // Header status banner
            Container(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
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
                    color: cardShadow,
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Image.asset(
                          AppImages().backArrowIcon,
                          width: 20,
                          height: 20,
                          color: white,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                reservation.restaurantName,
                                style: const TextStyle(
                                  color: white,
                                  fontSize: 18,
                                  fontFamily: natoBold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reservation.restaurantAddress,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: white,
                                  fontSize: 13,
                                  fontFamily: natoRegular,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "booking ${reservation.status}",
                    style: TextStyle(
                      color: white,
                      fontSize: 22,
                      fontFamily: natoBold,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Reservation Details Card
                    Container(
                      width: double.infinity,
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
                          // Scheduled Date & Time
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppImages().calendarTodayIcon,
                                width: 20,
                                height: 20,
                                color: charcoalGray,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                reservation.scheduledTime,
                                style: const TextStyle(
                                  color: black,
                                  fontSize: 15,
                                  fontFamily: natoMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Guests Count
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppImages().guestIcon,
                                width: 20,
                                height: 20,
                                color: charcoalGray,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "${reservation.guests} guests",
                                style: const TextStyle(
                                  color: black,
                                  fontSize: 15,
                                  fontFamily: natoMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Location / Address Details
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
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Momo I AM",
                                      style: TextStyle(
                                        color: black,
                                        fontSize: 15,
                                        fontFamily: natoMedium,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Aditya Mehta, 23 Sunrise Apartments, Yagnik...",
                                      style: TextStyle(
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
                          const Divider(
                            height: 24,
                            thickness: 1,
                            color: borderGray,
                          ),
                          const Text(
                            "Reach the restaurant 15 min before your slot starts",
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                              fontFamily: natoRegular,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Heading: Need Help
                    const Text(
                      "Need help with booking?",
                      style: TextStyle(
                        color: black,
                        fontSize: 15,
                        fontFamily: natoSemiBold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card 2: Need Help Card
                    Container(
                      width: double.infinity,
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
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  reservation.restaurantImage,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      AppImages().foodItemOne,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reservation.restaurantName,
                                      style: const TextStyle(
                                        color: black,
                                        fontSize: 15,
                                        fontFamily: natoBold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      reservation.restaurantAddress,
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
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // View Restaurant Button
                              Expanded(
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: borderGray,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      "View Restaurant",
                                      style: TextStyle(
                                        color: black,
                                        fontSize: 14,
                                        fontFamily: natoMedium,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Chat Icon
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: borderGray,
                                      width: 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    AppImages().chatIcon,
                                    width: 18,
                                    height: 18,
                                    color: charcoalGray,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Call Icon
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: orange,
                                  ),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    AppImages().callIcon,
                                    width: 18,
                                    height: 18,
                                    color: white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Heading: Feedback
                    const Text(
                      "Feedback Received",
                      style: TextStyle(
                        color: black,
                        fontSize: 15,
                        fontFamily: natoSemiBold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card 3: Feedback Card
                    Container(
                      width: double.infinity,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "YOU RATED",
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                              fontFamily: natoMedium,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: Image.asset(
                                  AppImages().starIcon,
                                  width: 24,
                                  height: 24,
                                  color: index < 4 ? greenBadge : lightGray,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "“Excellent food and ambiance!”",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: black,
                              fontSize: 14,
                              fontFamily: natoMedium,
                            ),
                          ),
                        ],
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

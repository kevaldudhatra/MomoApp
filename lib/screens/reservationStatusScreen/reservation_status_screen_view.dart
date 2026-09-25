import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/reservationStatusScreen/reservation_status_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/widgets/feedback_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservationStatusScreen
    extends GetView<ReservationStatusScreenController> {
  const ReservationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Obx(() {
          final reservation = controller.reservation;
          return Column(
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
                      "Booking ${reservation.status}",
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reservation.restaurantName,
                                        style: TextStyle(
                                          color: black,
                                          fontSize: 15,
                                          fontFamily: natoMedium,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        reservation.restaurantAddress,
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
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            child: Container(
                                              width: 44,
                                              height: 44,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        AppImages().momoImg,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                const SizedBox(width: 12),
                                InkWell(
                                  onTap: () async {
                                    final Uri uri = Uri(
                                      scheme: 'tel',
                                      path: "+91 ${reservation.phoneNumber}",
                                    );
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        'Unable to open phone dialer',
                                      );
                                    }
                                  },
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
                      const SizedBox(height: 30),

                      // Feedback Button
                      Center(
                        child: CustomButton(
                          height: 45,
                          width: MediaQuery.of(context).size.width * 0.60,
                          label: "Add Feedback",
                          fontSize: 14,
                          onTap: () {
                            FeedbackDialog.show(
                              context,
                              onSubmit: (rating, comment) async {
                                return await controller.addFeedback(
                                  rating: rating,
                                  comment: comment,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

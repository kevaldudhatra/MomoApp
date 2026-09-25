import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/screens/myReservationsScreen/my_reservations_screen_controller.dart';
import 'package:shimmer/shimmer.dart';

class MyReservationsScreen extends GetView<MyReservationsScreenController> {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Obx(() {
          final reservations = controller.filteredReservations;
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                // Header / App Bar
                Container(
                  width: double.infinity,
                  color: white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  margin: EdgeInsets.only(bottom: 15),
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
                        "Your Reservations",
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

                // Reservations Status Filter Tab Bar
                _buildTabBar(),

                // Reservations List
                Expanded(
                  child: controller.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(color: orange),
                        )
                      : controller.hasError.value && reservations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.errorMessage.value.isNotEmpty
                                    ? controller.errorMessage.value
                                    : "Failed to load reservations",
                                style: const TextStyle(
                                  color: textSecondary,
                                  fontSize: 15,
                                  fontFamily: natoMedium,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => controller.fetchReservations(
                                  page: 1,
                                  isRefresh: true,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Retry",
                                  style: TextStyle(
                                    color: white,
                                    fontFamily: natoMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : reservations.isEmpty
                      ? RefreshIndicator(
                          onRefresh: () => controller.fetchReservations(
                            page: 1,
                            isRefresh: true,
                          ),
                          color: orange,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.60,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                ),
                                child: Center(
                                  child: Text(
                                    "You have no reservations at the moment.",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: textSecondary,
                                      fontSize: 16,
                                      fontFamily: natoBold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => controller.fetchReservations(
                            page: 1,
                            isRefresh: true,
                          ),
                          color: orange,
                          child: ListView.builder(
                            controller: controller.scrollController,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount:
                                reservations.length +
                                (controller.isMoreLoading.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == reservations.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: orange,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return _buildReservationCard(reservations[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: white,
      height: 50,
      margin: const EdgeInsets.only(bottom: 15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: controller.statusOptions.map((status) {
            final isSelected = controller.selectedStatus.value == status;
            return GestureDetector(
              onTap: () => controller.selectedStatus.value = status,
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.only(right: 24),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 14),
                    Text(
                      status,
                      style: TextStyle(
                        color: isSelected ? orange : textSecondary,
                        fontSize: 15,
                        fontFamily: isSelected ? natoMedium : natoRegular,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 3,
                      width: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? orange : Colors.transparent,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReservationCard(ReservationModel reservation) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(Routes.reservationStatusScreen, arguments: reservation),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Restaurant Logo & Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      reservation.restaurantImage,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.restaurantName,
                          style: const TextStyle(
                            color: black,
                            fontSize: 16,
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
            ),

            const Divider(height: 1, thickness: 1, color: borderGray),

            // Middle Section: Booking Details Info Rows
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Booking ID", reservation.id),
                  _buildInfoRow("Guests", reservation.guests.toString()),
                  _buildInfoRow("Scheduled Time", reservation.scheduledTime),
                  _buildInfoRow("Placed Time", reservation.placedTime),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: borderGray),

            // Bottom Section: Placed Date, Status Badge
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Booking status",
                    style: TextStyle(
                      color: charcoalGray,
                      fontSize: 14,
                      fontFamily: natoRegular,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderGray, width: 1),
                    ),
                    child: Text(
                      '${reservation.status[0].toUpperCase()}${reservation.status.substring(1)}',
                      style: TextStyle(
                        color: reservation.status == 'pending'
                            ? charcoalGray
                            : reservation.status == 'confirmed'
                            ? blue
                            : reservation.status == 'completed'
                            ? greenBadge
                            : reservation.status == 'cancelled'
                            ? red
                            : charcoalGray,
                        fontSize: 13,
                        fontFamily: natoMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:  ",
            style: const TextStyle(
              color: charcoalGray,
              fontSize: 14,
              fontFamily: natoRegular,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: black,
                fontSize: 14,
                fontFamily: natoMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

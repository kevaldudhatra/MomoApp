import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/myOrdersScreen/my_orders_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/routes/app_pages.dart';

class MyOrdersScreen extends GetView<MyOrdersScreenController> {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        body: Obx(() {
          final orders = controller.filteredOrders;
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
                        "Your orders",
                        style: TextStyle(
                          color: black,
                          fontSize: 20,
                          fontFamily: natoBold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Order Status Filter Tab Bar
                _buildTabBar(),

                // Order List
                Expanded(
                  child: orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "No orders in '${controller.selectedStatus.value}'",
                                style: const TextStyle(
                                  color: textSecondary,
                                  fontSize: 16,
                                  fontFamily: natoMedium,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(orders[index]);
                          },
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
      margin: EdgeInsets.only(bottom: 15),
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

  Widget _buildOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.orderStatusScreen, arguments: order),
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
                      order.restaurantImage,
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
                          order.restaurantName,
                          style: const TextStyle(
                            color: black,
                            fontSize: 16,
                            fontFamily: natoBold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.restaurantAddress,
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

            // Middle Section: Items List
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                children: order.items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Image.asset(
                              item.isVeg
                                  ? AppImages().vegIcon
                                  : AppImages().nonVegIcon,
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${item.quantity}  x  ${item.name}",
                              style: const TextStyle(
                                color: black,
                                fontSize: 14,
                                fontFamily: natoRegular,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const Divider(height: 1, thickness: 1, color: borderGray),

            // Bottom Section: Placed Date, Status Badge, Price & Right Arrow
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side: placed date + status badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order placed on ${order.orderDate}",
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          fontFamily: natoRegular,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderGray, width: 1),
                        ),
                        child: Text(
                          order.status,
                          style: const TextStyle(
                            color: charcoalGray,
                            fontSize: 13,
                            fontFamily: natoMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Right side: Total price & Right arrow icon
                  Row(
                    children: [
                      Text(
                        "₹${order.totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: black,
                          fontSize: 15,
                          fontFamily: natoBold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        AppImages().rightArrowIcon,
                        width: 12,
                        height: 12,
                        color: charcoalGray,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

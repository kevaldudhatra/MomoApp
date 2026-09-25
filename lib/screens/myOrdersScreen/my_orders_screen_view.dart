import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/myOrdersScreen/my_orders_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:shimmer/shimmer.dart';

class MyOrdersScreen extends GetView<MyOrdersScreenController> {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Obx(() {
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
                const Divider(height: 1, thickness: 1, color: borderGray),

                // Order Status Filter Tab Bar
                _buildTabBar(),

                // Order List
                Expanded(
                  child: controller.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(color: orange),
                        )
                      : controller.hasError.value && orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.errorMessage.value.isNotEmpty
                                    ? controller.errorMessage.value
                                    : "Failed to load orders",
                                style: const TextStyle(
                                  color: textSecondary,
                                  fontSize: 15,
                                  fontFamily: natoMedium,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => controller.fetchOrders(
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
                      : orders.isEmpty
                      ? RefreshIndicator(
                          onRefresh: () =>
                              controller.fetchOrders(page: 1, isRefresh: true),
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
                                    controller.selectedStatus.value == "All"
                                        ? "You have no orders at the moment."
                                        : "No orders in '${controller.selectedStatus.value}'",
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
                          onRefresh: () =>
                              controller.fetchOrders(page: 1, isRefresh: true),
                          color: orange,
                          child: ListView.builder(
                            controller: controller.scrollController,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount:
                                orders.length +
                                (controller.isMoreLoading.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == orders.length) {
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
                              return _buildOrderCard(orders[index]);
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
      onTap: () => Get.toNamed(
        Routes.orderStatusScreen,
        arguments: {"orderId": order.id.toString()},
      ),
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
                            Expanded(
                              child: Text(
                                "${item.quantity}  x  ${item.name}",
                                style: const TextStyle(
                                  color: black,
                                  fontSize: 14,
                                  fontFamily: natoRegular,
                                ),
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
                          controller.formatStatus(order.status),
                          style: TextStyle(
                            color: order.status == 'placed'
                                ? charcoalGray
                                : order.status == 'accepted' ||
                                      order.status == 'preparing' ||
                                      order.status == 'ready' ||
                                      order.status == 'out_for_delivery'
                                ? blue
                                : order.status == 'delivered'
                                ? greenBadge
                                : order.status == 'cancelled'
                                ? red
                                : charcoalGray,
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

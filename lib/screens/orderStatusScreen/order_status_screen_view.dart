import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/orderStatusScreen/order_status_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';

class OrderStatusScreen extends GetView<OrderStatusScreenController> {
  const OrderStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = controller.order;
    final isMockOrder = order.id == "123456";
    final double itemTotalVal = isMockOrder ? 350.0 : order.totalAmount;
    final double couponDiscountVal = isMockOrder ? 20.0 : 0.0;
    final double packagingChargeVal = isMockOrder ? 20.0 : 15.0;
    final double cgstVal = isMockOrder ? 20.0 : (itemTotalVal * 0.025);
    final double sgstVal = isMockOrder ? 20.0 : (itemTotalVal * 0.025);
    final double finalTotalVal = isMockOrder
        ? 400.0
        : (itemTotalVal +
              packagingChargeVal +
              cgstVal +
              sgstVal -
              couponDiscountVal);

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
                          child: Text(
                            controller.order.restaurantName,
                            style: const TextStyle(
                              color: white,
                              fontSize: 18,
                              fontFamily: natoBold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Order is out for Delivery",
                    style: TextStyle(
                      color: white,
                      fontSize: 22,
                      fontFamily: natoBold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Your order will arrive in 20mins",
                    style: TextStyle(
                      color: white,
                      fontSize: 14,
                      fontFamily: natoRegular,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Cards List
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Card 1: Delivering to
                    _buildDeliveryCard(),
                    const SizedBox(height: 16),

                    // Card 2: Items Details
                    _buildItemsCard(context),
                    const SizedBox(height: 16),

                    // Card 3: Bill Details (Accordion)
                    _buildBillDetailsCard(
                      itemTotal: itemTotalVal,
                      couponDiscount: couponDiscountVal,
                      packagingCharge: packagingChargeVal,
                      cgst: cgstVal,
                      sgst: sgstVal,
                      finalTotal: finalTotalVal,
                    ),
                    const SizedBox(height: 16),

                    // Card 4: Payment Details
                    _buildPaymentCard(),
                    const SizedBox(height: 16),

                    // Card 5: Feedback Section
                    _buildFeedbackSection(),
                    const SizedBox(height: 16),

                    // Card 6: Download Invoice Button
                    _buildDownloadInvoiceButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
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
          // User Avater & Details Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: avatarBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "N",
                  style: TextStyle(
                    color: avatarTextColor,
                    fontSize: 16,
                    fontFamily: natoBold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Delivering to",
                    style: TextStyle(
                      color: black,
                      fontSize: 15,
                      fontFamily: natoBold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Neha, 963852740",
                    style: TextStyle(
                      color: charcoalGray,
                      fontSize: 13,
                      fontFamily: natoRegular,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: borderGray),
          // Delivery Address Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Image.asset(
                  AppImages().locationIcon,
                  width: 20,
                  height: 20,
                  color: charcoalGray,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Delivery at Home",
                      style: TextStyle(
                        color: black,
                        fontSize: 15,
                        fontFamily: natoBold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Liitle russel st, Ho chi minhi sarashni roas,opp. Indiam Post office,kolkata Liitle russel st, Ho",
                      style: TextStyle(
                        color: charcoalGray,
                        fontSize: 13,
                        fontFamily: natoRegular,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context) {
    final order = controller.order;
    final isMockOrder = order.id == "123456";
    return Container(
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
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant and Action Buttons
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: order.restaurantImage.isNotEmpty
                    ? Image.network(
                        order.restaurantImage,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              AppImages().menuItemOne,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                      )
                    : Image.asset(
                        AppImages().menuItemOne,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
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
                    const SizedBox(height: 4),
                    Text(
                      order.restaurantAddress,
                      style: const TextStyle(
                        color: charcoalGray,
                        fontSize: 13,
                        fontFamily: natoRegular,
                      ),
                    ),
                  ],
                ),
              ),
              // Chat Button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: chipBorder, width: 1),
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
              // Call Button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 36,
                  height: 36,
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
          const Divider(height: 24, thickness: 1, color: borderGray),

          // Order ID Row
          Row(
            children: [
              Image.asset(
                AppImages().billIcon,
                width: 20,
                height: 20,
                color: charcoalGray,
              ),
              const SizedBox(width: 10),
              Text(
                "OrderID #${order.id}",
                style: const TextStyle(
                  color: black,
                  fontSize: 15,
                  fontFamily: natoBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      item.isVeg ? AppImages().vegIcon : AppImages().nonVegIcon,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${item.quantity}  x  ${item.name}",
                            style: const TextStyle(
                              color: black,
                              fontSize: 14,
                              fontFamily: natoMedium,
                            ),
                          ),
                          if (index == 0 && isMockOrder)
                            const Text(
                              "Regular serves 1",
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                                fontFamily: natoRegular,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      "₹25.00",
                      style: const TextStyle(
                        color: black,
                        fontSize: 14,
                        fontFamily: natoRegular,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetailsCard({
    required double itemTotal,
    required double couponDiscount,
    required double packagingCharge,
    required double cgst,
    required double sgst,
    required double finalTotal,
  }) {
    return Container(
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
      child: Obx(() {
        final isExpanded = controller.isBillDetailsExpanded.value;
        return Column(
          children: [
            // Clickable Header for Accordion
            GestureDetector(
              onTap: () => controller.toggleBillDetails(),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bill Details",
                        style: TextStyle(
                          color: black,
                          fontSize: 16,
                          fontFamily: natoBold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Incl. taxes & Charges",
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                          fontFamily: natoRegular,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (!isExpanded)
                        Text(
                          "₹${finalTotal.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: black,
                            fontSize: 16,
                            fontFamily: natoBold,
                          ),
                        ),
                      const SizedBox(width: 10),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Image.asset(
                          AppImages().dropDownArrowIcon,
                          width: 25,
                          height: 25,
                          color: charcoalGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expanded accordion contents
            if (isExpanded) ...[
              const SizedBox(height: 16),
              _buildBillDetailRow(
                "Item Total",
                "₹${itemTotal.toStringAsFixed(0)}",
              ),
              const SizedBox(height: 10),
              _buildBillDetailRow(
                "Delivery Charge",
                "FREE",
                textStyle: const TextStyle(
                  color: greenFree,
                  fontSize: 14,
                  fontFamily: natoMedium,
                ),
              ),
              const SizedBox(height: 10),
              _buildBillDetailRow(
                "Coupon Discount",
                "₹${couponDiscount.toStringAsFixed(0)}",
              ),
              const SizedBox(height: 10),
              _buildBillDetailRow(
                "Packaging Charge",
                "₹${packagingCharge.toStringAsFixed(0)}",
              ),
              const SizedBox(height: 10),
              _buildBillDetailRow("CGST(2.5%)", "₹${cgst.toStringAsFixed(0)}"),
              const SizedBox(height: 10),
              _buildBillDetailRow("SGST(2.5%)", "₹${sgst.toStringAsFixed(0)}"),
              const Divider(height: 24, thickness: 1, color: borderGray),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(
                      color: black,
                      fontSize: 16,
                      fontFamily: natoBold,
                    ),
                  ),
                  Text(
                    "₹${finalTotal.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: black,
                      fontSize: 16,
                      fontFamily: natoBold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildBillDetailRow(
    String title,
    String value, {
    TextStyle? textStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: charcoalGray,
            fontSize: 14,
            fontFamily: natoRegular,
          ),
        ),
        Text(
          value,
          style:
              textStyle ??
              const TextStyle(
                color: black,
                fontSize: 14,
                fontFamily: natoRegular,
              ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard() {
    final order = controller.order;
    final isMockOrder = order.id == "123456";

    return Container(
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
          // Payment Method Row
          Row(
            children: [
              Image.asset(
                AppImages().paymentIcon,
                width: 22,
                height: 22,
                color: charcoalGray,
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Method",
                    style: TextStyle(
                      color: black,
                      fontSize: 15,
                      fontFamily: natoBold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Via Cash on delivery",
                    style: TextStyle(
                      color: charcoalGray,
                      fontSize: 13,
                      fontFamily: natoRegular,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: borderGray),
          // Payment Date Row
          Row(
            children: [
              Image.asset(
                AppImages().calenderIcon,
                width: 22,
                height: 22,
                color: charcoalGray,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payment Date",
                    style: TextStyle(
                      color: black,
                      fontSize: 15,
                      fontFamily: natoBold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMockOrder ? "Due" : order.orderDate,
                    style: const TextStyle(
                      color: charcoalGray,
                      fontSize: 13,
                      fontFamily: natoRegular,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Feedback Received",
          style: TextStyle(
            color: charcoalGray,
            fontSize: 14,
            fontFamily: natoSemiBold,
          ),
        ),
        const SizedBox(height: 8),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
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
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
    );
  }

  Widget _buildDownloadInvoiceButton() {
    return GestureDetector(
      onTap: () => controller.downloadInvoice(),
      child: Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.file_download_outlined,
              color: charcoalGray,
              size: 22,
            ),
            const SizedBox(width: 12),
            const Text(
              "Download Invoice",
              style: TextStyle(
                color: black,
                fontSize: 14,
                fontFamily: natoSemiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:momos/screens/orderStatusScreen/order_status_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/widgets/loading_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderStatusScreen extends GetView<OrderStatusScreenController> {
  const OrderStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        body: Obx(
          () => controller.isLoading.value
              ? SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: const LoadingDialog(),
                )
              : Column(
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
                                    controller.orderDetails['outlate']['name'],
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
                          Text(
                            "Order is ${controller.formatStatus(controller.orderDetails['orderStatus'])}",
                            style: TextStyle(
                              color: white,
                              fontSize: 22,
                              fontFamily: natoBold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          if (controller
                                  .orderDetails['estimatedDeliveryMinutes'] !=
                              null)
                            Text(
                              "Your order will arrive in ${controller.orderDetails['estimatedDeliveryMinutes']}mins",
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
                              itemTotal: double.parse(
                                controller.orderDetails['bill']['itemTotal']
                                    .toString(),
                              ),
                              couponDiscount: double.parse(
                                controller
                                    .orderDetails['bill']['discountAmount']
                                    .toString(),
                              ),
                              packagingCharge: double.parse(
                                controller
                                    .orderDetails['bill']['packagingCharge']
                                    .toString(),
                              ),
                              cgst: double.parse(
                                controller.orderDetails['bill']['cgstAmount']
                                    .toString(),
                              ),
                              sgst: double.parse(
                                controller.orderDetails['bill']['sgstAmount']
                                    .toString(),
                              ),
                              finalTotal: double.parse(
                                controller.orderDetails['bill']['grandTotal']
                                    .toString(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Card 4: Payment Details
                            _buildPaymentCard(),
                            const SizedBox(height: 16),

                            // Card 5: Download Invoice Button
                            _buildDownloadInvoiceButton(),
                            const SizedBox(height: 16),

                            // Card 6: Feedback Section
                            _buildFeedbackSection(context),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                child: Text(
                  controller.orderDetails['deliveringTo']['name']
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),
                  style: TextStyle(
                    color: avatarTextColor,
                    fontSize: 16,
                    fontFamily: natoBold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
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
                    "${controller.orderDetails['deliveringTo']['name']}, ${controller.orderDetails['deliveringTo']['countryCode']} ${controller.orderDetails['deliveringTo']['phoneNumber']}",
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Delivery at ${controller.orderDetails['address']['label']}",
                      style: TextStyle(
                        color: black,
                        fontSize: 15,
                        fontFamily: natoBold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      controller.orderDetails['address']['line'],
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
    final order = controller.orderDetails;
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
                child: Image.network(
                  order['outlate']['brandLogo'] ?? "",
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
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    AppImages().momoImg,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['outlate']['name'],
                      style: const TextStyle(
                        color: black,
                        fontSize: 16,
                        fontFamily: natoBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${order['outlate']['address']}, ${order['outlate']['city']}, ${order['outlate']['state']}",
                      style: const TextStyle(
                        color: charcoalGray,
                        fontSize: 13,
                        fontFamily: natoRegular,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final Uri uri = Uri(
                    scheme: 'tel',
                    path:
                        "+91 ${controller.orderDetails['outlate']['phoneNo']}",
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    Get.snackbar('Error', 'Unable to open phone dialer');
                  }
                },
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
                "OrderID #${order['orderNumber']}",
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
            itemCount: order['items'].length,
            itemBuilder: (context, index) {
              final item = order['items'][index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      item['itemType'] == 1
                          ? AppImages().vegIcon
                          : AppImages().nonVegIcon,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${item['quantity']}  x  ${item['itemName']}",
                            style: const TextStyle(
                              color: black,
                              fontSize: 14,
                              fontFamily: natoMedium,
                            ),
                          ),
                          if (item['modifiers'].length > 0)
                            ...item['modifiers'].map((e) {
                              return Text(
                                e['optionName'],
                                style: const TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                  fontFamily: natoRegular,
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    Text(
                      "₹${item['lineTotal'].toStringAsFixed(2)}",
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
      child: Column(
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
                    if (!controller.isBillDetailsExpanded.value)
                      Text(
                        "₹${finalTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: black,
                          fontSize: 16,
                          fontFamily: natoBold,
                        ),
                      ),
                    const SizedBox(width: 10),
                    AnimatedRotation(
                      turns: controller.isBillDetailsExpanded.value ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
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
          if (controller.isBillDetailsExpanded.value) ...[
            const SizedBox(height: 16),
            _buildBillDetailRow(
              "Item Total",
              "₹${itemTotal.toStringAsFixed(2)}",
            ),
            const SizedBox(height: 10),
            _buildBillDetailRow(
              "Delivery Charge",
              "FREE",
              textStyle: const TextStyle(
                color: greenBadge,
                fontSize: 14,
                fontFamily: natoMedium,
              ),
            ),
            const SizedBox(height: 10),
            _buildBillDetailRow(
              "Coupon Discount",
              "₹${couponDiscount.toStringAsFixed(2)}",
            ),
            const SizedBox(height: 10),
            _buildBillDetailRow(
              "Packaging Charge",
              "₹${packagingCharge.toStringAsFixed(2)}",
            ),
            const SizedBox(height: 10),
            _buildBillDetailRow("CGST(2.5%)", "₹${cgst.toStringAsFixed(2)}"),
            const SizedBox(height: 10),
            _buildBillDetailRow("SGST(2.5%)", "₹${sgst.toStringAsFixed(2)}"),
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
                  "₹${finalTotal.toStringAsFixed(2)}",
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
      ),
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
    final order = controller.orderDetails;
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
              Column(
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
                    "${order['paymentMethod']}",
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
                    DateFormat('dd MMM, hh:mm a').format(
                      DateTime.parse(order['placedAt'].toString()).toLocal(),
                    ),
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

  Widget _buildFeedbackSection(BuildContext context) {
    return Center(
      child: CustomButton(
        height: 45,
        width: MediaQuery.of(context).size.width * 0.40,
        label: "Add Feedback",
        fontSize: 14,
        onTap: () {},
      ),
    );
  }
}

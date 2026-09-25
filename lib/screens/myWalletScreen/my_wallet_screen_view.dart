import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/myWalletScreen/my_wallet_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';

class MyWalletScreen extends GetView<MyWalletScreenController> {
  const MyWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Header / App Bar
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
                    "My Wallet",
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

            // Scrollable Content
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
                    // Current Balance Card
                    Obx(
                      () => Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: cardShadow,
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Current Balance",
                                      style: TextStyle(
                                        color: black,
                                        fontSize: 14,
                                        fontFamily: natoSemiBold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "₹${controller.balance.value.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: black,
                                        fontSize: 32,
                                        fontFamily: natoBold,
                                      ),
                                    ),
                                  ],
                                ),
                                Image.asset(
                                  AppImages().walletIcon,
                                  width: 44,
                                  height: 44,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              height: 45,
                              width: double.infinity,
                              label: "Add Money",
                              onTap: () {
                                Get.toNamed(Routes.addMoneyScreen);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Subheading
                    const Text(
                      "Transaction History",
                      style: TextStyle(
                        color: charcoalGray,
                        fontSize: 16,
                        fontFamily: natoMedium,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Transaction List
                    Obx(
                      () => ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.transactions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final tx = controller.transactions[index];
                          return Container(
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon (Up/Down arrow)
                                Image.asset(
                                  tx.isTopup
                                      ? AppImages().upIcon
                                      : AppImages().downIcon,
                                  width: 20,
                                  height: 20,
                                  color: tx.isTopup ? greenBadge : orange,
                                ),
                                const SizedBox(width: 12),

                                // Transaction Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.title,
                                        style: const TextStyle(
                                          color: black,
                                          fontSize: 15,
                                          fontFamily: natoSemiBold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tx.subtitle,
                                        style: const TextStyle(
                                          color: textSecondary,
                                          fontSize: 13,
                                          fontFamily: natoMedium,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        tx.dateTime,
                                        style: const TextStyle(
                                          color: textSecondary,
                                          fontSize: 12,
                                          fontFamily: natoMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Transaction Amount
                                Text(
                                  tx.isTopup
                                      ? "₹${tx.amount.toStringAsFixed(0)}"
                                      : "-₹${tx.amount.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    color: tx.isTopup ? greenBadge : orange,
                                    fontSize: 16,
                                    fontFamily: natoBold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/offersScreen/offers_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/loading_view.dart';

class OffersScreen extends GetView<OffersScreenController> {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        body: Column(
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
                    "Offers",
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

            // Offers List
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(child: LoadingDialog())
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        itemCount: controller.offers.length,
                        itemBuilder: (context, index) {
                          final offer = controller.offers[index];
                          return _buildOfferCard(offer);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Single Offer Card
  Widget _buildOfferCard(Offer offer) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 16),
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
          children: [
            // Card Header
            GestureDetector(
              onTap: () => controller.toggleAccordion(offer),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Faded or active Gift Icon
                    Opacity(
                      opacity: offer.isActive ? 1.0 : 0.4,
                      child: Image.asset(
                        AppImages().giftIcon,
                        width: 35,
                        height: 35,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.title,
                            style: TextStyle(
                              color: offer.isActive ? black : textDisabled,
                              fontSize: 16,
                              fontFamily: natoBold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            offer.subtitle,
                            style: TextStyle(
                              color: offer.isActive
                                  ? charcoalGray
                                  : textDisabled,
                              fontSize: 12,
                              fontFamily: natoRegular,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Accordion Arrow Icon
                    AnimatedRotation(
                      turns: offer.isExpanded.value ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Image.asset(
                        AppImages().dropDownArrowIcon,
                        width: 25,
                        height: 25,
                        color: offer.isActive ? black : textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable details (Accordion)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: offer.bullets.isNotEmpty
                  ? Column(
                      children: [
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: borderGray,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            top: 12.0,
                            bottom: 6.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: offer.bullets.map((bullet) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "• ",
                                      style: TextStyle(
                                        color: offer.isActive
                                            ? charcoalGray
                                            : textDisabled,
                                        fontSize: 13,
                                        fontFamily: natoRegular,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        bullet,
                                        style: TextStyle(
                                          color: offer.isActive
                                              ? charcoalGray
                                              : textDisabled,
                                          fontSize: 12,
                                          fontFamily: natoRegular,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              crossFadeState: offer.isExpanded.value
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),

            // Divider and Apply Button
            const Divider(height: 1, thickness: 1, color: borderGray),
            GestureDetector(
              onTap: () => controller.applyOffer(offer),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                color: Colors.transparent,
                child: Text(
                  "Apply",
                  style: TextStyle(
                    color: offer.isActive ? orange : orangeDisabled,
                    fontSize: 16,
                    fontFamily: natoBold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

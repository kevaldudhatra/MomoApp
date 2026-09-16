import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/faqScreen/faq_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/loading_view.dart';

class FAQScreen extends GetView<FaqScreenController> {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
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
                    "FAQ",
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

            // FAQ Accordion List
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: const Center(child: LoadingDialog()),
                      )
                    : controller.faqList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Text(
                            "No Data Found",
                            style: TextStyle(
                              fontFamily: natoMedium,
                              fontSize: 15,
                              color: sectionHeaderColor,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        itemCount: controller.faqList.length,
                        itemBuilder: (context, index) {
                          final item = controller.faqList[index];
                          return _buildFaqCard(item);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCard(FAQItem item) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Accordion Header
          GestureDetector(
            onTap: () => controller.toggleFaq(item),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.question,
                      style: const TextStyle(
                        color: black,
                        fontSize: 15,
                        fontFamily: natoBold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: item.isExpanded.value ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Image.asset(
                      AppImages().dropDownArrowIcon,
                      width: 25,
                      height: 25,
                      color: black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Answer Block (Visible when expanded)
          if (item.isExpanded.value) ...[
            const Divider(height: 1, thickness: 1, color: borderGray),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                item.answer,
                style: const TextStyle(
                  color: charcoalGray,
                  fontSize: 13,
                  fontFamily: natoRegular,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/aboutUsScreen/about_us_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';

class AboutUsScreen extends GetView<AboutUsScreenController> {
  const AboutUsScreen({super.key});

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
                    "About Us",
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

            // Content Area with Options Card
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                child: Column(
                  children: [
                    // Terms & Conditions Option
                    _buildOptionItem(
                      iconPath: AppImages().termsIcon,
                      title: "Terms & Conditions",
                      onTap: () => controller.navigateToTerms(),
                    ),

                    const Divider(height: 1, thickness: 1, color: borderGray),

                    // Privacy Policy Option
                    _buildOptionItem(
                      iconPath: AppImages().privacyIcon,
                      title: "Privacy Policy",
                      onTap: () => controller.navigateToPrivacy(),
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

  Widget _buildOptionItem({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Image.asset(iconPath, width: 22, height: 22, color: charcoalGray),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: black,
                  fontSize: 15,
                  fontFamily: natoMedium,
                ),
              ),
            ),
            Image.asset(
              AppImages().rightArrowIcon,
              width: 12,
              height: 12,
              color: charcoalGray,
            ),
          ],
        ),
      ),
    );
  }
}

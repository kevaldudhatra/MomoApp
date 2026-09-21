import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/screens/privacyAndTermsScreen/privacy_and_terms_screen_controller.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/loading_view.dart';

class PrivacyAndTermsScreen extends GetView<PrivacyAndTermsScreenController> {
  const PrivacyAndTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        body: Obx(
          () => Column(
            children: [
              // Top Bar Header
              Container(
                width: double.infinity,
                color: white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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
                    Text(
                      controller.isPrivacy.value
                          ? "Privacy Policy"
                          : controller.isTerms.value
                          ? "Terms and Conditions"
                          : "Refund Policy",
                      style: const TextStyle(
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
                child: controller.isLoading.value
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: const Center(child: LoadingDialog()),
                      )
                    : controller.privacyAndTerms.isEmpty
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
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Html(
                          data: HtmlUnescape().convert(
                            controller.privacyAndTerms.value,
                          ),
                          style: {
                            "body": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                            ),
                            "h1": Style(
                              fontSize: FontSize(22),
                              fontWeight: FontWeight.bold,
                              margin: Margins.only(top: 12, bottom: 6),
                              padding: HtmlPaddings.zero,
                            ),
                            "h2": Style(
                              fontSize: FontSize(17),
                              fontWeight: FontWeight.bold,
                              margin: Margins.only(top: 10, bottom: 4),
                              padding: HtmlPaddings.zero,
                            ),
                            "p": Style(
                              fontSize: FontSize(15),
                              lineHeight: LineHeight.number(1.3),
                              margin: Margins.only(bottom: 6),
                              padding: HtmlPaddings.zero,
                            ),
                            "li": Style(
                              fontSize: FontSize(15),
                              lineHeight: LineHeight.number(1.3),
                              margin: Margins.only(bottom: 4),
                              padding: HtmlPaddings.zero,
                            ),
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

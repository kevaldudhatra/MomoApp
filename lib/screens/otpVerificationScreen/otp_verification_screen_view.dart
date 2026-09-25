import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/otpVerificationScreen/otp_verification_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';

class OtpVerificationScreen extends GetView<OtpVerificationScreenController> {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            controller.focusNode.unfocus();
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Center(
                child: Image.asset(
                  AppImages().headerBgImg,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    image: DecorationImage(
                      image: AssetImage(AppImages().fullBgImg),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Obx(
                        () => Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 30),
                            const Text(
                              "Verify Phone Number",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: black,
                                fontSize: 24,
                                fontFamily: natoSemiBold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Please enter 6 digit code sent to your Phone number.",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: charcoalGray,
                                fontSize: 14,
                                fontFamily: natoRegular,
                              ),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              height: 48,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned.fill(
                                    child: Opacity(
                                      opacity: 0,
                                      child: TextField(
                                        controller: controller.otpController,
                                        focusNode: controller.focusNode,
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                        showCursor: false,
                                        enableInteractiveSelection: false,
                                        decoration: const InputDecoration(
                                          counterText: "",
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      controller.focusNode.requestFocus();
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: List.generate(6, (index) {
                                        final String char =
                                            index <
                                                controller.otpCode.value.length
                                            ? controller.otpCode.value[index]
                                            : "-";
                                        final bool isFocused =
                                            controller.isOtpFocused.value &&
                                            controller
                                                .otpCode
                                                .value
                                                .isNotEmpty &&
                                            controller.otpCode.value.length <
                                                6 &&
                                            index ==
                                                controller
                                                        .otpCode
                                                        .value
                                                        .length -
                                                    1;
                                        return Container(
                                          height: 48,
                                          width: 45,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: isFocused
                                                  ? orange
                                                  : lightGray,
                                              width: isFocused ? 1.5 : 0.5,
                                            ),
                                          ),
                                          child: Text(
                                            char,
                                            style: TextStyle(
                                              color: char == "-"
                                                  ? lightGray
                                                  : black,
                                              fontSize: 18,
                                              fontFamily: char == "-"
                                                  ? natoRegular
                                                  : natoSemiBold,
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            CustomButton(
                              width: MediaQuery.of(context).size.width,
                              label: "Continue",
                              isEnabled: controller.otpCode.value.length == 6,
                              onTap: () {
                                if (controller.otpCode.value.length == 6) {
                                  controller.otpVerification();
                                }
                              },
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Didn't get code?",
                                  style: TextStyle(
                                    color: charcoalGray,
                                    fontSize: 14,
                                    fontFamily: natoRegular,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    controller.otpController.clear();
                                    controller.focusNode.unfocus();
                                    await controller.resendOtp();
                                  },
                                  child: const Text(
                                    "Resend",
                                    style: TextStyle(
                                      color: blue,
                                      fontSize: 14,
                                      fontFamily: natoSemiBold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
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

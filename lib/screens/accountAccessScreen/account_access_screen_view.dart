import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/screens/accountAccessScreen/account_access_screen_controller.dart';

class AccountAccessScreen extends GetView<AccountAccessScreenController> {
  const AccountAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
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
                            Text(
                              controller.isLogin.value
                                  ? "Welcome Back!"
                                  : "Create an Account",
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                color: black,
                                fontSize: 24,
                                fontFamily: natoSemiBold,
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              "Phone Number",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: charcoalGray,
                                fontSize: 15,
                                fontFamily: natoSemiBold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: white,
                                    border: Border.all(color: lightGray),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "🇮🇳",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        height: 18,
                                        width: 1,
                                        color: lightGray,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "+91",
                                        style: TextStyle(
                                          color: black,
                                          fontSize: 16,
                                          fontFamily: natoRegular,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: TextField(
                                      controller: controller.currentNumber,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      cursorColor: black,
                                      cursorHeight: 18,
                                      style: const TextStyle(
                                        color: black,
                                        fontSize: 16.0,
                                        fontFamily: natoRegular,
                                      ),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 10.0,
                                          horizontal: 15.0,
                                        ),
                                        filled: true,
                                        hintText: "Enter your phone number",
                                        hintStyle: TextStyle(
                                          color: lightGray,
                                          fontFamily: natoRegular,
                                          fontSize: 16.0,
                                        ),
                                        fillColor: white,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: lightGray,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: lightGray,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            CustomButton(
                              width: MediaQuery.of(context).size.width,
                              label: "Get OTP",
                              isEnabled:
                                  controller.phoneNumber.value.length == 10,
                              onTap: () {
                                if (controller.phoneNumber.value.length == 10) {
                                  controller.userRegisterOrLoginUsingPhone();
                                }
                              },
                            ),
                            const SizedBox(height: 35),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(height: 1, color: lightGray),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Text(
                                    controller.isLogin.value
                                        ? "or log in with"
                                        : "or sign up with",
                                    style: const TextStyle(
                                      color: charcoalGray,
                                      fontSize: 14,
                                      fontFamily: natoRegular,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(height: 1, color: lightGray),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            GestureDetector(
                              onTap: () async {
                                final google = GoogleAuthService();
                                await google.initialize();
                                await google.signInWithGoogle(
                                  isLogin: controller.isLogin.value,
                                );
                              },
                              child: Container(
                                height: 48,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: white,
                                  border: Border.all(color: lightGray),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages().googleIcon,
                                      height: 24,
                                      width: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Continue with google",
                                      style: TextStyle(
                                        color: charcoalGray,
                                        fontSize: 16,
                                        fontFamily: natoRegular,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            GestureDetector(
                              onTap: () {
                                if (controller.isLogin.value) {
                                  Get.toNamed(Routes.loginScreen);
                                } else {
                                  Get.toNamed(Routes.createAccountScreen);
                                }
                              },
                              child: Container(
                                height: 48,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: white,
                                  border: Border.all(color: lightGray),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages().emailIcon,
                                      height: 24,
                                      width: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Continue with Email",
                                      style: TextStyle(
                                        color: charcoalGray,
                                        fontSize: 16,
                                        fontFamily: natoRegular,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text.rich(
                              TextSpan(
                                text: "I agree to momo i am's ",
                                style: const TextStyle(
                                  color: charcoalGray,
                                  fontSize: 14,
                                  fontFamily: dmRegular,
                                  height: 1.4,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Terms & Conditions",
                                    style: const TextStyle(
                                      color: blue,
                                      fontFamily: dmRegular,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Get.toNamed(
                                          Routes.privacyAndTermsScreen,
                                          arguments: {"isTerms": true},
                                        );
                                      },
                                  ),
                                  const TextSpan(text: " and acknowledge the "),
                                  TextSpan(
                                    text: "Privacy Policy.",
                                    style: const TextStyle(
                                      color: blue,
                                      fontFamily: dmRegular,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Get.toNamed(
                                          Routes.privacyAndTermsScreen,
                                          arguments: {"isPrivacy": true},
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  controller.toggleLogin();
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text: controller.isLogin.value
                                        ? "Don't have an account? "
                                        : "Already have an account? ",
                                    style: const TextStyle(
                                      color: charcoalGray,
                                      fontSize: 14,
                                      fontFamily: natoRegular,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: controller.isLogin.value
                                            ? "Sign Up"
                                            : "Log In",
                                        style: const TextStyle(
                                          color: blue,
                                          fontFamily: natoSemiBold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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

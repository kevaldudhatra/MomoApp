import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/forgotPasswordScreen/forgot_password_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordScreenController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
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
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 30),
                            const Text(
                              "Forgot Password",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: black,
                                fontSize: 24,
                                fontFamily: natoSemiBold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Please enter your email to reset the password",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: charcoalGray,
                                fontSize: 14,
                                fontFamily: natoRegular,
                              ),
                            ),
                            const SizedBox(height: 35),
                            CustomTextField(
                              labelText: "Email",
                              hintText: "Enter your email address",
                              textEditingController: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 30),
                            CustomButton(
                              width: MediaQuery.of(context).size.width,
                              label: "Continue",
                              onTap: () {
                                controller.verifyEmail();
                              },
                            ),
                            const SizedBox(height: 30),
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

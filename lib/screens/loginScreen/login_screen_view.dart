import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/loginScreen/login_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/widgets/custom_text_field.dart';

class LoginScreen extends GetView<LoginScreenController> {
  const LoginScreen({super.key});

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
                        child: Obx(
                          () => Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 30),
                              const Text(
                                "Welcome Back!",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: black,
                                  fontSize: 24,
                                  fontFamily: natoSemiBold,
                                ),
                              ),
                              const SizedBox(height: 30),
                              CustomTextField(
                                labelText: "Email",
                                hintText: "Enter your email address",
                                textEditingController:
                                    controller.emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                labelText: "Password",
                                hintText: "Enter password",
                                textEditingController:
                                    controller.passwordController,
                                obscureText: controller.obscurePassword.value,
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    controller.togglePasswordVisibility();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: 15,
                                      left: 5,
                                    ),
                                    child: Icon(
                                      controller.obscurePassword.value
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: charcoalGray,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed(Routes.forgotPasswordScreen);
                                  },
                                  child: const Text(
                                    "Forgot Password ?",
                                    style: TextStyle(
                                      color: blue,
                                      fontSize: 14,
                                      fontFamily: dmRegular,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 35),
                              CustomButton(
                                width: MediaQuery.of(context).size.width,
                                label: "Continue",
                                onTap: () {
                                  controller.userLogin();
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

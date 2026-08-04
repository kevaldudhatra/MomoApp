import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/widgets/custom_text_field.dart';
import 'package:momos/screens/changePasswordScreen/change_password_screen_controller.dart';

class ChangePasswordScreen extends GetView<ChangePasswordScreenController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              // Header / App Bar
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
                    const Text(
                      "Change Password",
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

              // Scrollable Inputs Section
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 24.0,
                    ),
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current Password Field
                          CustomTextField(
                            labelText: "Current Password",
                            hintText: "Enter password",
                            maxLine: 1,
                            textEditingController:
                                controller.currentPasswordController,
                            obscureText:
                                controller.obscureCurrentPassword.value,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.next,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                controller.toggleCurrentPasswordVisibility();
                              },
                              child: Icon(
                                controller.obscureCurrentPassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: charcoalGray,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // New Password Field
                          CustomTextField(
                            labelText: "New Password",
                            hintText: "Enter password",
                            maxLine: 1,
                            textEditingController:
                                controller.newPasswordController,
                            obscureText: controller.obscureNewPassword.value,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                controller.toggleNewPasswordVisibility();
                              },
                              child: Icon(
                                controller.obscureNewPassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: charcoalGray,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Save Button
                          CustomButton(
                            width: double.infinity,
                            label: "Save",
                            onTap: () {
                              controller.savePassword();
                            },
                          ),
                        ],
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

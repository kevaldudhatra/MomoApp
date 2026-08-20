import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/widgets/custom_text_field.dart';
import 'package:momos/screens/editProfileScreen/edit_profile_screen_controller.dart';

class EditProfileScreen extends GetView<EditProfileScreenController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: white,
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
                      "Edit profile",
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
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar Image Section
                      Center(
                        child: Stack(
                          children: [
                            // Circular Profile Photo
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: cardShadow,
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: NetworkImage(
                                    controller.avatarUrl.value,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Overlay Camera/Edit badge
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: cardShadow,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    AppImages().editIcon,
                                    width: 16,
                                    height: 16,
                                    color: charcoalGray,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // First Name Input
                      CustomTextField(
                        labelText: "First Name",
                        hintText: "Enter first name",
                        textEditingController: controller.firstNameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 20),

                      // Email Input (Read-only)
                      CustomTextField(
                        labelText: "Email",
                        hintText: "Enter email",
                        textEditingController: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        readOnly: true,
                        fillColor: background,
                      ),
                      const SizedBox(height: 20),

                      // Phone Number Input (Read-only)
                      controller.userData['loginType'] == 'phone'
                          ? Column(
                              children: [
                                CustomTextField(
                                  labelText: "Phone Number",
                                  hintText: "Enter phone number",
                                  textEditingController:
                                      controller.phoneController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  readOnly: true,
                                  fillColor: background,
                                ),
                                const SizedBox(height: 20),
                              ],
                            )
                          : Container(),

                      // Change Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.changePasswordScreen);
                          },
                          child: const Text(
                            "Change Password ?",
                            style: TextStyle(
                              color: orange,
                              fontSize: 14,
                              fontFamily: natoMedium,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Save Changes Button
                      CustomButton(
                        width: double.infinity,
                        label: "Save Changes",
                        onTap: () => controller.saveChanges(),
                      ),
                    ],
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/completeYourProfileScreen/complete_your_profile_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/widgets/custom_text_field.dart';

class CompleteYourProfileScreen
    extends GetView<CompleteYourProfileScreenController> {
  const CompleteYourProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: white,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 30),
                          const Text(
                            "Complete your profile",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: black,
                              fontSize: 24,
                              fontFamily: natoBold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Please enter the details below to complete your profile",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: charcoalGray,
                              fontSize: 14,
                              fontFamily: natoRegular,
                            ),
                          ),
                          const SizedBox(height: 25),
                          CustomTextField(
                            labelText: "Full Name",
                            hintText: "Enter your name",
                            textEditingController:
                                controller.fullNameController,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            labelText: "Email",
                            hintText: "Enter your email address",
                            textEditingController: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 35),
                          CustomButton(
                            width: MediaQuery.of(context).size.width,
                            label: "Continue",
                            onTap: () {
                              controller.submitProfile();
                            },
                          ),
                          const SizedBox(height: 30),
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

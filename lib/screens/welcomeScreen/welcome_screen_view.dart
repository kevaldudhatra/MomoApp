import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:momos/widgets/custom_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final storage = GetStorage();

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (storage.hasData(loginTrue) && storage.read(loginTrue) == true) {
        print("User Token => ${storage.read(userToken)}");
        Get.offAllNamed(Routes.homeScreen);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Center(
              child: Image.asset(
                AppImages().splashImg,
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            storage.hasData(loginTrue) && storage.read(loginTrue) == true
                ? Container()
                : Positioned(
                    bottom: 50,
                    child: CustomButton(
                      width: MediaQuery.of(context).size.width - 100,
                      label: "Get Started",
                      onTap: () {
                        Get.offAllNamed(Routes.startScreen);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

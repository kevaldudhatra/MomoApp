import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: white,
        body: Scaffold(
          backgroundColor: white,
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              Center(
                child: Image.asset(
                  AppImages().welcomeImg,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    image: DecorationImage(image: AssetImage(AppImages().halfBgImg), fit: BoxFit.cover),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Welcome to ',
                              style: TextStyle(color: black, fontSize: 26, fontFamily: natoSemiBold),
                            ),
                            TextSpan(
                              text: 'Momo I am',
                              style: TextStyle(color: orange, fontSize: 26, fontFamily: natoSemiBold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Steaming hot, made fresh, delivered\nwith care",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: charcoalGray, fontSize: 14, fontFamily: natoRegular),
                      ),
                      SizedBox(height: 50),
                      CustomButton(
                        width: MediaQuery.of(context).size.width - 100,
                        label: "Create an Account",
                        onTap: () {
                          Get.toNamed(Routes.accountAccessScreen, arguments: {"forLogin": false});
                        },
                      ),
                      SizedBox(height: 20),
                      CustomButton(
                        width: MediaQuery.of(context).size.width - 100,
                        isEnabled: false,
                        label: "Login",
                        onTap: () {
                          Get.toNamed(Routes.accountAccessScreen, arguments: {"forLogin": true});
                        },
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

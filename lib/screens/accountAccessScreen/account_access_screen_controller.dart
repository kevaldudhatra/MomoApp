import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/network/env.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/network/socket_service.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:momos/widgets/loading_view.dart';
import 'package:http/http.dart' as http;

class GoogleAuthService {
  final storage = GetStorage();

  GoogleAuthService();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> initialize() async {
    await _googleSignIn.initialize(serverClientId: googleServerClientID);
  }

  Future<void> signInWithGoogle({required bool isLogin}) async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      print("Email: ${account.email}");
      print("Display Name: ${account.displayName}");
      print("User ID: ${account.id}");
      Get.dialog(const LoadingDialog(), barrierDismissible: false);
      var response = await http.post(
        Uri.parse(isLogin ? ApiServices.login : ApiServices.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          isLogin
              ? {
                  "email": account.email,
                  "googleToken": account.id,
                  "loginType": "google",
                }
              : {
                  "email": account.email,
                  "name": account.displayName,
                  "googleToken": account.id,
                  "loginType": "google",
                },
        ),
      );
      print('signInWithGoogle Response status: ${response.statusCode}');
      print('signInWithGoogle Response body: ${response.body}');
      if (Get.isDialogOpen!) {
        Get.back();
      }
      var data = jsonDecode(response.body);
      print("Google Data => $data");
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["success"] == true) {
        Get.snackbar(
          "Success",
          data["message"],
          icon: const Icon(Icons.done, color: Colors.green),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
        await storage.write(loginTrue, true);
        final token = "Bearer ${data["data"]["token"]}";
        await storage.write(userToken, token);
        SocketService().connect(userToken: data["data"]["token"]);
        Get.offAllNamed(Routes.homeScreen);
      } else {
        Get.snackbar(
          "Oops!",
          data["message"],
          icon: const Icon(Icons.error, color: Colors.red),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
      }
    } on Exception catch (e) {
      print('Google Sign-In exception: $e');
      Get.snackbar(
        "Oops!",
        "Unable to sign in with Google. Please try again later.",
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
    }
  }

  Future<void> signOutWithGoogle() async {
    await _googleSignIn.signOut();
  }
}

class AccountAccessScreenController extends GetxController {
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  final currentNumber = TextEditingController();
  final RxBool isLogin = false.obs;
  final RxString phoneNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    isLogin.value = Get.arguments?['forLogin'] ?? false;
    currentNumber.addListener(() {
      phoneNumber.value = currentNumber.text;
    });
  }

  @override
  void onClose() {
    currentNumber.dispose();
    super.onClose();
  }

  void toggleLogin() {
    isLogin.value = !isLogin.value;
  }

  Future<dynamic> userRegisterOrLoginUsingPhone() async {
    print(
      "userRegisterOrLoginUsingPhone input Data ${phoneNumber.value}, ${isLogin.value}",
    );
    Get.dialog(const LoadingDialog(), barrierDismissible: false);
    var response = await http.post(
      Uri.parse(isLogin.value ? ApiServices.login : ApiServices.register),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "countryCode": "+91",
        "phoneNumber": phoneNumber.value.trim(),
        "loginType": "phone",
      }),
    );
    print(
      'userRegisterOrLoginUsingPhone Response status: ${response.statusCode}',
    );
    print('userRegisterOrLoginUsingPhone Response body: ${response.body}');
    if (Get.isDialogOpen!) {
      Get.back();
    }
    var data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["success"] == true) {
      Get.snackbar(
        "Success",
        data["message"],
        icon: const Icon(Icons.done, color: Colors.green),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
      Get.toNamed(
        Routes.otpVerificationScreen,
        arguments: {
          "forLogin": isLogin.value,
          "phoneNumber": phoneNumber.value.trim(),
          "email": "",
          "secretId":
              data["data"]?["user"]?["secretId"] ?? data["data"]?["secretId"],
        },
      );
    } else {
      Get.snackbar(
        "Oops!",
        data["message"],
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
    }
  }
}

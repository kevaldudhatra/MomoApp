import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:http/http.dart' as http;

class PrivacyAndTermsScreenController extends GetxController {
  final storage = GetStorage();
  RxBool isLoading = true.obs;
  RxBool isPrivacy = false.obs;
  RxString privacyAndTerms = "".obs;

  @override
  void onInit() {
    super.onInit();
    isPrivacy.value = Get.arguments['isPrivacy'];
    getPrivacyPolicy(isPrivacy: isPrivacy.value);
  }

  Future<void> getPrivacyPolicy({required bool isPrivacy}) async {
    try {
      isLoading.value = true;
      privacyAndTerms.value = "";
      final response = await http.get(
        Uri.parse(
          isPrivacy
              ? ApiServices.privacyPolicyUrl
              : ApiServices.termsAndConditionUrl,
        ),
        headers: {'Content-Type': 'application/json'},
      );
      print('getPrivacyPolicy Response status: ${response.statusCode}');
      print('getPrivacyPolicy Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        privacyAndTerms.value = data['data']['content'];
      } else {
        privacyAndTerms.value = "";
      }
    } catch (e) {
      print('getPrivacyPolicy Error: $e');
      privacyAndTerms.value = "";
    } finally {
      isLoading.value = false;
    }
  }
}

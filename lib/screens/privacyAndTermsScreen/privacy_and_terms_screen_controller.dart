import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:http/http.dart' as http;

class PrivacyAndTermsScreenController extends GetxController {
  final storage = GetStorage();
  RxBool isLoading = true.obs;
  RxBool isPrivacy = false.obs;
  RxBool isTerms = false.obs;
  RxBool isRefund = false.obs;
  RxString privacyAndTerms = "".obs;

  @override
  void onInit() {
    super.onInit();
    isTerms.value = Get.arguments['isTerms'] ?? false;
    isPrivacy.value = Get.arguments['isPrivacy'] ?? false;
    isRefund.value = Get.arguments['isRefund'] ?? false;
    getPrivacyPolicy(
      isTerms: isTerms.value,
      isPrivacy: isPrivacy.value,
      isRefund: isRefund.value,
    );
  }

  Future<void> getPrivacyPolicy({
    required bool isTerms,
    required bool isPrivacy,
    required bool isRefund,
  }) async {
    try {
      isLoading.value = true;
      privacyAndTerms.value = "";
      final response = await http.get(
        Uri.parse(
          isTerms
              ? ApiServices.termsAndConditionUrl
              : isPrivacy
              ? ApiServices.privacyPolicyUrl
              : ApiServices.refundPolicyUrl,
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

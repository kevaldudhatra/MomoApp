import 'package:get/get.dart';
import 'package:momos/network/api_services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreenController extends GetxController {
  void navigateToTerms() async {
    final Uri uri = Uri.parse(ApiServices.termsAndConditionUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Unable to open terms and conditions');
    }
  }

  void navigateToPrivacy() async {
    final Uri uri = Uri.parse(ApiServices.privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Unable to open privacy policy');
    }
  }
}

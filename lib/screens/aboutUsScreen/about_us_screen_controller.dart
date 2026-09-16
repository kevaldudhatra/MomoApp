import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';

class AboutUsScreenController extends GetxController {
  void navigateToTerms() {
    Get.toNamed(Routes.privacyAndTermsScreen, arguments: {'isPrivacy': false});
  }

  void navigateToPrivacy() {
    Get.toNamed(Routes.privacyAndTermsScreen, arguments: {'isPrivacy': true});
  }
}

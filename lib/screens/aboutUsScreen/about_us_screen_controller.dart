import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';

class AboutUsScreenController extends GetxController {
  void navigateToTerms() {
    Get.toNamed(Routes.privacyAndTermsScreen, arguments: {'isTerms': true});
  }

  void navigateToPrivacy() {
    Get.toNamed(Routes.privacyAndTermsScreen, arguments: {'isPrivacy': true});
  }

  void navigateToRefund() {
    Get.toNamed(Routes.privacyAndTermsScreen, arguments: {'isRefund': true});
  }
}

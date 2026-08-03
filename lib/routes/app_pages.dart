import 'package:get/get.dart';
import 'package:momos/screens/accountAccessScreen/account_access_screen_controller.dart';
import 'package:momos/screens/accountAccessScreen/account_access_screen_view.dart';
import 'package:momos/screens/createAccountScreen/create_account_screen_controller.dart';
import 'package:momos/screens/createAccountScreen/create_account_screen_view.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_view.dart';
import 'package:momos/screens/diningScreen/dining_screen_controller.dart';
import 'package:momos/screens/diningScreen/dining_screen_view.dart';
import 'package:momos/screens/profileScreen/profile_screen_controller.dart';
import 'package:momos/screens/profileScreen/profile_screen_view.dart';
import 'package:momos/screens/outletScreen/outlet_screen_controller.dart';
import 'package:momos/screens/outletScreen/outlet_screen_view.dart';
import 'package:momos/screens/forgotPasswordScreen/forgot_password_screen_controller.dart';
import 'package:momos/screens/forgotPasswordScreen/forgot_password_screen_view.dart';
import 'package:momos/screens/homeScreen/home_screen_controller.dart';
import 'package:momos/screens/homeScreen/home_screen_view.dart';
import 'package:momos/screens/loginScreen/login_screen_controller.dart';
import 'package:momos/screens/loginScreen/login_screen_view.dart';
import 'package:momos/screens/otpVerificationScreen/otp_verification_screen_controller.dart';
import 'package:momos/screens/otpVerificationScreen/otp_verification_screen_view.dart';
import 'package:momos/screens/resetPasswordScreen/reset_password_screen_controller.dart';
import 'package:momos/screens/resetPasswordScreen/reset_password_screen_view.dart';
import 'package:momos/screens/startScreen/start_screen_view.dart';
import 'package:momos/screens/verifyEmailScreen/verify_email_screen_controller.dart';
import 'package:momos/screens/verifyEmailScreen/verify_email_screen_view.dart';
import 'package:momos/screens/welcomeScreen/welcome_screen_view.dart';
import 'package:momos/screens/outletDetailScreen/outlet_detail_screen_controller.dart';
import 'package:momos/screens/outletDetailScreen/outlet_detail_screen_view.dart';
import 'package:momos/screens/reviewsScreen/reviews_screen_controller.dart';
import 'package:momos/screens/reviewsScreen/reviews_screen_view.dart';
import 'package:momos/screens/completeYourProfileScreen/complete_your_profile_screen_controller.dart';
import 'package:momos/screens/completeYourProfileScreen/complete_your_profile_screen_view.dart';
import 'package:momos/screens/orderDetailScreen/order_detail_screen_controller.dart';
import 'package:momos/screens/orderDetailScreen/order_detail_screen_view.dart';
import 'package:momos/screens/offersScreen/offers_screen_controller.dart';
import 'package:momos/screens/offersScreen/offers_screen_view.dart';
import 'package:momos/screens/addressSelectionScreen/address_selection_screen_controller.dart';
import 'package:momos/screens/addressSelectionScreen/address_selection_screen_view.dart';
import 'package:momos/screens/searchAddressScreen/search_address_screen_controller.dart';
import 'package:momos/screens/searchAddressScreen/search_address_screen_view.dart';
import 'package:momos/screens/myOrdersScreen/my_orders_screen_controller.dart';
import 'package:momos/screens/myOrdersScreen/my_orders_screen_view.dart';
import 'package:momos/screens/orderStatusScreen/order_status_screen_controller.dart';
import 'package:momos/screens/orderStatusScreen/order_status_screen_view.dart';

part 'app_routes.dart';

class AppPages {
  static String initialRoute = Routes.welcomeScreen;

  static final routes = [
    GetPage(name: Routes.welcomeScreen, page: () => const WelcomeScreen()),
    GetPage(name: Routes.startScreen, page: () => const StartScreen()),
    GetPage(
      name: Routes.accountAccessScreen,
      page: () => const AccountAccessScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AccountAccessScreenController>(
          () => AccountAccessScreenController(),
        );
      }),
    ),
    GetPage(
      name: Routes.otpVerificationScreen,
      page: () => const OtpVerificationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OtpVerificationScreenController>(
          () => OtpVerificationScreenController(),
        );
      }),
    ),
    GetPage(
      name: Routes.createAccountScreen,
      page: () => const CreateAccountScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CreateAccountScreenController>(
          () => CreateAccountScreenController(),
        );
      }),
    ),
    GetPage(
      name: Routes.loginScreen,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginScreenController>(() => LoginScreenController());
      }),
    ),
    GetPage(
      name: Routes.forgotPasswordScreen,
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ForgotPasswordScreenController>(
          () => ForgotPasswordScreenController(),
        );
      }),
    ),
    GetPage(
      name: Routes.verifyEmailScreen,
      page: () => const VerifyEmailScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<VerifyEmailScreenController>(
          () => VerifyEmailScreenController(),
        );
      }),
    ),
    GetPage(
      name: Routes.resetPasswordScreen,
      page: () => const ResetPasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ResetPasswordScreenController>(
          () => ResetPasswordScreenController(),
        );
      }),
    ),
    GetPage(
      name: Routes.completeYourProfileScreen,
      page: () => const CompleteYourProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CompleteYourProfileScreenController>(
          () => CompleteYourProfileScreenController(),
        );
      }),
    ),
    GetPage(
      name: Routes.homeScreen,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeScreenController>(() => HomeScreenController());
        Get.lazyPut<DeliveryScreenController>(() => DeliveryScreenController());
        Get.lazyPut<DiningScreenController>(() => DiningScreenController());
        Get.lazyPut<ProfileScreenController>(() => ProfileScreenController());
      }),
    ),
    GetPage(
      name: Routes.deliveryScreen,
      page: () => const DeliveryScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DeliveryScreenController>(() => DeliveryScreenController());
      }),
    ),
    GetPage(
      name: Routes.diningScreen,
      page: () => const DiningScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DiningScreenController>(() => DiningScreenController());
      }),
    ),
    GetPage(
      name: Routes.profileScreen,
      page: () => const ProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileScreenController>(() => ProfileScreenController());
      }),
    ),
    GetPage(
      name: Routes.outletScreen,
      page: () => const OutletScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OutletScreenController>(() => OutletScreenController());
      }),
    ),
    GetPage(
      name: Routes.outletDetailScreen,
      page: () => const OutletDetailScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OutletDetailScreenController>(
          () => OutletDetailScreenController(),
        );
      }),
    ),
    GetPage(
      name: Routes.reviewsScreen,
      page: () => const ReviewsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ReviewsScreenController>(() => ReviewsScreenController());
      }),
    ),
    GetPage(
      name: Routes.orderDetailScreen,
      page: () => const OrderDetailScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OrderDetailScreenController>(
          () => OrderDetailScreenController(),
        );
      }),
    ),
    GetPage(
      name: Routes.offersScreen,
      page: () => const OffersScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OffersScreenController>(() => OffersScreenController());
      }),
    ),
    GetPage(
      name: Routes.addressSelectionScreen,
      page: () => const AddressSelectionScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AddressSelectionScreenController>(
          () => AddressSelectionScreenController(),
        );
      }),
    ),
    GetPage(
      name: Routes.searchAddressScreen,
      page: () => const SearchAddressScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SearchAddressScreenController>(
          () => SearchAddressScreenController(),
        );
      }),
    ),
    GetPage(
      name: Routes.myOrdersScreen,
      page: () => const MyOrdersScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MyOrdersScreenController>(() => MyOrdersScreenController());
      }),
    ),
    GetPage(
      name: Routes.orderStatusScreen,
      page: () => const OrderStatusScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OrderStatusScreenController>(
          () => OrderStatusScreenController(),
        );
      }),
    ),
  ];
}

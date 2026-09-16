import 'package:momos/network/env.dart';

class ApiServices {
  // Live mode url //
  static String baseUrl = liveUrl;
  static String socketUrl = socketLiveUrl;
  static String connectSocket = '$baseUrl/api/v1/user/chat/connect-socket';
  static String verifyOtp = '$baseUrl/public/api/v1/user/otp-verify';
  static String resendOtp = '$baseUrl/public/api/v1/user/resend-otp';
  static String register = '$baseUrl/public/api/v1/user/register';
  static String login = '$baseUrl/public/api/v1/user/login';
  static String forgotPassword = '$baseUrl/public/api/v1/user/forgot-password';
  static String resetPassword = '$baseUrl/api/v1/user/reset-password';
  static String getAndUpdateProfile = '$baseUrl/api/v1/user/profile';
  static String userAddress = '$baseUrl/api/v1/user/addresses';
  static String tableReservations = '$baseUrl/api/v1/user/reservations';
  static String getFoodTypes = '$baseUrl/api/v1/user/outlates/{outletId}/types';
  static String getFaqList = '$baseUrl/public/api/v1/user/content/faqs';
  static String deleteUserAddress =
      '$baseUrl/api/v1/user/addresses/{addressId}';
  static String verifyForgotOtp =
      '$baseUrl/public/api/v1/user/verify-forgot-password-otp';
  static String getDeliverySlots =
      '$baseUrl/api/v1/user/outlates/{outletId}/delivery-slots';
  static String getPaymentMethod =
      '$baseUrl/api/v1/user/outlates/{outletId}/payment-methods';
  static String getReservations =
      '$baseUrl/api/v1/user/reservations?limit=10&page={page}&status={status}';
  static String getOutlateByLocation =
      '$baseUrl/api/v1/user/get-home-details?latitude={latitude}&longitude={longitude}';
  static String getAllOffers =
      '$baseUrl/api/v1/user/outlates/{outletId}/promocodes';
  static String getFoodData =
      '$baseUrl/api/v1/user/outlates/{outletId}/menu?typeId={typeId}';
  static String getFoodItemDetails =
      '$baseUrl/api/v1/user/outlates/{outletId}/menu/{itemId}';
  static String getAllOutlateDetails =
      '$baseUrl/api/v1/user/outlates/{outletID}';
  static String getOutletReview =
      '$baseUrl/api/v1/user/outlates/{outletID}/ratings';
  static String termsAndConditionUrl =
      '$baseUrl/public/api/v1/user/content/terms-and-conditions';
  static String privacyPolicyUrl =
      '$baseUrl/public/api/v1/user/content/privacy-policy';
}

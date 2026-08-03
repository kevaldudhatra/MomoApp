import 'package:momos/network/env.dart';

class ApiServices {
  // Live mode url //
  static String baseUrl = liveUrl;

  static String verifyOtp = '$baseUrl/public/api/v1/user/otp-verify';
  static String resendOtp = '$baseUrl/public/api/v1/user/resend-otp';
  static String register = '$baseUrl/public/api/v1/user/register';
  static String login = '$baseUrl/public/api/v1/user/login';
  static String forgotPassword = '$baseUrl/public/api/v1/user/forgot-password';
  static String resetPassword = '$baseUrl/api/v1/user/reset-password';
  static String updateProfile = '$baseUrl/api/v1/user/profile';
  static String verifyForgotOtp =
      '$baseUrl/public/api/v1/user/verify-forgot-password-otp';
}

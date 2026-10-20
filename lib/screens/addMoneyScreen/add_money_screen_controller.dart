import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/screens/myWalletScreen/my_wallet_screen_controller.dart';
import 'package:momos/screens/profileScreen/profile_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:momos/network/payment_sound_service.dart';
import 'package:momos/widgets/loading_view.dart';
import 'package:http/http.dart' as http;

class AddMoneyScreenController extends GetxController {
  final storage = GetStorage();
  final amountController = TextEditingController();
  final RxInt selectedQuickAmount = 2000.obs;
  final RxString selectedPaymentMethod = "Gpay".obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessingPayment = false.obs;
  late Razorpay _razorpay;
  final _paymentSoundService = PaymentSoundService();
  String? _currentOrderId;
  double _pendingAmount = 0.0;
  bool _isVerifyingPayment = false;
  String? _lastVerifiedPaymentId;

  @override
  void onInit() {
    super.onInit();
    amountController.text = selectedQuickAmount.value.toString();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    amountController.dispose();
    _paymentSoundService.dispose();
    super.onClose();
  }

  void selectQuickAmount(int amount) {
    selectedQuickAmount.value = amount;
    amountController.text = amount.toString();
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void addMoney() async {
    final enteredText = amountController.text.trim();
    final double? amount = double.tryParse(enteredText);

    if (amount == null || amount <= 0) {
      Get.snackbar(
        "Oops!",
        "Please enter a valid amount.",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    // Prevent duplicate triggers
    if (isLoading.value || isProcessingPayment.value) return;

    isLoading.value = true;
    isProcessingPayment.value = true;
    _pendingAmount = amount;
    _currentOrderId = null;
    _isVerifyingPayment = false;

    Get.dialog(const LoadingDialog(), barrierDismissible: false);

    try {
      final response = await http.post(
        Uri.parse(ApiServices.initiateAddMoney),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode({
          "amount": amount.toInt() == amount ? amount.toInt() : amount,
        }),
      );

      print('initiateAddMoney Response status: ${response.statusCode}');
      print('initiateAddMoney Response body: ${response.body}');

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data["success"] == true) {
        final resData = data["data"] is Map ? data["data"] : data;
        final String orderId = resData["razorpayOrderId"]?.toString() ?? "";
        final String razorpayKeyToUse = resData["keyId"]?.toString() ?? "";

        if (orderId.isEmpty) {
          isLoading.value = false;
          isProcessingPayment.value = false;
          Get.snackbar(
            "Oops!",
            "Could not retrieve payment order details. Please try again.",
            snackPosition: SnackPosition.TOP,
            icon: const Icon(Icons.error, color: Colors.red),
            backgroundColor: charcoalGray.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
          return;
        }

        _currentOrderId = orderId;
        _openRazorpayCheckout(
          orderId: orderId,
          amount: amount,
          key: razorpayKeyToUse,
          checkoutConfig: resData["checkoutConfig"] ?? {},
        );
      } else {
        isLoading.value = false;
        isProcessingPayment.value = false;
        Get.snackbar(
          "Oops!",
          data["message"] ?? "Failed to initiate payment. Please try again.",
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.error, color: Colors.red),
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isLoading.value = false;
      isProcessingPayment.value = false;
      print('initiateAddMoney Error: $e');
      Get.snackbar(
        "Oops!",
        "Something went wrong while initiating payment. Please try again.",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  void _openRazorpayCheckout({
    required String orderId,
    required double amount,
    required String key,
    required Map<String, dynamic> checkoutConfig,
  }) {
    final options = {
      'key': key,
      'amount': (amount * 100).toInt(),
      'currency': 'INR',
      'name': 'Momo I am',
      'order_id': orderId,
      'theme': {'color': '#FF5722'},
      if (checkoutConfig.isNotEmpty) 'config': checkoutConfig,
    };

    print("Razorpay option : $options");

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Razorpay open Error: $e');
      isLoading.value = false;
      isProcessingPayment.value = false;
      Get.snackbar(
        "Oops!",
        "Failed to open Razorpay payment gateway: $e",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print(
      'Razorpay Payment Success: paymentId=${response.paymentId}, orderId=${response.orderId}',
    );

    // Duplicate-payment prevention
    if (_isVerifyingPayment) {
      print(
        'Payment verification already in progress, ignoring duplicate event.',
      );
      return;
    }

    if (response.paymentId != null &&
        _lastVerifiedPaymentId == response.paymentId) {
      print(
        'Payment ${response.paymentId} already verified, ignoring duplicate event.',
      );
      return;
    }

    _isVerifyingPayment = true;
    _lastVerifiedPaymentId = response.paymentId;

    Get.dialog(const LoadingDialog(), barrierDismissible: false);

    try {
      final verifyPayload = {
        "razorpayOrderId": response.orderId ?? _currentOrderId ?? "",
        "razorpayPaymentId": response.paymentId ?? "",
        "razorpaySignature": response.signature ?? "",
        "note": "Wallet top-up",
      };

      print('verifyAddMoney Input : $verifyPayload');

      final verifyRes = await http.post(
        Uri.parse(ApiServices.addMoney),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode(verifyPayload),
      );

      print('verifyAddMoney Response status: ${verifyRes.statusCode}');
      print('verifyAddMoney Response body: ${verifyRes.body}');

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      final data = jsonDecode(verifyRes.body);

      if (verifyRes.statusCode == 201 && data["success"] == true) {
        // Extract updated balance if returned by backend
        double? updatedBalance;
        if (data["data"] is Map) {
          final rawAmt = data["data"]["walletAmt"];
          if (rawAmt != null) {
            updatedBalance = double.tryParse(rawAmt.toString());
          }
        }

        // Update MyWalletScreenController
        if (Get.isRegistered<MyWalletScreenController>()) {
          final walletCtrl = Get.find<MyWalletScreenController>();
          walletCtrl.onTopUpSuccess(
            amount: _pendingAmount,
            newBalance: updatedBalance,
            paymentId: response.paymentId,
          );
        }

        // Update ProfileScreenController
        if (Get.isRegistered<ProfileScreenController>()) {
          final profileCtrl = Get.find<ProfileScreenController>();
          if (updatedBalance != null) {
            profileCtrl.userData['walletAmt'] = updatedBalance;
          } else {
            final current =
                double.tryParse(
                  profileCtrl.userData['walletAmt']?.toString() ?? '0',
                ) ??
                0.0;
            profileCtrl.userData['walletAmt'] = current + _pendingAmount;
          }
          profileCtrl.userData.refresh();
          profileCtrl.getUserProfile();
        }

        isLoading.value = false;
        isProcessingPayment.value = false;
        _isVerifyingPayment = false;

        // Show Success Dialog
        await _showSuccessDialog(_pendingAmount);
      } else {
        isLoading.value = false;
        isProcessingPayment.value = false;
        _isVerifyingPayment = false;
        Get.snackbar(
          "Verification Failed",
          data["message"] ??
              "Could not verify payment. Please contact support if your account was debited.",
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.error, color: Colors.red),
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isLoading.value = false;
      isProcessingPayment.value = false;
      _isVerifyingPayment = false;
      print('verifyAddMoney Error: $e');
      Get.snackbar(
        "Verification Error",
        "Network error while verifying payment. If amount was debited, it will reflect shortly.",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> _showSuccessDialog(double amount) async {
    _paymentSoundService.playPaymentSound();
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        elevation: 0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                AppImages().success,
                width: 140,
                height: 140,
                repeat: false,
              ),
              const SizedBox(height: 20),
              const Text(
                "Payment Successful!",
                style: TextStyle(
                  color: black,
                  fontSize: 18,
                  fontFamily: natoBold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "₹${amount.toStringAsFixed(2)} has been added to your wallet.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: charcoalGray,
                  fontSize: 14,
                  fontFamily: natoRegular,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      barrierColor: dialogBarrierColor,
      barrierDismissible: false,
    );
    await Future.delayed(const Duration(milliseconds: 2500));
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    Get.back();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(
      'Razorpay Payment Error: code=${response.code}, message=${response.message}',
    );
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    isLoading.value = false;
    isProcessingPayment.value = false;
    _isVerifyingPayment = false;
    final isCancelled = response.code == Razorpay.PAYMENT_CANCELLED;
    Get.snackbar(
      isCancelled ? "Payment Cancelled" : "Payment Failed",
      isCancelled
          ? "Payment was cancelled."
          : (response.message ?? "Payment failed. Please try again."),
      snackPosition: SnackPosition.TOP,
      icon: Icon(
        isCancelled ? Icons.info_outline : Icons.error,
        color: isCancelled ? Colors.amber : Colors.red,
      ),
      backgroundColor: charcoalGray.withValues(alpha: 0.9),
      colorText: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('Razorpay External Wallet: walletName=${response.walletName}');
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    isLoading.value = false;
    isProcessingPayment.value = false;
    Get.snackbar(
      "External Wallet Selected",
      "Redirecting to ${response.walletName ?? 'external wallet'} to complete payment.",
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.account_balance_wallet, color: Colors.blue),
      backgroundColor: charcoalGray.withValues(alpha: 0.9),
      colorText: Colors.white,
    );
  }
}

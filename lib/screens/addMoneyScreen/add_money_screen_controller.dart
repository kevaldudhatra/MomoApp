import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/utils/const_colors_key.dart';

class AddMoneyScreenController extends GetxController {
  final amountController = TextEditingController();
  final RxInt selectedQuickAmount = 2000.obs;
  final RxString selectedPaymentMethod = "Gpay".obs;

  @override
  void onInit() {
    super.onInit();
    amountController.text = selectedQuickAmount.value.toString();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  void selectQuickAmount(int amount) {
    selectedQuickAmount.value = amount;
    amountController.text = amount.toString();
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void addMoney() {
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

    Get.snackbar(
      "Success",
      "₹${amount.toStringAsFixed(2)} added to your wallet!",
      icon: const Icon(Icons.done, color: Colors.green),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      backgroundColor: charcoalGray.withValues(alpha: 0.9),
    );

    // Return back to My Wallet screen
    Future.delayed(const Duration(seconds: 5), () {
      Get.back();
    });
  }
}

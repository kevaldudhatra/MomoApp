import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/addMoneyScreen/add_money_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/widgets/custom_text_field.dart';

class AddMoneyScreen extends GetView<AddMoneyScreenController> {
  const AddMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              // Header / App Bar
              Container(
                width: double.infinity,
                color: white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Image.asset(
                        AppImages().backArrowIcon,
                        width: 20,
                        height: 20,
                        color: black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "My Wallet",
                      style: TextStyle(
                        color: black,
                        fontSize: 20,
                        fontFamily: natoBold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: borderGray),

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enter Amount input
                        CustomTextField(
                          labelText: "Enter Amount",
                          hintText: "Enter amount",
                          textEditingController: controller.amountController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            final parsed = int.tryParse(value.trim());
                            if (parsed != null &&
                                [1000, 2000, 3000].contains(parsed)) {
                              controller.selectedQuickAmount.value = parsed;
                            } else {
                              controller.selectedQuickAmount.value = -1;
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Quick Selectors
                        Row(
                          children: [
                            _buildQuickAmountButton(1000),
                            const SizedBox(width: 12),
                            _buildQuickAmountButton(2000),
                            const SizedBox(width: 12),
                            _buildQuickAmountButton(3000),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Heading: Payment Method
                        const Text(
                          "Payment method",
                          style: TextStyle(
                            color: charcoalGray,
                            fontSize: 16,
                            fontFamily: natoSemiBold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Payment Methods Card Container
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: cardShadow,
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              _buildPaymentMethodRow(
                                methodKey: "Gpay",
                                label: "Gpay",
                                iconPath: AppImages().gPeIcon,
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: borderGray,
                              ),
                              _buildPaymentMethodRow(
                                methodKey: "Phone Pay",
                                label: "Phone Pay",
                                iconPath: AppImages().phonePeIcon,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Action Button
                        CustomButton(
                          width: double.infinity,
                          label: "Add Money",
                          onTap: () {
                            controller.addMoney();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(int amount) {
    return Obx(() {
      final isSelected = controller.selectedQuickAmount.value == amount;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.selectQuickAmount(amount),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? orange : borderGray,
                width: 1,
              ),
            ),
            child: Text(
              amount.toString(),
              style: TextStyle(
                color: isSelected ? orange : black,
                fontSize: 16,
                fontFamily: isSelected ? natoSemiBold : natoRegular,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPaymentMethodRow({
    required String methodKey,
    required String label,
    required String iconPath,
  }) {
    return Obx(() {
      final isSelected = controller.selectedPaymentMethod.value == methodKey;
      return InkWell(
        onTap: () => controller.selectPaymentMethod(methodKey),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo icon
              Image.asset(iconPath, width: 24, height: 24, fit: BoxFit.contain),
              const SizedBox(width: 12),

              // Title label
              Text(
                label,
                style: const TextStyle(
                  color: black,
                  fontSize: 15,
                  fontFamily: natoMedium,
                ),
              ),
              const Spacer(),

              // Custom Radio Indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? orange : lightGray,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: orange,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }
}

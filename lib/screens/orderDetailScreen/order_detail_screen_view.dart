import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_button.dart';
import 'package:momos/widgets/custom_text_field.dart';
import 'package:momos/screens/cartManagement/cart_controller.dart';
import 'package:momos/screens/orderDetailScreen/order_detail_screen_controller.dart';

class OrderDetailScreen extends GetView<OrderDetailScreenController> {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
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
                      "Momo I AM gol park",
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

              // Main Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ordered Items List Card
                        _buildCard(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Obx(
                                () => ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.cartItems.length,
                                  separatorBuilder: (context, index) =>
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.0,
                                        ),
                                        child: Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: borderGray,
                                        ),
                                      ),
                                  itemBuilder: (context, index) {
                                    final item = controller.cartItems[index];
                                    return _buildCartItemRow(item);
                                  },
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: borderGray,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: charcoalGray,
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "Add More Items",
                                      style: TextStyle(
                                        color: charcoalGray,
                                        fontSize: 14,
                                        fontFamily: natoMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Cooking Note Section
                        CustomTextField(
                          labelText: 'Add Cooking Note',
                          hintText: "Add cooking note",
                          textEditingController:
                              controller.cookingNoteController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),

                        // Offers Section
                        Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSectionTitle("Offers"),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(Routes.offersScreen);
                                    },
                                    child: const Text(
                                      "View all",
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 13,
                                        fontFamily: natoMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      hintText: "Enter promocode",
                                      textEditingController:
                                          controller.promoCodeController,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => controller.applyPromoCode(),
                                    child: Container(
                                      height: 35,
                                      width: 85,
                                      decoration: BoxDecoration(
                                        color: orange,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Apply",
                                        style: TextStyle(
                                          color: white,
                                          fontSize: 14,
                                          fontFamily: natoMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              controller.isPromocodeApplied.value
                                  ? Container(
                                      margin: EdgeInsets.only(
                                        top: 10,
                                        bottom: 20,
                                      ),
                                      child: _buildCard(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Promocode applied",
                                                  style: const TextStyle(
                                                    color: black,
                                                    fontSize: 15,
                                                    fontFamily: natoMedium,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    controller
                                                        .removePromocode();
                                                  },
                                                  child: Container(
                                                    height: 35,
                                                    width: 85,
                                                    decoration: BoxDecoration(
                                                      color: orange,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                      "Remove",
                                                      style: TextStyle(
                                                        color: white,
                                                        fontSize: 14,
                                                        fontFamily: natoMedium,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        // Delivery Details Section
                        Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("Delivery Details"),
                              const SizedBox(height: 5),
                              _buildDeliveryDetailsCard(context),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        // Total Bill Section
                        Obx(
                          () => controller.cartItems.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle("Total Bill"),
                                    const SizedBox(height: 5),
                                    _buildTotalBillCard(context),
                                    const SizedBox(height: 20),
                                  ],
                                )
                              : Container(),
                        ),

                        // Payment Method Section
                        Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("Payment Method"),
                              const SizedBox(height: 5),
                              _buildPaymentMethodCard(context),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Sticky Bar (Place Order Button)
              Container(
                width: double.infinity,
                color: white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: CustomButton(
                  width: MediaQuery.of(context).size.width,
                  label: "Place Order",
                  onTap: () {
                    controller.placeOrder();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Row for Each Cart Item
  Widget _buildCartItemRow(CartItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Veg Indicator
        Image.asset(AppImages().vegIcon, width: 16, height: 16),
        const SizedBox(width: 12),
        // Title & Description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  color: black,
                  fontSize: 15,
                  fontFamily: natoBold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: const TextStyle(
                  color: charcoalGray,
                  fontSize: 12,
                  fontFamily: natoRegular,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Quantity Selector & Price Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Custom bordered quantity selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: orange, width: 1),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => controller.decrementQuantity(item),
                    child: const Icon(
                      Icons.remove,
                      size: 16,
                      color: charcoalGray,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      item.quantity.toString(),
                      style: const TextStyle(
                        color: black,
                        fontSize: 14,
                        fontFamily: natoBold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.incrementQuantity(item),
                    child: const Icon(Icons.add, size: 16, color: charcoalGray),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "₹${item.price.toInt()}",
              style: const TextStyle(
                color: black,
                fontSize: 14,
                fontFamily: natoBold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Reusable Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: charcoalGray,
          fontSize: 14,
          fontFamily: natoMedium,
        ),
      ),
    );
  }

  // Styled Card Wrapper
  Widget _buildCard({required List<Widget> children}) {
    return Container(
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
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  // Card details for Delivery Details
  Widget _buildDeliveryDetailsCard(BuildContext context) {
    return _buildCard(
      children: [
        // Row 1: Delivering now
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                AppImages().timerIcon,
                width: 20,
                height: 20,
                color: charcoalGray,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.deliveryTime.value,
                      style: const TextStyle(
                        color: black,
                        fontSize: 14,
                        fontFamily: natoBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => controller.showScheduleBottomSheet(context),
                      child: const Text(
                        "Schedule for later",
                        style: TextStyle(
                          color: orange,
                          fontSize: 13,
                          fontFamily: natoMedium,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, thickness: 1, color: borderGray),

        // Row 2: Selected address
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: controller.userAddressList.isNotEmpty
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      AppImages().addressIcon,
                      width: 20,
                      height: 20,
                      color: charcoalGray,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.addressTitle.value,
                            style: const TextStyle(
                              color: black,
                              fontSize: 14,
                              fontFamily: natoBold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.addressSubtitle.value,
                            style: const TextStyle(
                              color: charcoalGray,
                              fontSize: 13,
                              fontFamily: natoRegular,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () =>
                                controller.showAddressBottomSheet(context),
                            child: const Text(
                              "Change",
                              style: TextStyle(
                                color: orange,
                                fontSize: 13,
                                fontFamily: natoMedium,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () => controller.showAddressBottomSheet(context),
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Add Address",
                      style: TextStyle(
                        color: white,
                        fontSize: 14,
                        fontFamily: natoMedium,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // Card details for Total bill
  Widget _buildTotalBillCard(BuildContext context) {
    return _buildCard(
      children: [
        GestureDetector(
          onTap: () => controller.showBillDetailsBottomSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                Image.asset(
                  AppImages().billIcon,
                  width: 20,
                  height: 20,
                  color: charcoalGray,
                ),
                const SizedBox(width: 10),
                Text(
                  "Total Bill ",
                  style: const TextStyle(
                    color: black,
                    fontSize: 15,
                    fontFamily: natoMedium,
                  ),
                ),
                Text(
                  "₹${controller.totalBill.toInt()}",
                  style: const TextStyle(
                    color: black,
                    fontSize: 15,
                    fontFamily: natoBold,
                  ),
                ),
                const Spacer(),
                Image.asset(
                  AppImages().dropDownArrowIcon,
                  width: 20,
                  height: 20,
                  color: charcoalGray,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Card details for Payment method
  Widget _buildPaymentMethodCard(BuildContext context) {
    final selectedMethod = controller.selectedPaymentMethod.value;
    final methodItem = controller.paymentMethodList.firstWhere(
      (element) => element.name == selectedMethod,
      orElse: () => PaymentMethodItem(id: 0, name: ''),
    );
    final iconPath = methodItem.iconPath;
    return _buildCard(
      children: [
        GestureDetector(
          onTap: () => controller.showPaymentMethodBottomSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                Image.asset(iconPath, width: 20, height: 20),
                const SizedBox(width: 10),
                Text(
                  controller.selectedPaymentMethod.value,
                  style: const TextStyle(
                    color: black,
                    fontSize: 15,
                    fontFamily: natoMedium,
                  ),
                ),
                const Spacer(),
                Image.asset(
                  AppImages().dropDownArrowIcon,
                  width: 20,
                  height: 20,
                  color: charcoalGray,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/cartManagement/cart_controller.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';

class GlobalCartButton extends StatelessWidget {
  final double bottomMargin;
  final double horizontalMargin;

  const GlobalCartButton({
    super.key,
    this.bottomMargin = 0.0,
    this.horizontalMargin = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Obx(() {
      if (cartController.isEmpty) {
        return const SizedBox.shrink();
      }

      final itemCount = cartController.totalItemCount;
      final itemText = itemCount == 1
          ? "1 Item added to cart"
          : "$itemCount Items added to cart";

      return Container(
        margin: EdgeInsets.only(
          left: horizontalMargin,
          right: horizontalMargin,
          bottom: bottomMargin,
        ),
        child: GestureDetector(
          onTap: () => Get.toNamed(Routes.orderDetailScreen),
          child: Container(
            height: 55,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: orange,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    itemText,
                    style: const TextStyle(
                      color: white,
                      fontSize: 15,
                      fontFamily: natoMedium,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Continue",
                      style: TextStyle(
                        color: white,
                        fontSize: 15,
                        fontFamily: natoBold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.5),
                      child: Image.asset(
                        AppImages().rightArrowIcon,
                        width: 15,
                        height: 15,
                        color: white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

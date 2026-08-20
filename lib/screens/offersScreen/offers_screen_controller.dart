import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/utils/const_colors_key.dart';

class Offer {
  final String id;
  final String title;
  final String subtitle;
  final String code;
  final List<String> bullets;
  final bool isActive;
  final RxBool isExpanded;

  Offer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.bullets,
    required this.isActive,
    bool isExpanded = false,
  }) : isExpanded = isExpanded.obs;
}

class OffersScreenController extends GetxController {
  final offers = <Offer>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadOffers();
  }

  void _loadOffers() {
    offers.assignAll([
      Offer(
        id: "1",
        title: "Get flat ₹125 off!",
        subtitle: "Use code PROMOCODE20 to avial this offer",
        code: "PROMOCODE20",
        bullets: [
          "minimum order value for this offer is 2000",
          "minimum order value for this offer is 2000",
        ],
        isActive: true,
        isExpanded: true,
      ),
      Offer(
        id: "2",
        title: "Get flat ₹125 off!",
        subtitle: "Use code CRAZY456 to avial this offer",
        code: "CRAZY456",
        bullets: [
          "minimum order value for this offer is 1000",
          "minimum order value for this offer is 1000",
        ],
        isActive: true,
        isExpanded: false,
      ),
      Offer(
        id: "3",
        title: "Get flat ₹125 off!",
        subtitle: "Use code CRAZY555 to avial this offer",
        code: "CRAZY555",
        bullets: [
          "minimum order value for this offer is 1500",
          "minimum order value for this offer is 1500",
        ],
        isActive: false,
        isExpanded: false,
      ),
      Offer(
        id: "4",
        title: "Get flat ₹125 off!",
        subtitle: "Use code CRAZY666 to avial this offer",
        code: "CRAZY666",
        bullets: [
          "minimum order value for this offer is 1500",
          "minimum order value for this offer is 1500",
        ],
        isActive: false,
        isExpanded: false,
      ),
    ]);
  }

  void toggleAccordion(Offer offer) {
    if (offer.isExpanded.value) {
      offer.isExpanded.value = false;
    } else {
      // Accordion effect: collapse all other offers first
      for (var o in offers) {
        o.isExpanded.value = false;
      }
      offer.isExpanded.value = true;
    }
  }

  void applyOffer(Offer offer) {
    if (!offer.isActive) {
      Get.snackbar(
        "Oops!",
        "This offer is currently inactive.",
        icon: const Icon(Icons.error, color: Colors.red),
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } else {
      // Navigate back passing the selected promo code
      Get.back(result: offer.code);
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.snackbar(
          "Success",
          "Coupon code '${offer.code}' applied successfully!",
          icon: const Icon(Icons.done, color: Colors.green),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
      });
    }
  }
}

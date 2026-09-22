import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

class Offer {
  final int id;
  final String title;
  final String subtitle;
  final String code;
  final List<dynamic> bullets;
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
  final storage = GetStorage();
  final isLoading = true.obs;
  final offers = <Offer>[].obs;
  final outletId = Get.isRegistered<DeliveryScreenController>()
      ? Get.find<DeliveryScreenController>().outlateDetails['id']
      : 0;

  @override
  void onInit() {
    super.onInit();
    getAllOffers();
  }

  Future<void> getAllOffers() async {
    try {
      offers.clear();
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(
          ApiServices.getAllOffers.replaceAll(
            '{outletId}',
            outletId.toString(),
          ),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getAllOffers Response status: ${response.statusCode}');
      print('getAllOffers Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        for (var offer in data["data"]["promocodes"]) {
          offers.add(
            Offer(
              id: offer["id"],
              title: offer["title"],
              subtitle: "Use code ${offer["name"]} to avial this offer",
              code: offer["name"],
              bullets: offer["reasons"],
              isActive: offer["isApplicable"],
              isExpanded: false,
            ),
          );
        }
      } else {
        offers.clear();
      }
    } catch (e) {
      print('getOutletDetails Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleAccordion(Offer offer) {
    if (offer.isExpanded.value) {
      offer.isExpanded.value = false;
    } else {
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
      Get.back(result: {"promocode": offer.code, "promocodeId": offer.id});
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.snackbar(
          "Success",
          "Coupon code '${offer.code}' selected successfully!",
          icon: const Icon(Icons.done, color: Colors.green),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
      });
    }
  }
}

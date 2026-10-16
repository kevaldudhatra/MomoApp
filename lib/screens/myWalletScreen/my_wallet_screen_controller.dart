import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/screens/profileScreen/profile_screen_controller.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final String dateTime;
  final double amount;
  final bool isTopup;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dateTime,
    required this.amount,
    required this.isTopup,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      title: json['type'] == 'addMoneyUser' ? "Wallet top-up" : "Order Payment",
      subtitle: json['type'] == 'addMoneyUser'
          ? json['razorpayPaymentId'] ?? ""
          : json['note'] ?? "",
      dateTime: DateFormat(
        'dd MMM, hh:mm a',
      ).format(DateTime.parse(json['createdAt'].toString())).toString(),
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      isTopup: json['entryType'] == 'credit' ? true : false,
    );
  }
}

class MyWalletScreenController extends GetxController {
  final storage = GetStorage();
  final ScrollController scrollController = ScrollController();
  final RxDouble balance = 0.0.obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool isNextPage = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt limit = 10.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    syncBalanceFromProfile();
    loadTransactions(page: 1, isRefresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
      if (!isLoading.value && !isMoreLoading.value && isNextPage.value) {
        loadTransactions(page: currentPage.value + 1);
      }
    }
  }

  void syncBalanceFromProfile() {
    if (Get.isRegistered<ProfileScreenController>()) {
      final profile = Get.find<ProfileScreenController>();
      final amt = profile.userData['walletAmt'];
      if (amt != null) {
        balance.value = double.tryParse(amt.toString()) ?? 0.0;
      }
    }
  }

  void onTopUpSuccess({
    required double amount,
    double? newBalance,
    String? paymentId,
  }) {
    if (newBalance != null) {
      balance.value = newBalance;
    } else {
      balance.value += amount;
    }
    loadTransactions(page: 1, isRefresh: true);
  }

  Future<void> loadTransactions({int page = 1, bool isRefresh = false}) async {
    if (isLoading.value || isMoreLoading.value) return;
    if (!isRefresh && page > 1 && !isNextPage.value) return;
    if (isRefresh || page == 1) {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = "";
    } else {
      isMoreLoading.value = true;
    }
    try {
      final url = ApiServices.walletTransactions.replaceAll(
        '{pageNumber}',
        page.toString(),
      );
      debugPrint('fetchWalletTransactions URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      debugPrint('fetchWalletTransactions Status: ${response.statusCode}');
      debugPrint('fetchWalletTransactions Body: ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'];
          List<dynamic> rawList = json['data']['transactions'];
          final newItems = rawList.map<TransactionModel>((item) {
            if (item is Map<String, dynamic>) {
              return TransactionModel.fromJson(item);
            } else if (item is Map) {
              return TransactionModel.fromJson(Map<String, dynamic>.from(item));
            }
            return TransactionModel.fromJson({});
          }).toList();

          if (data is Map) {
            currentPage.value = data['page'] is int
                ? data['page']
                : int.tryParse(data['page']?.toString() ?? '') ?? page;
            limit.value = data['limit'] is int
                ? data['limit']
                : int.tryParse(data['limit']?.toString() ?? '') ?? 10;
            if (data['isNextPage'] != null) {
              isNextPage.value = data['isNextPage'] == true;
            } else {
              isNextPage.value = newItems.length >= limit.value;
            }
          } else {
            currentPage.value = page;
            isNextPage.value = newItems.length >= limit.value;
          }

          if (isRefresh || page == 1) {
            transactions.assignAll(newItems);
          } else {
            final existingIds = transactions
                .where((t) => t.id.isNotEmpty)
                .map((t) => t.id)
                .toSet();
            final uniqueItems = newItems.where((item) {
              if (item.id.isNotEmpty) {
                if (existingIds.contains(item.id)) return false;
                existingIds.add(item.id);
                return true;
              }
              return !transactions.any(
                (t) =>
                    t.title == item.title &&
                    t.subtitle == item.subtitle &&
                    t.dateTime == item.dateTime &&
                    t.amount == item.amount,
              );
            }).toList();
            transactions.addAll(uniqueItems);
          }
        } else {
          if (isRefresh || page == 1) {
            transactions.clear();
          }
          isNextPage.value = false;
        }
      } else {
        hasError.value = true;
        errorMessage.value = "Failed to fetch transactions";
      }
    } catch (e) {
      debugPrint('fetchWalletTransactions Error: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }
}

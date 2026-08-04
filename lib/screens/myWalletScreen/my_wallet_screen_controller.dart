import 'package:get/get.dart';

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
}

class MyWalletScreenController extends GetxController {
  final RxDouble balance = 42.50.obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMockTransactions();
  }

  void loadMockTransactions() {
    transactions.value = [
      TransactionModel(
        id: "1",
        title: "Order Payment",
        subtitle: "Order #ORD-00005",
        dateTime: "23-06-26 11:41 AM",
        amount: 250.0,
        isTopup: false,
      ),
      TransactionModel(
        id: "2",
        title: "Topup",
        subtitle: "Order #ORD-00005",
        dateTime: "23-06-26 11:41 AM",
        amount: 300.0,
        isTopup: true,
      ),
    ];
  }
}

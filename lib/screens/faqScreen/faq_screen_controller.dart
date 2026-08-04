import 'package:get/get.dart';

class FAQItem {
  final String question;
  final String answer;
  final RxBool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    bool isExpanded = false,
  }) : isExpanded = isExpanded.obs;
}

class FaqScreenController extends GetxController {
  final faqList = <FAQItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFaqs();
  }

  void _loadFaqs() {
    faqList.assignAll([
      FAQItem(
        question: "How to cancel my order",
        answer:
            "Due to ongoing process and maintainanceDue to ongoing process and maintainance Due to ongoing process and maintainance",
        isExpanded: true,
      ),
      FAQItem(
        question: "How we get refund back?",
        answer:
            "Due to ongoing process and maintainanceDue to ongoing process and maintainance Due to ongoing process and maintainance",
        isExpanded: false,
      ),
      FAQItem(
        question: "Referal Program",
        answer:
            "Due to ongoing process and maintainanceDue to ongoing process and maintainance Due to ongoing process and maintainance",
        isExpanded: false,
      ),
    ]);
  }

  void toggleFaq(FAQItem item) {
    item.isExpanded.value = !item.isExpanded.value;
  }
}

import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

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
  final storage = GetStorage();
  RxBool isLoading = true.obs;
  RxList<FAQItem> faqList = <FAQItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    getFAQList();
  }

  Future<void> getFAQList() async {
    try {
      faqList.clear();
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(ApiServices.getFaqList),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getFAQList Response status: ${response.statusCode}');
      print('getFAQList Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        faqList.assignAll(
          data['data'].map<FAQItem>((e) {
            return FAQItem(
              question: e['question'],
              answer: e['answer'],
              isExpanded: true,
            );
          }).toList(),
        );
      } else {
        faqList.clear();
      }
    } catch (e) {
      print('getFAQList Error: $e');
      faqList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFaq(FAQItem item) {
    item.isExpanded.value = !item.isExpanded.value;
    faqList.refresh();
  }
}

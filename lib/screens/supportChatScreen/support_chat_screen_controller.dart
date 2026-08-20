import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class SupportChatScreenController extends GetxController {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final messagesList = <ChatMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _loadInitialMessages() {
    messagesList.assignAll([
      ChatMessage(
        text:
            "Hi John! How can I help you with your order from The Burger Club?",
        isUser: false,
        time: "08:12 PM",
      ),
      ChatMessage(text: "My order is delayed.", isUser: true, time: "08:13 PM"),
      ChatMessage(
        text:
            "I'm sorry about that! Let me check the status for you. It should be with you in 10 minutes.",
        isUser: false,
        time: "08:14 PM",
      ),
    ]);
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final rawHour = now.hour % 12;
    final hourStr = (rawHour == 0 ? 12 : rawHour).toString().padLeft(2, '0');
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final timeStr = "$hourStr:$minuteStr $period";

    // User outgoing message
    messagesList.add(ChatMessage(text: text, isUser: true, time: timeStr));
    messageController.clear();
    _scrollToBottom();

    // Mock incoming support response
    Timer(const Duration(seconds: 1), () {
      final nowReply = DateTime.now();
      final periodReply = nowReply.hour >= 12 ? 'PM' : 'AM';
      final rawHourReply = nowReply.hour % 12;
      final hourStrReply = (rawHourReply == 0 ? 12 : rawHourReply)
          .toString()
          .padLeft(2, '0');
      final minuteStrReply = nowReply.minute.toString().padLeft(2, '0');
      final timeStrReply = "$hourStrReply:$minuteStrReply $periodReply";

      messagesList.add(
        ChatMessage(
          text:
              "I've informed our rider, he is approaching your location. Thank you for your patience!",
          isUser: false,
          time: timeStrReply,
        ),
      );
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

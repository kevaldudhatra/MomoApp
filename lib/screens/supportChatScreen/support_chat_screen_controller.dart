import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/network/socket_service.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final dynamic id;
  final String text;
  final bool isUser;
  final String time;

  ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    required this.time,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      text: json['message']?.toString() ?? '',
      isUser: json['senderType'] == 'user',
      time: formatMessageTime(json['createdAt']),
    );
  }

  static String formatMessageTime(dynamic value) {
    try {
      final dateTime = DateTime.parse(value.toString()).toLocal();
      return DateFormat('hh:mm a').format(dateTime);
    } catch (_) {
      return value?.toString() ?? '';
    }
  }
}

class SupportChatScreenController extends GetxController {
  StreamSubscription? _chatMessageSubscription;
  StreamSubscription? _reconnectSubscription;
  StreamSubscription? _connectionStateSubscription;
  bool _isSending = false;
  final socketConnectionState = SocketConnectionState.disconnected.obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final currentPage = 1.obs;
  final limit = 20.obs;
  final isNextPage = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final storage = GetStorage();
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final messagesList = <ChatMessage>[].obs;
  final outletId = Get.isRegistered<DeliveryScreenController>()
      ? Get.find<DeliveryScreenController>().outlateDetails['id']
      : 0;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    getMessages(page: 1);
    _initSocketListeners();
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    messageController.dispose();
    scrollController.dispose();
    SocketService().leaveChatRoom();
    _chatMessageSubscription?.cancel();
    _reconnectSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    super.onClose();
  }

  void _initSocketListeners() {
    socketConnectionState.value = SocketService().state;

    _connectionStateSubscription = SocketService().onConnectionStateChanged
        .listen((state) {
          socketConnectionState.value = state;
        });

    SocketService().joinChatRoom();
    _listenToChatMessageUpdate();

    // On reconnect, auto-rejoin chat room and sync latest messages
    _reconnectSubscription = SocketService().onReconnected.listen((_) {
      debugPrint(
        "SupportChatScreenController => Reconnected: syncing messages...",
      );
      SocketService().joinChatRoom();
      getMessages(page: 1, isRefresh: true);
    });
  }

  void _listenToChatMessageUpdate() {
    _chatMessageSubscription = SocketService().onChatMessageReceived.listen((
      data,
    ) {
      debugPrint(
        "📦 Socket chatMessageUpdate received in SupportChatScreenController: $data",
      );
      if (data == null) return;
      try {
        if (data is Map && data.isNotEmpty && data['senderType'] == 'outlate') {
          final newMessage = ChatMessage.fromJson(
            Map<String, dynamic>.from(data),
          );
          final newId = newMessage.id?.toString();
          final alreadyExists = messagesList.any(
            (item) => item.id?.toString() == newId,
          );
          if (!alreadyExists) {
            messagesList.insert(0, newMessage);
            messagesList.refresh();
            update();
          }
        }
      } catch (e) {
        debugPrint("SupportChatScreenController => Error handling message: $e");
      }
    });
  }

  // ----------------------------------------------------------
  // SCROLL LISTENER
  // ----------------------------------------------------------

  void _scrollListener() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    final isNearTop = position.maxScrollExtent - position.pixels <= 100;
    if (isNearTop &&
        !isLoading.value &&
        !isMoreLoading.value &&
        isNextPage.value) {
      getMessages(page: currentPage.value + 1);
    }
  }

  // ----------------------------------------------------------
  // TIME FORMATTER
  // ----------------------------------------------------------

  String formatTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime).toLocal();
      return DateFormat('hh:mm a').format(date);
    } catch (_) {
      return dateTime;
    }
  }

  // ----------------------------------------------------------
  // SCROLL TO BOTTOM (LATEST MESSAGE)
  // ----------------------------------------------------------

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      if (animated) {
        scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(0.0);
      }
    });
  }

  // ----------------------------------------------------------
  // GET MESSAGES
  // ----------------------------------------------------------

  Future<void> getMessages({int page = 1, bool isRefresh = false}) async {
    if (isLoading.value || isMoreLoading.value) return;
    final isFirstPage = page == 1 || isRefresh;

    if (isFirstPage) {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
    } else {
      isMoreLoading.value = true;
    }

    try {
      double distanceFromEnd = 0.0;
      if (!isFirstPage && scrollController.hasClients) {
        final position = scrollController.position;
        distanceFromEnd = position.maxScrollExtent - position.pixels;
      }
      final url = ApiServices.getMessages
          .replaceAll('{pageNumber}', page.toString())
          .replaceAll('{outlateId}', outletId.toString());
      debugPrint('getMessages URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      debugPrint('getMessages Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        _handleGetMessagesError(
          'Failed to fetch messages',
          clearMessages: isFirstPage,
        );
        return;
      }
      final responseData = jsonDecode(response.body);
      if (responseData['success'] != true || responseData['data'] == null) {
        _handleGetMessagesError(
          responseData['message']?.toString() ?? 'Failed to fetch messages',
          clearMessages: isFirstPage,
        );
        return;
      }
      final data = responseData['data'];
      final List<dynamic> rawList = (data['messages'] as List?) ?? [];
      final serverPage = int.tryParse(data['page']?.toString() ?? '') ?? page;
      final serverLimit = int.tryParse(data['limit']?.toString() ?? '') ?? 20;
      final nextPage = data['isNextPage'] == true;
      final newItems = rawList
          .whereType<Map>()
          .map((item) => ChatMessage.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      currentPage.value = serverPage;
      limit.value = serverLimit;
      isNextPage.value = nextPage;

      if (isFirstPage) {
        messagesList.assignAll(_removeDuplicates(newItems));
        _scrollToBottom(animated: false);
      } else {
        final existingIds = messagesList
            .map((message) => message.id?.toString())
            .toSet();
        final uniqueItems = newItems.where((message) {
          final id = message.id?.toString();
          if (id == null || existingIds.contains(id)) {
            return false;
          }
          existingIds.add(id);
          return true;
        }).toList();
        messagesList.addAll(uniqueItems);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!scrollController.hasClients) return;
          final newMaxScrollExtent = scrollController.position.maxScrollExtent;
          final newOffset = newMaxScrollExtent - distanceFromEnd;
          final safeOffset = newOffset.clamp(0.0, newMaxScrollExtent);
          scrollController.jumpTo(safeOffset);
        });
      }
    } catch (e) {
      debugPrint('getMessages Error: $e');
      hasError.value = true;
      errorMessage.value = 'Something went wrong.';
      if (isFirstPage) {
        messagesList.clear();
      }
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  // ----------------------------------------------------------
  // REMOVE DUPLICATE MESSAGES
  // ----------------------------------------------------------

  List<ChatMessage> _removeDuplicates(List<ChatMessage> messages) {
    final uniqueIds = <String>{};
    final result = <ChatMessage>[];
    for (final message in messages) {
      final id = message.id?.toString();
      if (id == null || uniqueIds.add(id)) {
        result.add(message);
      }
    }
    return result;
  }

  // ----------------------------------------------------------
  // ERROR HANDLING
  // ----------------------------------------------------------

  void _handleGetMessagesError(String message, {bool clearMessages = false}) {
    hasError.value = true;
    errorMessage.value = message;
    isNextPage.value = false;
    if (clearMessages) {
      messagesList.clear();
    }
  }

  // ----------------------------------------------------------
  // SEND MESSAGE
  // ----------------------------------------------------------

  Future<void> sendMessage() async {
    if (_isSending) return;
    final message = messageController.text.trim();
    if (message.isEmpty) return;
    _isSending = true;
    try {
      final response = await http.post(
        Uri.parse(ApiServices.sendMessage),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode({'outlateId': outletId, 'message': message}),
      );
      debugPrint('sendMessage Status: ${response.statusCode}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          data['success'] == true &&
          data['data']?['messageData'] != null) {
        final messageData = data['data']['messageData'];
        final newMessage = ChatMessage(
          id: messageData['id'],
          text: messageData['message']?.toString() ?? '',
          isUser: true,
          time: formatTime(messageData['createdAt'].toString()),
        );
        final newId = newMessage.id?.toString();
        final alreadyExists = messagesList.any(
          (item) => item.id?.toString() == newId,
        );
        if (!alreadyExists) {
          messagesList.insert(0, newMessage);
        }
        messageController.clear();
        _scrollToBottom();
      } else {
        _showErrorSnackbar(
          data['message']?.toString() ??
              'Something went wrong. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('sendMessage Error: $e');
      _showErrorSnackbar('Something went wrong. Please try again.');
    } finally {
      _isSending = false;
    }
  }

  // ----------------------------------------------------------
  // ERROR SNACKBAR
  // ----------------------------------------------------------

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Oops!',
      message,
      icon: const Icon(Icons.error, color: Colors.red),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      backgroundColor: charcoalGray.withValues(alpha: 0.9),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/network/socket_service.dart';
import 'package:momos/screens/supportChatScreen/support_chat_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';

class SupportChatScreen extends GetView<SupportChatScreenController> {
  const SupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: background,
        body: Column(
          children: [
            // Top Bar Header
            Container(
              width: double.infinity,
              color: white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    "Momo i AM Support",
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

            // Connection Status Banner
            Obx(() {
              final state = controller.socketConnectionState.value;
              if (state == SocketConnectionState.connected) {
                return const SizedBox.shrink();
              }
              String text = "Connecting...";
              Color color = Colors.orange;
              if (state == SocketConnectionState.reconnecting) {
                text = "Reconnecting to live support...";
                color = Colors.amber.shade800;
              } else if (state == SocketConnectionState.disconnected ||
                  state == SocketConnectionState.error) {
                text = "Chat connection offline. Reconnecting...";
                color = Colors.grey.shade700;
              }
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                color: color,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: natoRegular,
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Message History List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.messagesList.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: orange),
                  );
                }
                final messages = controller.messagesList;
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(
                        color: charcoalGray,
                        fontSize: 14,
                        fontFamily: natoBold,
                      ),
                    ),
                  );
                }
                final showMoreLoader = controller.isMoreLoading.value;
                return ListView.builder(
                  controller: controller.scrollController,
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  itemCount: messages.length + (showMoreLoader ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (showMoreLoader && index == messages.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: orange,
                            ),
                          ),
                        ),
                      );
                    }
                    final msg = messages[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: _buildMessageBubble(context, msg),
                    );
                  },
                );
              }),
            ),

            // Input Box Sticky Footer
            Container(
              color: white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  // Text Input
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderGray, width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: controller.messageController,
                        style: const TextStyle(
                          color: black,
                          fontSize: 14,
                          fontFamily: natoRegular,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            fontFamily: natoRegular,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Send Button
                  GestureDetector(
                    onTap: () => controller.sendMessage(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: orange,
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        AppImages().sendIcon,
                        width: 20,
                        height: 20,
                        color: white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage msg) {
    final isUser = msg.isUser;
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.75;

    return Column(
      crossAxisAlignment: isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // Bubble Body
        Container(
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
          decoration: BoxDecoration(
            color: isUser ? orange : borderGray,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
              bottomRight: isUser ? Radius.zero : const Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            msg.text,
            style: TextStyle(
              color: isUser ? white : black,
              fontSize: 14,
              fontFamily: natoMedium,
              height: 1.3,
            ),
          ),
        ),

        // Timestamp & Status below
        Padding(
          padding: EdgeInsets.only(
            top: 4.0,
            left: isUser ? 0.0 : 4.0,
            right: isUser ? 4.0 : 0.0,
          ),
          child: Text(
            msg.time,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontFamily: natoRegular,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hire_me/app/modules/job_seeker/dashboard/views/widgets/search_widget.dart';
import 'package:hire_me/app/shared/widgets/curved_app_bar.dart';

import 'widgets/chat_tile.dart';
import 'widgets/empty_state.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CurvedAppBar(title: 'Chats'),
            Transform.translate(
              offset: const Offset(0, -28),
              child: SearchBarWidget(
                searchController: controller.searchController,
                onChanged: controller.onSearchChanged,
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final chats = controller.filteredChats;
                if (chats.isEmpty) return const EmptyState();
                return ListView.builder(
                  itemCount: chats.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (_, index) => ChatTile(chat: chats[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

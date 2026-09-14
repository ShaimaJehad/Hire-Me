import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/company_chat_tile.dart';
import 'widgets/company_empty_state.dart';
import '../../../job_seeker/dashboard/views/widgets/search_widget.dart';
import '../../../../../core/utils/app_color.dart';
import '../controllers/company_chat_controller.dart';

class CompanyChatView extends GetView<CompanyChatController> {
  const CompanyChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 50),
            decoration: BoxDecoration(
              color: AppColor.kblue,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Text(
                    'Chats',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Search متداخلة مع الهيدر
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
                  child: CircularProgressIndicator(), // ✅
                );
              }
              final chats = controller.filteredChats;
              if (chats.isEmpty) return const CompanyEmptyState();
              return ListView.builder(
                itemCount: chats.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (_, index) => CompanyChatTile(chat: chats[index]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

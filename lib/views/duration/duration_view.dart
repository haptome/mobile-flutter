// Purpose: Duration page
// Author: haptome H.
// Linked Spec Section: Duration Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/duration_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/ekub_type_card.dart';

class DurationView extends StatelessWidget {
  const DurationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DurationController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'duration'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: AppColors.textDark,
            ),
            onPressed: controller.onFilterTap,
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () {
            if (controller.filteredEkubs.isEmpty) {
              return Center(
                child: Text(
                  'no_ekubs_found'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textLightGray,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: controller.filteredEkubs.length,
              itemBuilder: (context, index) {
                final ekub = controller.filteredEkubs[index];
                return EkubTypeCard(
                  id: ekub['id'] ?? '',
                  name: ekub['name'] ?? '',
                  frequency: ekub['frequency'] ?? '',
                  amount: ekub['amount'] ?? '',
                  duration: ekub['duration'] ?? '',
                  memberCount: ekub['memberCount'] ?? 0,
                  memberAvatars: ekub['memberAvatars'] != null
                      ? List<String>.from(ekub['memberAvatars'] as List)
                      : null,
                  onJoin: () => controller.onJoinEkub(ekub['id'] ?? ''),
                  initiallyExpanded: index == 0, // First card expanded
                );
              },
            );
          },
        ),
      ),
    );
  }
}


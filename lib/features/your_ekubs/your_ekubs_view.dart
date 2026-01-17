// Purpose: Your Ekubs page view
// Author: haptome H.
// Linked Spec Section: Your Ekubs Page

import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/core/widgets/completed_ekub_card.dart';
import 'package:et_digital_equb/core/widgets/ekub_list_item_custom.dart';
import 'package:et_digital_equb/core/widgets/ekub_progress_carousel.dart';
import 'package:et_digital_equb/core/widgets/user_header.dart';
import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/your_ekubs_controller.dart';
import '../../models/group_model.dart';

class YourEkubsView extends StatefulWidget {
  const YourEkubsView({super.key});

  @override
  State<YourEkubsView> createState() => _YourEkubsViewState();
}

class _YourEkubsViewState extends State<YourEkubsView> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<YourEkubsController>();
    final authService = AuthService.to;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  // User Header - Wrap only the user data in Obx
                  Obx(() {
                    final user = authService.currentUser.value;
                    final userName = user?.fullName ?? 'User';
                    final initials =
                        user?.fullName
                            ?.split(' ')
                            .map((n) => n[0])
                            .take(2)
                            .join()
                            .toUpperCase() ??
                        'NB';

                    return UserHeader(
                      userName: userName,
                      userInitials: initials,
                      onRefresh: controller.onCreateEkub,
                    );
                  }),
                  // Ekub Progress Carousel with Loading/Error States
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return _buildSkeletonLoader();
                      }

                      if (controller.errorMessage.value.isNotEmpty &&
                          controller.ekubs.isEmpty) {
                        return _buildErrorWidget(controller);
                      }

                      if (controller.ekubs.isEmpty) {
                        return _buildEmptyState();
                      }

                      // Convert to List for the widget
                      final ekubsList = List<Map<String, dynamic>>.from(
                        controller.ekubs,
                      );
                      return EkubProgressCarousel(
                        ekubs: ekubsList,
                        onEkubTap: controller.onEkubTap,
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  // Ekub List
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.ekubs.isEmpty &&
                          controller.completedEkubs.isEmpty) {
                        return const Center(child: Text('No ekubs to display'));
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await controller.loadUserGroups();
                        },
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          children: [
                            // Active Ekubs List
                            if (controller.ekubs.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                itemCount: controller.ekubs.length,
                                itemBuilder: (context, index) {
                                  final ekubData = controller.ekubs[index];
                                  final group = ekubData['group'];

                                  if (group is Group) {
                                    return EkubListItemCustom.fromGroup(
                                      group,
                                      onTap: () =>
                                          controller.onEkubTap(ekubData['id']),
                                    );
                                  } else if (group is InKindGroup) {
                                    // Convert InKindGroup to a format compatible with EkubListItem
                                    final groupConverted = Group(
                                      id: group.id,
                                      name: group.name,
                                      type: group.type,
                                      contributionAmount:
                                          group.contributionAmount,
                                      frequency: group.frequency,
                                      minMembers: group.minMembers,
                                      targetMembers: group.targetMembers,
                                      currentMembers:
                                          0, // InKindGroup doesn't have currentMembers
                                      rotationMethod: group.rotationMethod,
                                      serviceChargePercent:
                                          group.serviceChargePercent,
                                      status: group.status,
                                      createdAt: group.createdAt,
                                      leaderId: group.leaderId,
                                      categoryId: group.categoryId,
                                      startDate: group.startDate,
                                    );
                                    return EkubListItemCustom.fromGroup(
                                      groupConverted,
                                      onTap: () =>
                                          controller.onEkubTap(ekubData['id']),
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),

                            // Completed Ekubs Collapsible Section
                            if (controller.completedEkubs.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top:
                                      8.0, // Add small space between active ekubs and completed ekubs
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    'Completed Ekubs (${controller.completedEkubs.length})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkTextSecondary,
                                    ),
                                  ),
                                  trailing: Obx(
                                    () => Icon(
                                      controller.showCompletedEkubs.value
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          controller.completedEkubs.length,
                                      itemBuilder: (context, index) {
                                        final ekubData =
                                            controller.completedEkubs[index];
                                        // Calculate duration based on frequency and number of rounds
                                        String duration;
                                        if (ekubData['frequency']
                                            .toLowerCase()
                                            .contains('week')) {
                                          duration =
                                              '${(ekubData['totalRounds'] ~/ 4).toInt()} months';
                                        } else if (ekubData['frequency']
                                            .toLowerCase()
                                            .contains('month')) {
                                          duration =
                                              '${ekubData['totalRounds']} months';
                                        } else {
                                          // daily
                                          duration =
                                              '${(ekubData['totalRounds'] ~/ 30).toInt()} months';
                                        }

                                        return CompletedEkubCard(
                                          id: ekubData['id'],
                                          name: ekubData['title'],
                                          amount: ekubData['amount'],
                                          round: ekubData['completedRounds'],
                                          frequency: ekubData['frequency'],
                                          duration: duration,
                                          totalAmount: ekubData['totalAmount'],
                                          onTap: () => controller.onEkubTap(
                                            ekubData['id'],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                  onExpansionChanged: (bool expanded) {
                                    controller.showCompletedEkubs.value =
                                        expanded;
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(YourEkubsController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 48),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[700]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => controller.loadUserGroups(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.group_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Groups Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join a group to get started!',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

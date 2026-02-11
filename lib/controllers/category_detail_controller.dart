// Purpose: Controller for Category Detail page
// Author: Auto-generated

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/models/category_model.dart' as category_models;
import 'package:et_digital_equb/models/group_model.dart';
import '../core/routes/app_routes.dart';

/// Controller enhancements: support joining a group from category list

class CategoryDetailController extends GetxController {
  final GroupService _groupService = GroupService.to;
  final AuthService _authService = AuthService.to;

  final Rx<category_models.Category> category;
  final RxList<dynamic> groups = <dynamic>[].obs;
  final RxList<String> userGroupIds = <String>[].obs; // Track user's group IDs
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isKindGroup = false.obs; // Track if we're showing in-kind groups

  CategoryDetailController({required category_models.Category category})
    : category = category.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Listen to authentication state changes
    ever(_authService.isAuthenticated, (isAuth) {
      if (isAuth) {
        loadUserGroupIds(); // Load user's groups first
        loadGroups();
      } else {
        groups.clear();
        userGroupIds.clear();
      }
    });
    
    // Also load data immediately if already authenticated
    if (_authService.isAuthenticated.value) {
      loadUserGroupIds(); // Load user's groups first
      loadGroups();
    }
  }

  /// Load user's group IDs to check membership
  Future<void> loadUserGroupIds() async {
    try {
      final user = _authService.currentUser.value;
      if (user?.id == null) return;

      // Fetch user's cash groups
      final cashGroupsResponse = await _groupService.getUserGroups(
        userId: user!.id,
        limit: 100,
      );

      // Fetch user's in-kind groups
      final inKindGroupsResponse = await _groupService.getUserInKindGroups();

      final List<String> ids = [];

      // Add cash group IDs
      if (cashGroupsResponse.success && cashGroupsResponse.data != null) {
        ids.addAll(cashGroupsResponse.data!.map((g) => g.id));
      }

      // Add in-kind group IDs
      if (inKindGroupsResponse.success && inKindGroupsResponse.data != null) {
        ids.addAll(inKindGroupsResponse.data!.map((g) => g.id));
      }

      userGroupIds.value = ids;
    } catch (e) {
      // Silently fail - user just won't see membership status
      if (kDebugMode) {
        print('Error loading user groups: $e');
      }
    }
  }

  /// Check if user is a member of a group
  bool isUserMember(dynamic group) {
    final groupId = group is Group ? group.id : (group as InKindGroup).id;
    return userGroupIds.contains(groupId);
  }

  Future<void> loadGroups() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check if this is an in-kind category
      if (category.value.categoryType == 'in_kind') {
        isKindGroup.value = true;
        // Load in-kind groups
        final response = await _groupService.getInKindGroups(
          categoryId: category.value.id,
          status: 'active', // Only show active groups
        );

        if (response.success && response.data != null) {
          groups.value = response.data!;
        } else {
          errorMessage.value =
              response.message ?? 'Failed to load in-kind groups';
        }
      } else {
        isKindGroup.value = false;
        // Load regular cash groups
        final response = await _groupService.getGroups(
          categoryId: category.value.id,
          status: 'active', // Only show active groups
        );

        if (response.success && response.data != null) {
          groups.value = response.data!;
        } else {
          errorMessage.value = response.message ?? 'Failed to load groups';
        }
      }
    } catch (e) {
      errorMessage.value = 'Error loading groups: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void onGroupTap(dynamic group) {
    // Route to the appropriate detail page based on group type
    if (group is InKindGroup) {
      Get.toNamed(AppRoutes.inKindDetail, arguments: group);
    } else {
      Get.toNamed(AppRoutes.groupDetail, arguments: group);
    }
  }

  Future<void> onJoinTap(dynamic group) async {
    // Show bottom sheet with terms and conditions
    final result = await Get.bottomSheet<Map<String, dynamic>>(
      _JoinGroupBottomSheet(group: group),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );

    if (result == null || result['confirmed'] != true) return;

    try {
      isLoading.value = true;

      final resp = await _groupService.joinGroup(group.id, acceptTerms: true);

      if (resp.success) {
        Get.snackbar('Joined', resp.message ?? 'Successfully joined group');
        // Reload user group IDs to update membership status
        await loadUserGroupIds();
        // Navigate to appropriate detail page based on group type
        if (group is InKindGroup) {
          Get.toNamed(AppRoutes.inKindDetail, arguments: group);
        } else {
          Get.toNamed(AppRoutes.groupDetail, arguments: group);
        }
      } else {
        Get.snackbar('Join failed', resp.message ?? 'Failed to join group');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to join group: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

// Join Group Bottom Sheet Widget
class _JoinGroupBottomSheet extends StatefulWidget {
  final dynamic group;

  const _JoinGroupBottomSheet({required this.group});

  @override
  State<_JoinGroupBottomSheet> createState() => _JoinGroupBottomSheetState();
}

class _JoinGroupBottomSheetState extends State<_JoinGroupBottomSheet> {
  bool termsAccepted = false;

  String _generateGroupRules() {
    final group = widget.group;
    String rules = '';
    
    // Contribution details
    rules += '1. Contribution Amount: ETB ${group.contributionAmount}\n';
    rules += '   - Each member must contribute ETB ${group.contributionAmount} ${group.frequency}.\n\n';
    
    // Frequency
    String frequencyText = group.frequency == 'weekly' ? 'every week' : 'every month';
    rules += '2. Contribution Frequency: ${group.frequency[0].toUpperCase()}${group.frequency.substring(1)}\n';
    rules += '   - Contributions are due $frequencyText.\n\n';
    
    // Service charge
    rules += '3. Service Charge: ${group.serviceChargePercent}%\n';
    rules += '   - A service charge of ${group.serviceChargePercent}% will be applied to each payout.\n\n';
    
    // Rotation method
    rules += '4. Rotation Method: ${_getRotationMethodName(group.rotationMethod)}\n';
    rules += '   - ${_getRotationMethodDescription(group.rotationMethod)}\n\n';
    
    // Target and minimum members
    rules += '5. Group Size:\n';
    rules += '   - Target members: ${group.targetMembers}\n';
    rules += '   - Minimum members to start: ${group.minMembers}\n\n';
    
    // Additional rules
    rules += '6. General Rules:\n';
    rules += '   - Late payments may result in penalties as decided by the group.\n';
    rules += '   - All members must maintain transparency and honesty.\n';
    rules += '   - Disputes will be resolved through group consensus.\n';
    rules += '   - Members who miss payments may be removed from the group.';
    
    return rules;
  }

  String _getRotationMethodName(String method) {
    switch (method) {
      case 'me_first':
        return 'Me First';
      case 'random':
        return 'Random';
      case 'sequential':
        return 'Sequential';
      case 'bidding':
        return 'Bidding';
      default:
        return method[0].toUpperCase() + method.substring(1);
    }
  }

  String _getRotationMethodDescription(String method) {
    switch (method) {
      case 'me_first':
        return 'The group creator will receive the first payout. After that, the remaining members will be selected randomly for subsequent rounds.';
      case 'random':
        return 'The payout order will be determined randomly through a draw. Each member has an equal chance of being selected for each round.';
      case 'sequential':
        return 'Members will receive payouts in a predetermined sequential order based on when they joined the group.';
      case 'bidding':
        return 'Members can bid for their turn to receive the payout. The highest bidder for each round will receive the payout for that round.';
      default:
        return 'The rotation method will determine the order in which members receive payouts.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Join ${widget.group.name}',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Terms and Conditions Section
                  Text(
                    'Terms and Conditions',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: const Color(0xFFD8DADC), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Text(
                        'By joining this group, you agree to:\n\n'
                        '1. Ensure all contributions are made on time\n'
                        '2. Follow the rotation method selected by the group\n'
                        '3. Maintain transparency in all transactions\n'
                        '4. Resolve disputes fairly and promptly\n'
                        '5. Comply with all applicable laws and regulations\n\n'
                        'Additional terms may apply based on the group rules below.',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Group Rules Section
                  Text(
                    'Group Rules',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: const Color(0xFFD8DADC), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Text(
                        _generateGroupRules(),
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Terms acceptance checkbox and buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: termsAccepted,
                        onChanged: (value) {
                          setState(() {
                            termsAccepted = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFFBBBB32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'I agree to the group terms and conditions',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: const Color(0xFFD8DADC)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: termsAccepted
                              ? () => Get.back(result: {'confirmed': true})
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: termsAccepted
                                ? const Color(0xFFBBBB32)
                                : const Color(0xFFBBBB32).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Join',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

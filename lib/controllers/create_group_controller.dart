// Purpose: Controller for Create Group page with stepper functionality
// Author: Created for Ekub app

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/api_service.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/models/category_model.dart';
import 'package:et_digital_equb/core/routes/app_routes.dart';
import 'package:et_digital_equb/controllers/your_ekubs_controller.dart';

class CreateGroupController extends GetxController {
  final GroupService _groupService = GroupService.to;

  // Stepper state
  final RxInt currentStep = 0.obs;
  final int totalSteps = 3; // Total number of steps in the stepper

  // Progress tracking
  final RxDouble progressPercentage = 0.0.obs;

  // Group creation data
  final RxString groupName = ''.obs;
  final RxInt contributionAmount = 0.obs;
  final RxString frequency = 'weekly'.obs; // weekly, monthly
  final RxInt targetMembers = 0.obs;
  final RxInt minMembers = 3.obs; // Default minimum members
  final RxString groupType =
      'private'.obs; // private, invite only (not public for members)
  final RxString rotationMethod = 'random'.obs; // random, sequential, bidding
  final RxDouble serviceChargePercent = 4.76.obs; // Default service charge
  final Rx<DateTime?> startDate = Rx<DateTime?>(null); // Optional start date
  final RxInt durationInMonths = 0.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxBool isLoadingCategories = false.obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxString groupRules = ''.obs; // Group rules text
  final RxBool termsAccepted = false.obs; // Terms acceptance checkbox

  // Validation states
  final RxBool isGroupNameValid = true.obs;
  final RxBool isAmountValid = true.obs;
  final RxBool isTargetValid = true.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Step validation
  bool get isStep1Valid => groupName.isNotEmpty && isGroupNameValid.isTrue;
  bool get isStep2Valid =>
      contributionAmount.value > 0 &&
      targetMembers.value > 0 &&
      isAmountValid.isTrue &&
      isTargetValid.isTrue;
  bool get isStep3Valid =>
      termsAccepted.value; // Step 3 requires terms acceptance

  // Move to next step
  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
      updateProgress();
      // Auto-generate group rules when entering Step 3
      if (currentStep.value == 2) {
        generateGroupRules();
      }
    } else {
      // Final step - create group
      createGroup();
    }
  }

  // Check if current step is valid
  bool isCurrentStepValid() {
    if (currentStep.value == 0) {
      return groupName.isNotEmpty && groupName.value.length >= 3;
    } else if (currentStep.value == 1) {
      return contributionAmount.value > 0 &&
          targetMembers.value > 0 &&
          minMembers.value > 0 &&
          targetMembers.value >= minMembers.value; // Validate target >= min
    } else {
      // Step 3 requires terms acceptance
      return termsAccepted.value;
    }
  }

  // Move to previous step
  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      updateProgress();
    }
  }

  // Validate step 1 (Basic Information)
  void validateStep1() {
    isGroupNameValid.value =
        groupName.isNotEmpty && groupName.value.length >= 3;
  }

  // Validate step 2 (Financial Settings)
  void validateStep2() {
    isAmountValid.value = contributionAmount.value > 0;
    isTargetValid.value =
        targetMembers.value > 1 && targetMembers.value <= 50; // Max 50 members
  }

  // Create the group
  Future<bool> createGroup() async {
    try {
      isLoading.value = true;

      // Prepare the group data
      final createGroupData = {
        'name': groupName.value,
        'contribution_amount': contributionAmount.value,
        'frequency': frequency.value,
        'target_members': targetMembers.value,
        'type': groupType.value, // private or invite (not public)
        'leader_id':
            'CURRENT_USER_ID', // This should be replaced with actual logged in user ID
      };

      print(createGroupData);
      // Get the current user ID from the API service
      final apiService = ApiService.to;
      final currentUserId = await apiService.getCurrentUserId();

      if (currentUserId == null) {
        Get.snackbar(
          'Error',
          'Unable to get current user information. Please log in again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Create the group via API
      final response = await _groupService.createGroup(
        name: groupName.value,
        contributionAmount: contributionAmount.value,
        frequency: frequency.value,
        targetMembers: targetMembers.value,
        minMembers: minMembers.value,
        type: groupType.value,
        rotationMethod: rotationMethod.value,
        // serviceChargePercent & categoryId omitted — handled server-side
        startDate: startDate.value?.toIso8601String(),
      );

      if (response.success) {
        // Reset form after successful creation
        resetForm();

        // Eagerly refresh "Your Ekubs" list before navigating so the new group
        // is already loaded when the screen appears (avoids showing empty state).
        if (Get.isRegistered<YourEkubsController>()) {
          Get.find<YourEkubsController>().loadUserGroups();
        }

        // Navigate to ekubs tab after successful creation
        Get.offAndToNamed(AppRoutes.ekubs); // Navigate directly to ekubs tab

        Get.snackbar(
          'Success',
          'Group created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      } else {
        // Handle API error
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to create group',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Reset the form
  void resetForm() {
    currentStep.value = 0;
    groupName.value = '';
    contributionAmount.value = 0;
    frequency.value = 'weekly';
    targetMembers.value = 0;
    minMembers.value = 3;
    groupType.value = 'private';
    rotationMethod.value = 'random';
    serviceChargePercent.value = 4.76; // reset to platform default
    selectedCategoryId.value = ''; // clear category so form starts empty
    startDate.value = null;
    durationInMonths.value = 0;
    groupRules.value = '';
    termsAccepted.value = false;

    // Reset validations
    isGroupNameValid.value = true;
    isAmountValid.value = true;
    isTargetValid.value = true;
  }

  // Update group name
  void updateGroupName(String name) {
    groupName.value = name;
    validateStep1();
  }

  // Update contribution amount
  void updateContributionAmount(int amount) {
    contributionAmount.value = amount;
    validateStep2();
  }

  // Update frequency
  void updateFrequency(String freq) {
    frequency.value = freq;
  }

  // Update target members
  void updateTargetMembers(int members) {
    targetMembers.value = members;
    validateStep2();
  }

  // Update group type
  void updateGroupType(String type) {
    groupType.value = type;
  }

  // Update minimum members
  void updateMinMembers(int members) {
    minMembers.value = members;
  }

  // Update rotation method
  void updateRotationMethod(String method) {
    rotationMethod.value = method;
  }

  // Update start date
  void updateStartDate(DateTime? date) {
    startDate.value = date;
  }

  // Update selected category
  void updateSelectedCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
  }

  // Generate group rules based on the group settings
  void generateGroupRules() {
    String rules = '';
    
    // Contribution details
    rules += '1. Contribution Amount: ${'etb'.tr} ${contributionAmount.value}\n';
    rules += '   - Each member must contribute ${'etb'.tr} ${contributionAmount.value} ${frequency.value}.\n\n';
    
    // Frequency
    String frequencyText = frequency.value == 'weekly' ? 'every week' : 'every month';
    rules += '2. Contribution Frequency: ${frequency.value.capitalize}\n';
    rules += '   - Contributions are due $frequencyText.\n\n';
    
    // Service charge
    rules += '3. Service Charge: ${serviceChargePercent.value}%\n';
    rules += '   - A service charge of ${serviceChargePercent.value}% will be applied to each payout.\n\n';
    
    // Rotation method
    rules += '4. Rotation Method: ${_getRotationMethodName()}\n';
    rules += '   - ${_getRotationMethodDescription()}\n\n';
    
    // Target and minimum members
    rules += '5. Group Size:\n';
    rules += '   - Target members: ${targetMembers.value}\n';
    rules += '   - Minimum members to start: ${minMembers.value}\n\n';
    
    // Additional rules
    rules += '6. General Rules:\n';
    rules += '   - Late payments may result in penalties as decided by the group.\n';
    rules += '   - All members must maintain transparency and honesty.\n';
    rules += '   - Disputes will be resolved through group consensus.\n';
    rules += '   - Members who miss payments may be removed from the group.';
    
    groupRules.value = rules;
  }

  // Get formatted rotation method name
  String _getRotationMethodName() {
    switch (rotationMethod.value) {
      case 'me_first':
        return 'Me First';
      case 'random':
        return 'Random';
      case 'sequential':
        return 'Sequential';
      case 'bidding':
        return 'Bidding';
      default:
        return rotationMethod.value.capitalize ?? 'Unknown';
    }
  }

  // Get rotation method description
  String _getRotationMethodDescription() {
    switch (rotationMethod.value) {
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

  // Update group rules
  void updateGroupRules(String rules) {
    groupRules.value = rules;
  }

  // Update terms acceptance
  void updateTermsAccepted(bool accepted) {
    termsAccepted.value = accepted;
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      final response = await _groupService.getCategories(categoryType: 'cash');
      if (response.success && response.data != null) {
        categories.assignAll(response.data!);
      }
    } catch (e) {
      print('Error loading categories: \\$e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Calculate progress percentage
  double getProgressPercentage() {
    if (totalSteps <= 0) return 0.0;
    return ((currentStep.value + 1) / totalSteps) * 100.0;
  }

  // Get current progress as a value between 0 and 1
  double getProgressValue() {
    if (totalSteps <= 0) return 0.0;
    return (currentStep.value + 1) / totalSteps;
  }

  // Get step titles
  List<String> getStepTitles() {
    return ['Basic Information', 'Financial Settings', 'Review & Confirm'];
  }

  // Get current step title
  String getCurrentStepTitle() {
    final titles = getStepTitles();
    if (currentStep.value >= 0 && currentStep.value < titles.length) {
      return titles[currentStep.value];
    }
    return 'Step ${currentStep.value + 1}';
  }

  // Get step subtitles or descriptions
  List<String> getStepSubtitles() {
    return [
      'Enter group name and type',
      'Set contribution and member details',
      'Review group information',
    ];
  }

  // Get current step subtitle
  String getCurrentStepSubtitle() {
    final subtitles = getStepSubtitles();
    if (currentStep.value >= 0 && currentStep.value < subtitles.length) {
      return subtitles[currentStep.value];
    }
    return 'Step details';
  }

  // Update progress percentage when step changes
  void updateProgress() {
    progressPercentage.value = getProgressValue();
  }

  // Initialize progress when controller is created
  @override
  void onInit() {
    super.onInit();
    updateProgress();
    loadCategories(); // Load categories when controller is initialized
  }
}

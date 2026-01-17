// Purpose: Controller for Create Group page with stepper functionality
// Author: Created for Ekub app

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:et_digital_equb/core/services/api_service.dart';
import 'package:et_digital_equb/core/services/group_service.dart';
import 'package:et_digital_equb/models/group_model.dart';
import 'package:et_digital_equb/models/category_model.dart';
import 'package:et_digital_equb/core/routes/app_routes.dart';

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
      true; // Step 3 is always valid since it's just confirmation

  // Move to next step
  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
      updateProgress();
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
      // Step 2 is always valid to proceed (final review step)
      return true;
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

      // Calculate duration in months based on frequency
      int calculatedDuration = 0;
      if (frequency.value == 'weekly') {
        // For weekly groups: duration = targetMembers / 4 (approx weeks in a month)
        calculatedDuration = (targetMembers.value ~/ 4);
        if (targetMembers.value % 4 != 0) calculatedDuration++; // Round up
      } else {
        // For monthly groups: duration = targetMembers
        calculatedDuration = targetMembers.value;
      }

      // Prepare the group data
      final createGroupData = {
        'name': groupName.value,
        'contribution_amount': contributionAmount.value,
        'frequency': frequency.value,
        'target_members': targetMembers.value,
        'type': groupType.value, // private or invite (not public)
        'leader_id':
            'CURRENT_USER_ID', // This should be replaced with actual logged in user ID
        // 'duration_months': calculatedDuration,
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
        serviceChargePercent: serviceChargePercent.value,
        startDate: startDate.value?.toIso8601String(),
        leaderId: currentUserId,
        categoryId: selectedCategoryId.value.isEmpty
            ? null
            : selectedCategoryId.value,
        // durationMonths: calculatedDuration,
      );

      if (response.success) {
        // Reset form after successful creation
        resetForm();

        // Navigate to ekubs tab after successful creation
        // Navigate back to ekubs tab
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
    groupType.value = 'private';
    durationInMonths.value = 0;

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

  // Update service charge percentage
  void updateServiceChargePercent(double percent) {
    serviceChargePercent.value = percent;
  }

  // Update start date
  void updateStartDate(DateTime? date) {
    startDate.value = date;
  }

  // Update selected category
  void updateSelectedCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
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

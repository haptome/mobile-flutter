// Purpose: Create Group page with 3-step form and Figma design implementation
// Author: Created for Ekub app

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:et_digital_equb/core/theme/app_sizes.dart';
import 'package:et_digital_equb/controllers/create_group_controller.dart';
import 'package:et_digital_equb/core/widgets/equb_membership_agreement.dart';
import 'package:et_digital_equb/core/widgets/scaffold_with_bottom_bar.dart';
import 'package:et_digital_equb/controllers/language_controller.dart';
import 'package:et_digital_equb/core/utils/ethiopian_date.dart';

class CreateGroupView extends StatefulWidget {
  const CreateGroupView({super.key});

  @override
  State<CreateGroupView> createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  // Text editing controllers for each step
  final _groupNameController = TextEditingController();
  final _groupPurposeController = TextEditingController();
  final _contributionAmountController = TextEditingController();
  final _targetMembersController = TextEditingController();
  final _minMembersController = TextEditingController();
  final _serviceChargeController = TextEditingController();
  final _groupRulesController = TextEditingController();

  // Always create a fresh GetX controller so the form never opens with stale
  // state (e.g. a category that was selected in a previous session).
  late final CreateGroupController _gxController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<CreateGroupController>()) {
      Get.delete<CreateGroupController>(force: true);
    }
    _gxController = Get.put(CreateGroupController());
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupPurposeController.dispose();
    _contributionAmountController.dispose();
    _targetMembersController.dispose();
    _minMembersController.dispose();
    _serviceChargeController.dispose();
    _groupRulesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _gxController;

    return ScaffoldWithBottomBar(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFFFFFF),
                const Color(0xD9FFFFFF).withOpacity(0.85),
                const Color(0xE6FFFFFF).withOpacity(0.9),
                const Color(0xFFFFFFFF),
              ],
              stops: const [0.0093, 0.1247, 0.2386, 0.3381],
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Obx(
                      () => controller.currentStep.value > 0
                          ? IconButton(
                              icon: Transform.rotate(
                                angle:
                                    -90 *
                                    3.141592653589793 /
                                    180, // -90 degrees in radians
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.black,
                                ),
                              ),
                              onPressed: () => controller.prevStep(),
                            )
                          : IconButton(
                              icon: Transform.rotate(
                                angle:
                                    -90 *
                                    3.141592653589793 /
                                    180, // -90 degrees in radians
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.black,
                                ),
                              ),
                              onPressed: () => Get.back(),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'create_new_ekub_group'.tr,
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'fill_details_create_group'.tr,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() {
                      // Calculate progress as "X of Y" format
                      int currentStepIndex = controller.currentStep.value;
                      int totalSteps = 3;
                      String stepText =
                          '${currentStepIndex + 1} of $totalSteps Completed';

                      return Text(
                        stepText,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF666666),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Container(
                      height: 6,
                      width: double.infinity, // Make it full width
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAE7E1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Obx(() {
                            double progressWidth =
                                constraints.maxWidth *
                                controller.progressPercentage.value;
                            print(progressWidth);
                            return LinearProgressIndicator(
                              backgroundColor: const Color(0xFFEAE7E1),
                              valueColor: AlwaysStoppedAnimation(
                                const Color(0xFFBBBB32),
                              ),
                              value: controller.progressPercentage.value,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusCircular,
                              ),
                            );
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Step content based on current step
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Obx(() {
                          String stepTitle = '';
                          switch (controller.currentStep.value) {
                            case 0:
                              stepTitle = 'basic_information'.tr;
                              break;
                            case 1:
                              stepTitle = 'financial_settings'.tr;
                              break;
                            case 2:
                              stepTitle = 'Review & Create';
                              break;
                          }
                          return Text(
                            stepTitle,
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          );
                        }),
                      ),

                      Expanded(
                        child: Obx(() {
                          switch (controller.currentStep.value) {
                            case 0:
                              return _buildStep1Content(controller);
                            case 1:
                              return _buildStep2Content(controller);
                            case 2:
                              return _buildStep3Content(controller);
                            default:
                              return _buildStep1Content(controller);
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Obx(() {
                  bool isLastStep = controller.currentStep.value == 2;
                  bool canProceed = controller.isCurrentStepValid();
                  bool isLoading = controller.isLoading.value;

                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (canProceed && !isLoading)
                          ? (isLastStep
                                ? () => controller.createGroup()
                                : () => controller.nextStep())
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (canProceed && !isLoading)
                            ? const Color(0xFFBBBB32)
                            : const Color(0xFFBBBB32).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              isLastStep ? 'create_group'.tr : 'continue'.tr,
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1Content(CreateGroupController controller) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Name
          const SizedBox(height: 8),
          Text(
            'group_name_required'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _groupNameController,
            decoration: InputDecoration(
              hintText: 'enter_group_name'.tr,
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) => controller.updateGroupName(value),
          ),

          // Group Purpose
          const SizedBox(height: 12),
          Text(
            'equb_purpose_required'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _groupPurposeController,
            decoration: InputDecoration(
              hintText: 'enter_group_purpose'.tr,
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Content(CreateGroupController controller) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contribution Amount
          const SizedBox(height: 8),
          Text(
            'contribution_amount_required'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _contributionAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'enter_contribution_amount'.tr,
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              prefixText: '${'etb'.tr} ',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                controller.updateContributionAmount(int.tryParse(value) ?? 0);
              }
            },
          ),

          // Category is not shown to the user — it's always null when creating
          // a group. The backend accepts groups without a category.

          // Frequency
          const SizedBox(height: 12),
          Text(
            'contribution_frequency_required'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD8DADC), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(
              () => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: controller.frequency.value,
                  hint: Text(
                    'select_frequency'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  items: <String>['weekly', 'monthly']
                      .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value[0].toUpperCase() + value.substring(1),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      })
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.updateFrequency(newValue);
                    }
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  iconSize: 14,
                ),
              ),
            ),
          ),

          // Target Members
          const SizedBox(height: 12),
          Text(
            'target_members_required'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _targetMembersController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'enter_target_members'.tr,
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                controller.updateTargetMembers(int.tryParse(value) ?? 0);
              }
            },
          ),

          // Minimum Members
          const SizedBox(height: 12),
          Text(
            'minimum_members_required'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _minMembersController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'enter_minimum_members'.tr,
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                controller.updateMinMembers(int.tryParse(value) ?? 3);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Content(CreateGroupController controller) {
    // Pre-fill the service charge field with the current platform value on first
    // render of step 3, so the user sees 4.76 rather than an empty box.
    if (_serviceChargeController.text.isEmpty) {
      _serviceChargeController.text =
          controller.serviceChargePercent.value.toString();
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Type
          const SizedBox(height: 8),
          Text(
            'group_type_required'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD8DADC), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(
              () => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: controller.groupType.value,
                  hint: Text(
                    'select_group_type'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  items: <String>['private']
                      .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value[0].toUpperCase() + value.substring(1),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      })
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.updateGroupType(newValue);
                    }
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  iconSize: 14,
                ),
              ),
            ),
          ),

          // Rotation Method
          const SizedBox(height: 12),
          Text(
            'rotation_method_required'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD8DADC), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(
              () => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: controller.rotationMethod.value,
                  hint: Text(
                    'select_rotation_method'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  items: <String>['random', 'sequential', 'me_first', 'bidding']
                      .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value == 'me_first' 
                              ? 'me_first'.tr 
                              : value[0].toUpperCase() + value.substring(1),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      })
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.updateRotationMethod(newValue);
                    }
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  iconSize: 14,
                ),
              ),
            ),
          ),

          // Service Charge Percent (platform-enforced, read-only)
          const SizedBox(height: 12),
          Text(
            'service_charge_required'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _serviceChargeController,
            readOnly: true,
            decoration: InputDecoration(
              suffixText: '%',
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
          ),

          // Start Date
          const SizedBox(height: 12),
          Text(
            'start_date_label'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                controller.updateStartDate(pickedDate);
              }
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD8DADC), width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => Text(
                        controller.startDate.value != null
                            ? formatStartDate(
                                controller.startDate.value!,
                                amharic: Get.find<LanguageController>()
                                        .currentLocale
                                        .value
                                        .languageCode ==
                                    'am',
                              )
                            : 'select_start_date'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: controller.startDate.value != null
                              ? Colors.black
                              : Colors.black.withOpacity(0.5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),

          // Rules & Terms Section
          const SizedBox(height: 24),
          Text(
            'Rules & Terms',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          
          // Group Rules TextField
          Text(
            'group_rules'.tr,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Container(

            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Obx(
              () {
                // Update the controller text when groupRules changes
                if (_groupRulesController.text != controller.groupRules.value) {
                  _groupRulesController.text = controller.groupRules.value;
                  _groupRulesController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _groupRulesController.text.length),
                  );
                }
                return TextField(
                  controller: _groupRulesController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'group_rules_auto_generated'.tr,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  onChanged: (value) => controller.updateGroupRules(value),
                );
              },
            ),
          ),

          // Terms and Conditions Checkbox
          const SizedBox(height: 16),
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: controller.termsAccepted.value,
                    onChanged: (value) {
                      controller.updateTermsAccepted(value ?? false);
                    },
                    activeColor: const Color(0xFFBBBB32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Show the Amharic membership agreement
                      _showTermsAndConditions(context, controller);
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(text: 'i_agree_to_the'.tr + ' '),
                          TextSpan(
                            text: 'group_terms_conditions'.tr,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: const Color(0xFFBBBB32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showTermsAndConditions(
      BuildContext context, CreateGroupController controller) async {
    final tcText = buildCashEqubTc(
      groupName: controller.groupName.value.isEmpty
          ? 'ዕቁቡ'
          : controller.groupName.value,
      contributionAmount: controller.contributionAmount.value.toDouble(),
      targetMembers: controller.targetMembers.value,
      frequency: controller.frequency.value,
      serviceChargePercent: controller.serviceChargePercent.value,
      startDate: controller.startDate.value,
    );

    final accepted = await showEqubMembershipAgreement(context, tcText);
    if (accepted) {
      controller.updateTermsAccepted(true);
    }
  }
}

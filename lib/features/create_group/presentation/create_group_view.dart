// Purpose: Create Group page with 3-step form and Figma design implementation
// Author: Created for Ekub app

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:et_digital_equb/core/theme/app_sizes.dart';
import 'package:et_digital_equb/controllers/create_group_controller.dart';

class CreateGroupView extends StatelessWidget {
  const CreateGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<CreateGroupController>()
        ? Get.find<CreateGroupController>()
        : Get.put(CreateGroupController());

    return Scaffold(
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
                            'Create New Ekub Group',
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Fill in the details to create a new Equb group.',
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            return Container(
                              width: progressWidth,
                              decoration: BoxDecoration(
                                color: const Color(0xFFBBBB32), // Primary color
                                borderRadius: BorderRadius.circular(3),
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
                              stepTitle = 'Basic Information';
                              break;
                            case 1:
                              stepTitle = 'Financial Settings';
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

                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: canProceed
                          ? (isLastStep
                                ? () => controller.createGroup()
                                : () => controller.nextStep())
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canProceed
                            ? const Color(0xFFBBBB32)
                            : const Color(0xFFBBBB32).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isLastStep ? 'Create Group' : 'Continue',
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
            'Group Name *',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter group name',
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
            'Equb Purpose *',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter group purpose',
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
            'Contribution Amount *',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter contribution amount',
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              prefixText: 'ETB ',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                controller.updateContributionAmount(int.tryParse(value) ?? 0);
              }
            },
          ),

          // Frequency
          const SizedBox(height: 12),
          Text(
            'Contribution Frequency *',
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
                    'Select frequency',
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
            'Target Members *',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter target members',
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
            'Minimum Members *',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter minimum members',
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Type
          const SizedBox(height: 8),
          Text(
            'Group Type *',
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
                    'Select group type',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  items: <String>['private', 'invite']
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
            'Rotation Method *',
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
                    'Select rotation method',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  items: <String>['random', 'sequential', 'bidding']
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

          // Service Charge Percent
          const SizedBox(height: 12),
          Text(
            'Service Charge (%) *',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter service charge',
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              suffixText: '%',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                controller.updateServiceChargePercent(
                  double.tryParse(value) ?? 4.76,
                );
              }
            },
          ),

          // Start Date
          const SizedBox(height: 12),
          Text(
            'Start Date',
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
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.startDate.value != null
                          ? '${controller.startDate.value!.day}/${controller.startDate.value!.month}/${controller.startDate.value!.year}'
                          : 'Select start date',
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
          GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: Get.context!,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                controller.updateStartDate(pickedDate);
              }
            },
            child: Container(),
          ),
        ],
      ),
    );
  }
}

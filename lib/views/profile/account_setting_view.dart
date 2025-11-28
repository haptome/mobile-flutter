// Purpose: Account Setting page
// Author: haptome H.
// Linked Spec Section: Account Setting Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/account_setting_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/profile_picture_selector.dart';
import '../../widgets/form_field_widget.dart';
import '../../widgets/country_code_widget.dart';
import '../../widgets/primary_button.dart';

class AccountSettingView extends StatelessWidget {
  const AccountSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountSettingController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'account_setting'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'manage_personal_account'.tr,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLightGray,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Profile Picture
                ProfilePictureSelector(
                  imageUrl: controller.profileImageUrl.value,
                  onTap: controller.onSelectPhoto,
                ),
                const SizedBox(height: 40),
                // Full Name
                FormFieldWidget(
                  label: 'full_name'.tr,
                  value: controller.fullName.value,
                  hintText: 'enter_full_name'.tr,
                  onChanged: (value) => controller.fullName.value = value,
                ),
                const SizedBox(height: 20),
                // Phone Number
                FormFieldWidget(
                  label: 'phone_number'.tr,
                  value: controller.phoneNumber.value,
                  hintText: 'enter_phone_number'.tr,
                  prefix: const CountryCodeWidget(),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => controller.phoneNumber.value = value,
                ),
                const SizedBox(height: 20),
                // Registered ID
                FormFieldWidget(
                  label: 'registered_id'.tr,
                  value: controller.registeredId.value,
                  hintText: 'enter_registered_id'.tr,
                  keyboardType: TextInputType.text,
                  onChanged: (value) => controller.registeredId.value = value,
                ),
                const SizedBox(height: 20),
                // Location
                FormFieldWidget(
                  label: 'location'.tr,
                  value: controller.location.value,
                  hintText: 'select_location'.tr,
                  isDropdown: true,
                  onTap: controller.onLocationTap,
                ),
                const SizedBox(height: 20),
                // Occupation
                FormFieldWidget(
                  label: 'occupation'.tr,
                  value: controller.occupation.value,
                  hintText: 'select_occupation'.tr,
                  isDropdown: true,
                  onTap: controller.onOccupationTap,
                ),
                const SizedBox(height: 40),
                // Save Change Button
                PrimaryButton(
                  text: 'save_change'.tr,
                  onPressed: controller.onSaveChanges,
                  isLoading: controller.isSaving.value,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

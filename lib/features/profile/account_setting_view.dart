// Purpose: Account Setting page
// Author: haptome H.
// Linked Spec Section: Account Setting Page

import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:et_digital_equb/core/widgets/country_code_widget.dart';
import 'package:et_digital_equb/core/widgets/custom_back_button.dart';
import 'package:et_digital_equb/core/widgets/form_field_widget.dart';
import 'package:et_digital_equb/core/widgets/profile_picture_selector.dart';
import 'package:et_digital_equb/core/widgets/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/account_setting_controller.dart';
import 'package:et_digital_equb/core/widgets/app_button.dart';
import 'package:et_digital_equb/core/widgets/scaffold_with_bottom_bar.dart';

class AccountSettingView extends StatelessWidget {
  const AccountSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountSettingController>();

    return ScaffoldWithBottomBar(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText(
              'account_setting'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            TranslatedText(
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
                  isDropdown: false,
                  onChanged: (value) => controller.fullName.value = value,
                ),
                const SizedBox(height: 20),
                // Phone Number
                FormFieldWidget(
                  label: 'phone_number'.tr,
                  value: controller.phoneNumber.value,
                  hintText: 'enter_phone_number'.tr,
                  prefix: const CountryCodeWidget(countryCode: ''),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => controller.phoneNumber.value = value,
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
                // Work Status
                FormFieldWidget(
                  label: 'work_status'.tr,
                  value: controller.workStatus.value,
                  hintText: 'select_work_status'.tr,
                  isDropdown: true,
                  onTap: controller.onOccupationTap,
                ),
                const SizedBox(height: 40),
                // Save Change Button
                AppButton(
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

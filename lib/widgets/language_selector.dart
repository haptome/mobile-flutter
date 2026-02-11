// Purpose: Language selector widget for changing app language
// Author: ET Digital Equb Team

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/language_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/theme/app_text_styles.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          border: Border.all(
            color: AppColors.textFieldBorder,
            width: AppSizes.textFieldBorderWidth,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.language,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'language'.tr,
                    style: AppTextStyles.bodySmall(
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    languageController.getCurrentLanguageName(),
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<Locale>(
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppColors.lightTextPrimary,
              ),
              onSelected: (Locale locale) {
                languageController.changeLanguage(locale);
              },
              itemBuilder: (BuildContext context) {
                return languageController.languages.map((language) {
                  final locale = language['locale'] as Locale;
                  final isSelected =
                      languageController.currentLocale.value == locale;

                  return PopupMenuItem<Locale>(
                    value: locale,
                    child: Row(
                      children: [
                        Text(
                          language['flag'],
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: AppSizes.spacingSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language['nativeName'],
                                style: AppTextStyles.bodyMedium(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                language['name'],
                                style: AppTextStyles.bodySmall(
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple language toggle button (for quick switching)
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    return Obx(
      () => InkWell(
        onTap: () => languageController.toggleLanguage(),
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
            border: Border.all(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                languageController.getCurrentLanguageFlag(),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                languageController.getCurrentLanguageName(),
                style: AppTextStyles.bodyMedium(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

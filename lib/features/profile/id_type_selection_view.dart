// Purpose: ID Type Selection Screen
// Author: Auto-generated
// Linked Spec Section: KYC ID & Liveness Flow - ID Type Selection

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/id_type.dart';
import 'id_capture_view.dart';

class IdTypeSelectionView extends StatelessWidget {
  const IdTypeSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'select_id_type'.tr,
          style: AppTextStyles.h3(color: AppColors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'choose_id_type_desc'.tr,
                style: AppTextStyles.bodyLarge(color: AppColors.lightTextSecondary),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _IDTypeCard(
                    idTypeInfo: IDTypeInfo.nationalId,
                    onTap: () => Get.to(() => IdCaptureView(idType: IDType.nationalId)),
                  ),
                  const SizedBox(height: 12),
                  _IDTypeCard(
                    idTypeInfo: IDTypeInfo.driverLicense,
                    onTap: () => Get.to(() => IdCaptureView(idType: IDType.driverLicense)),
                  ),
                  const SizedBox(height: 12),
                  _IDTypeCard(
                    idTypeInfo: IDTypeInfo.passport,
                    onTap: () => Get.to(() => IdCaptureView(idType: IDType.passport)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IDTypeCard extends StatelessWidget {
  final IDTypeInfo idTypeInfo;
  final VoidCallback onTap;

  const _IDTypeCard({
    required this.idTypeInfo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  idTypeInfo.icon,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      idTypeInfo.displayName,
                      style: AppTextStyles.bodyLarge(color: AppColors.black).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      idTypeInfo.description,
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.lightTextSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

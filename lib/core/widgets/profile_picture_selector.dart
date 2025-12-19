// Purpose: Profile picture selector widget
// Author: haptome H.
// Linked Spec Section: Account Setting Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class ProfilePictureSelector extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;

  const ProfilePictureSelector({
    super.key,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderLightGray,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'set_new_photo'.tr,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.backgroundLightGray,
      child: const Icon(
        Icons.person,
        size: 60,
        color: AppColors.textLightGray,
      ),
    );
  }
}


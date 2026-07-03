// Purpose: Logout button widget
// Author: haptome H.
// Linked Spec Section: Profile Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'translated_text.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback? onLogout;

  const LogoutButton({
    super.key,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE), // Light red background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onLogout,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.exit_to_app,
                color: Color(0xFFF44336), // Red
                size: 24,
              ),
              const SizedBox(width: 8),
              TranslatedText(
                'logout'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF44336), // Red
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Purpose: Logo widget for ET Digital Ekub using asset image
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;

  const LogoWidget({
    super.key,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if image fails to load
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFFDD835), // Bright yellow/gold
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            size: 60,
            color: Color(0xFF1A4744),
          ),
        );
      },
    );
  }
}

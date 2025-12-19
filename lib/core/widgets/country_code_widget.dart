// Purpose: Country code widget with flag
// Author: haptome H.
// Linked Spec Section: Account Setting Page

import 'package:flutter/material.dart';

class CountryCodeWidget extends StatelessWidget {
  final String countryCode;
  final String flag;

  const CountryCodeWidget({
    super.key,
    this.countryCode = '+251',
    this.flag = '🇪🇹', // Ethiopian flag emoji
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          flag,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 8),
        Text(
          '($countryCode)',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}


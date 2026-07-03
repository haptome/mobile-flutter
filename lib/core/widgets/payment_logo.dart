// Purpose: Payment gateway logo widgets
// Author: haptome H.
// Linked Spec Section: Payment Selection Page

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ChapaLogo extends StatelessWidget {
  const ChapaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/chapa.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to text logo if image fails to load
            return Center(
              child: Text(
                'C',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ArifpayLogo extends StatelessWidget {
  const ArifpayLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/arif-pay.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to text logo if image fails to load
            return Center(
              child: Text(
                'AP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SantimPayLogo extends StatelessWidget {
  const SantimPayLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/santim.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to text logo if image fails to load
            return Center(
              child: Text(
                'SP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AddisPayLogo extends StatelessWidget {
  const AddisPayLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/addispay.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to text logo if image asset is not yet added
            return Center(
              child: Text(
                'AP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TelebirrLogo extends StatelessWidget {
  const TelebirrLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/tele_birr.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to text logo if image fails to load
            return Center(
              child: Text(
                'TB',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

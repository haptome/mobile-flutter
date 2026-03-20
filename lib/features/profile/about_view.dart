// Purpose: About App page
// Author: ET Digital Equb Team

import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:et_digital_equb/core/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'about_app'.tr,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App logo + name + version card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                   
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        AppAssets.logo,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ET Digital Equb',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF232729),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${'version'.tr} 1.0.1',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AppColors.textLightGray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Description card
            _InfoCard(
              icon: Iconsax.info_circle,
              title: 'about_app'.tr,
              content:
                  'ET Digital Equb is a modern digital platform for managing traditional Ethiopian savings circles (Equb). '
                  'Join or create groups, contribute securely, and participate in fair automated draws — all from your phone.',
            ),
            const SizedBox(height: 12),
            // Features card
          
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1A4D4D), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF232729),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0x1A000000)),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: const Color(0xFF555555),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

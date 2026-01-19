// Purpose: Categories List Screen with Icon Display
// Author: Generated for Iconify Icon Implementation Demo

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/category_icon.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';

class CategoriesListView extends StatelessWidget {
  const CategoriesListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample category data with icon names
    final categories = [
      {
        'id': '1',
        'name': 'Banking & Finance',
        'description': 'Financial institutions and money management',
        'icon': 'bank',
        'type': 'cash',
        'count': 12
      },
      {
        'id': '2',
        'name': 'Shopping Centers',
        'description': 'Retail stores and shopping complexes',
        'icon': 'shopping',
        'type': 'cash',
        'count': 8
      },
      {
        'id': '3',
        'name': 'Transportation',
        'description': 'Vehicle and travel related groups',
        'icon': 'car',
        'type': 'in_kind',
        'count': 15
      },
      {
        'id': '4',
        'name': 'Technology',
        'description': 'Electronics and tech equipment',
        'icon': 'laptop',
        'type': 'in_kind',
        'count': 6
      },
      {
        'id': '5',
        'name': 'Food & Dining',
        'description': 'Restaurants and food services',
        'icon': 'restaurant',
        'type': 'cash',
        'count': 20
      },
      {
        'id': '6',
        'name': 'Healthcare',
        'description': 'Medical and health services',
        'icon': 'medical',
        'type': 'in_kind',
        'count': 4
      },
      {
        'id': '7',
        'name': 'Education',
        'description': 'Learning and educational resources',
        'icon': 'school',
        'type': 'cash',
        'count': 9
      },
      {
        'id': '8',
        'name': 'Entertainment',
        'description': 'Leisure and recreational activities',
        'icon': 'movie',
        'type': 'cash',
        'count': 7
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Categories',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.splashBackground,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSizes.paddingMedium,
            mainAxisSpacing: AppSizes.paddingMedium,
            childAspectRatio: 0.85,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(context, category);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category) {
    final isCash = category['type'] == 'cash';
    final secondaryColor = AppColors.lightTextSecondary;
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to category detail or perform action
          Get.snackbar(
            category['name'],
            'Showing ${category['count']} groups in this category',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCash 
                    ? AppColors.primary.withOpacity(0.1)
                    : secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CategoryIcon(
                  iconName: category['icon'],
                  size: 32,
                  color: isCash ? AppColors.primary : secondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              
              // Category Name
              Text(
                category['name'],
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.splashBackground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              // Description
              Text(
                category['description'],
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppColors.textLightGray,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Group Count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCash 
                    ? AppColors.primary.withOpacity(0.1)
                    : secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category['count']} groups',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isCash ? AppColors.primary : secondaryColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Category Type Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isCash ? AppColors.primary : secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category['type'].toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
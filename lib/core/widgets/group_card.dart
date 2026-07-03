import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../../models/group_model.dart';

/// Reusable group card used across category and listing screens
class GroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback? onTap;
  final bool showAction;

  const GroupCard({super.key, required this.group, this.onTap, this.showAction = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leading colored dot for type
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _typeColor(group.type),
                    ),
                    child: Center(
                      child: Text(
                        group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                        style: GoogleFonts.montserrat(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.splashBackground,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingXSmall),
                        Text(
                          '${group.contributionAmount.toStringAsFixed(0)} ${'etb'.tr} • ${_prettyFrequency(group.frequency)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: AppColors.textLightGray,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingXSmall),
                        Row(
                          children: [
                            const Icon(Icons.people, size: 14, color: AppColors.textLightGray),
                            const SizedBox(width: 6),
                            Text(
                              '${group.currentMembers} / ${group.targetMembers} members',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: AppColors.textLightGray,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _typeColor(group.type),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                group.type.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showAction) ...[
                const SizedBox(height: AppSizes.spacingSmall),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: onTap,
                    child: Text('view'.tr),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'public':
        return Colors.green;
      case 'private':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  String _prettyFrequency(String f) {
    if (f.isEmpty) return f;
    return f[0].toUpperCase() + f.substring(1);
  }
}

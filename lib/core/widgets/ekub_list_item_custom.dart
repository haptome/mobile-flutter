import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';

import '../../models/group_model.dart';

/// Custom ekub list item widget matching the specified design
class EkubListItemCustom extends StatelessWidget {
  final String title;
  final String amountLabel;
  final String frequency;
  final int currentMembers;
  final VoidCallback? onTap;
  final String? groupId;

  const EkubListItemCustom({
    super.key,
    required this.title,
    required this.amountLabel,
    required this.frequency,
    this.currentMembers = 0,
    this.onTap,
    this.groupId,
  });

  /// Compatibility constructor to build from a `Group` model
  factory EkubListItemCustom.fromGroup(Group group, {VoidCallback? onTap}) {
    return EkubListItemCustom(
      title: group.name,
      amountLabel: '${group.contributionAmount.toStringAsFixed(0)} ETB',
      frequency: _prettyFrequency(group.frequency),
      currentMembers: group.currentMembers,
      onTap: onTap,
      groupId: group.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 358,
        height: 110,
        margin: const EdgeInsets.only(bottom: 8.0), // gap of 8px
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.08), // 8% opacity
              blurRadius: 16,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Top section with title and icons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title container with bottom border
                  Container(
                    width: 338,
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 338,
                          padding: EdgeInsets.zero,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                title,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.splashBackground,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 1,
                                height: 15,
                                color: AppColors.borderLightGray,
                              ),
                              const SizedBox(width: 6),

                              Row(
                                children: [
                                  Icon(
                                    Iconsax.clock,
                                    size: 14,
                                    color:
                                        AppColors.splashBackground, // #024141
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    frequency,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          thickness: 0.4,
                          color: Color.fromRGBO(
                            0,
                            0,
                            0,
                            0.24,
                          ), // rgba(0, 0, 0, 0.24)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4), // gap of 4px
                  // Icon row with amount, time, and number
                  Container(
                    width: 338,
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Amount with icon
                        Row(
                          children: [
                            Icon(
                              Iconsax.money,
                              size: 14,
                              color: AppColors.splashBackground, // #024141
                            ),
                            const SizedBox(width: 6),
                            Text(
                              amountLabel,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        // Time with icon
                        Row(
                          children: [
                            Icon(
                              Iconsax.clock,
                              size: 14,
                              color: AppColors.splashBackground, // #024141
                            ),
                            const SizedBox(width: 6),
                            Text(
                              frequency,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        // Number with icon
                        Row(
                          children: [
                            Icon(
                              Iconsax.profile_2user,
                              size: 14,
                              color: AppColors.splashBackground, // #024141
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${currentMembers} Members',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Join button placeholder
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBBBB32), // #BBBB32
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'See More',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _prettyFrequency(String f) {
    if (f.isEmpty) return f;
    return f[0].toUpperCase() + f.substring(1);
  }
}

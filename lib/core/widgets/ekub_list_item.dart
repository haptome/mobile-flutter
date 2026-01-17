import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../../models/group_model.dart';
import 'icon_label.dart';

/// Reusable ekub list item used inside collapsible sections and lists.
///
/// Can be constructed directly from primitive fields or using
/// `EkubListItem.fromGroup(group)` to keep compatibility with existing code.
class EkubListItem extends StatelessWidget {
  final String title;
  final String amountLabel;
  final String frequency;
  final int currentMembers;
  final List<Widget>? avatars; // small avatar widgets
  final VoidCallback? onJoin;
  final VoidCallback? onTap;
  final String joinLabel;
  final Color joinColor;
  final bool showJoin;

  const EkubListItem({
    super.key,
    required this.title,
    required this.amountLabel,
    required this.frequency,
    this.currentMembers = 0,
    this.avatars,
    this.onJoin,
    this.onTap,
    this.joinLabel = 'Join',
    this.joinColor = const Color(0xffc6c92a),
    this.showJoin = true,
  });

  /// Compatibility constructor to build from a `Group` model
  factory EkubListItem.fromGroup(
    Group group, {
    VoidCallback? onJoin,
    VoidCallback? onTap,
    bool showJoin = true,
  }) {
    return EkubListItem(
      title: group.name,
      amountLabel: '${group.contributionAmount.toStringAsFixed(0)} ETB',
      frequency: group.frequency,
      currentMembers: group.currentMembers,
      avatars: null,
      onJoin: onJoin,
      onTap: onTap,
      showJoin: showJoin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xfff7f7e6),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: amount icon + amount + title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconLabel(
                        iconData: Icons.attach_money,
                        iconColor: AppColors.splashBackground,
                        label: amountLabel,
                        labelStyle: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.splashBackground,
                        ),
                      ),

                      IconLabel(
                        iconData: Iconsax.money,
                        iconColor: AppColors.splashBackground,
                        label: title,
                        labelStyle: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.splashBackground,
                        ),
                      ),
                      IconLabel(
                        iconData: Iconsax.timer_1,
                        iconColor: AppColors.splashBackground,
                        label: _prettyFrequency(frequency),
                        labelStyle: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.splashBackground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (avatars != null && avatars!.isNotEmpty)
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...avatars!,
                              const SizedBox(width: AppSizes.spacingXSmall),
                              Flexible(
                                child: Text(
                                  '+${(currentMembers - (avatars?.length ?? 0)).clamp(0, 999)} Members',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: AppColors.textLightGray,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Flexible(
                          child: Text(
                            '+${currentMembers.clamp(0, 999)} Members',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: AppColors.textLightGray,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      const SizedBox(width: AppSizes.spacingSmall),

                      // Join button constrained to a finite width
                      if (showJoin)
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 72,
                            maxWidth: 90,
                          ),
                          child: ElevatedButton(
                            onPressed: onJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: joinColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              joinLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // avatars and members (shrinkable)
          ],
        ),
      ),
    );
  }

  String _prettyFrequency(String f) {
    if (f.isEmpty) return f;
    return f[0].toUpperCase() + f.substring(1);
  }
}

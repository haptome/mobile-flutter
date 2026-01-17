import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_sizes.dart';

/// Generic Icon + Label widget. Icon or IconData can be provided.
class IconLabel extends StatelessWidget {
  final Widget? icon;
  final IconData? iconData;
  final String label;
  final TextStyle? labelStyle;
  final Color? iconColor;
  final double spacing;

  const IconLabel({
    super.key,
    this.icon,
    this.iconData,
    required this.label,
    this.labelStyle,
    this.iconColor,
    this.spacing = AppSizes.spacingXSmall,
  }) : assert(
         icon != null || iconData != null,
         'Either icon or iconData must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final usedIcon = icon ?? Icon(iconData, color: iconColor, size: 18);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        usedIcon!,
        SizedBox(width: spacing),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style:
                (labelStyle ??
                        GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ))
                    .copyWith(overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}

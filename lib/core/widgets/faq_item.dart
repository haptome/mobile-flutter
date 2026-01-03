// Purpose: FAQ item widget (expandable)
// Author: haptome H.
// Linked Spec Section: FAQ/Help Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class FaqItem extends StatefulWidget {
  final String id;
  final String question;
  final String answer;
  final int usersAsked;
  final List<String>? userAvatars;

  const FaqItem({
    super.key,
    required this.id,
    required this.question,
    required this.answer,
    this.usersAsked = 0,
    this.userAvatars,
  });

  @override
  State<FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Question header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Question text
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Expand/collapse icon
                  Icon(
                    _isExpanded ? Icons.remove : Icons.add,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          // Answer content
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Answer text
                  Text(
                    widget.answer,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.lightTextPrimary,
                      height: 1.5,
                    ),
                  ),
                  // User engagement
                  if (widget.usersAsked > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // User avatars
                        ...List.generate(
                          (widget.userAvatars?.length ?? 0).clamp(0, 3),
                          (index) => Container(
                            margin: const EdgeInsets.only(right: -8),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.lightBackground,
                                width: 2,
                              ),
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                            child:
                                widget.userAvatars != null &&
                                    index < widget.userAvatars!.length
                                ? ClipOval(
                                    child: Image.network(
                                      widget.userAvatars![index],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.person,
                                                size: 16,
                                                color: AppColors.primary,
                                              ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Users asked text
                        Text(
                          '+${widget.usersAsked} ${'users_asked'.tr}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLightGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Purpose: Payment method card widget (expandable)
// Author: haptome H.
// Linked Spec Section: Payment Selection Page

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import 'primary_button.dart';

class PaymentMethodCard extends StatefulWidget {
  final String id;
  final String name;
  final Widget logo;
  final String? description;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onProceed;

  const PaymentMethodCard({
    super.key,
    required this.id,
    required this.name,
    required this.logo,
    this.description,
    this.isSelected = false,
    this.onTap,
    this.onProceed,
  });

  @override
  State<PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isSelected;
  }

  @override
  void didUpdateWidget(PaymentMethodCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      _isExpanded = widget.isSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded ? AppColors.primary : AppColors.borderLightGray,
          width: _isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
              widget.onTap?.call();
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Logo
                  widget.logo,
                  const SizedBox(width: 12),
                  // Name
                  Expanded(
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isExpanded
                            ? AppColors.primary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  // Chevron icon
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.lightTextPrimary,
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info box
                  if (widget.description != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Proceed button
                  Align(
                    alignment: Alignment.centerRight,
                    child: PrimaryButton(
                      text: 'proceed_to_payment'.tr,
                      onPressed: widget.onProceed,
                      minWidth: 180,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_text.dart';

enum StatusBadgeType {
  cash,
  deferred,
  categoryType,
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.text,
    super.key,
    this.type = StatusBadgeType.categoryType,
    this.backgroundColor,
    this.textColor,
  });

  const StatusBadge.cash({
    super.key,
    this.text = 'cash',
  })  : type = StatusBadgeType.cash,
        backgroundColor = null,
        textColor = null;

  const StatusBadge.deferred({
    super.key,
    this.text = 'deferred',
  })  : type = StatusBadgeType.deferred,
        backgroundColor = null,
        textColor = null;

  const StatusBadge.shipmentType({
    required this.text,
    super.key,
  })  : type = StatusBadgeType.categoryType,
        backgroundColor = null,
        textColor = null;

  final String text;
  final StatusBadgeType type;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    Color bg;
    Color fg;

    switch (type) {
      case StatusBadgeType.cash:
        bg = backgroundColor ?? colors.badgeCashBg;
        fg = textColor ?? colors.badgeCashText;
      case StatusBadgeType.deferred:
        bg = backgroundColor ?? colors.badgeDeferredBg;
        fg = textColor ?? colors.badgeDeferredText;
      case StatusBadgeType.categoryType:
        bg = backgroundColor ?? colors.badgeTypeBg;
        fg = textColor ?? colors.badgeTypeText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppText(
        text,
        style: AppTypography.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
        ),
        color: fg,
      ),
    );
  }
}

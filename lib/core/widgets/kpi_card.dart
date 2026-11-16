import 'package:flutter/material.dart';

import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_text.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    super.key,
    this.accentColor,
    this.iconBackgroundColor,
  }) : flex = 1;

  final String title;
  final String value;
  final String subtitle;
  final Widget icon;
  final Color? accentColor;
  final Color? iconBackgroundColor;
  final int flex;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final accent = accentColor ?? colors.brandInboundGreen;
    final iconBg = iconBackgroundColor ?? accent.withValues(alpha: 0.12);

    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppText(
                    title,
                    style: AppTypography.labelField,
                    color: colors.textMuted,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: icon,
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppText(
              value,
              style: AppTypography.displayKpiValue.copyWith(
                fontFamily: FontAssetsManager.jetBrainsMono,
              ),
              color: accent,
            ),
            const SizedBox(height: 6),
            AppText(
              subtitle,
              style: AppTypography.bodySmall,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

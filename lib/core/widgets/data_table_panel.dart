import 'package:flutter/material.dart';

import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_text.dart';

class DataTablePanel extends StatelessWidget {
  const DataTablePanel({
    required this.title,
    required this.child,
    super.key,
    this.titleColor,
    this.headerAction,
    this.footerText,
    this.onFooterTap,
    this.padding = const EdgeInsets.all(20),
  });

  final String title;
  final Widget child;
  final Color? titleColor;
  final Widget? headerAction;
  final String? footerText;
  final VoidCallback? onFooterTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  title,
                  style: AppTypography.headingCardTitle,
                  color: titleColor ?? colors.brandInboundGreen,
                ),
                ?headerAction,
              ],
            ),
          ),
          Divider(color: colors.borderDefault, height: 1),
          Padding(
            padding: padding,
            child: child,
          ),
          if (footerText != null) ...[
            Divider(color: colors.borderDefault, height: 1),
            InkWell(
              onTap: onFooterTap,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppText(
                      footerText!,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      color: titleColor ?? colors.brandInboundGreen,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

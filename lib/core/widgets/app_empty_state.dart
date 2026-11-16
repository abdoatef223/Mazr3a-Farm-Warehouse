import 'package:flutter/material.dart';

import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_text.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.message = 'No records yet',
    this.subMessage,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final String? subMessage;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.surfaceTableHead,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 28,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            AppText(
              message,
              style: AppTypography.headingCardTitle,
              color: colors.textPrimary,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 6),
              AppText(
                subMessage!,
                style: AppTypography.bodySmall,
                color: colors.textMuted,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_button.dart';
import 'package:mazr3a/core/widgets/app_text.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({
    super.key,
    this.title = 'Delete Record',
    this.message = "Delete this record? This can't be undone.",
  });

  final String title;
  final String message;

  static Future<bool> show(
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ConfirmDeleteDialog(
        title: title ?? 'Delete Record',
        message: message ?? "Delete this record? This can't be undone.",
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Dialog(
      backgroundColor: colors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.borderDefault),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: colors.danger,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppText(
                    title,
                    style: AppTypography.headingCardTitle,
                    color: colors.textPrimary,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppText(
                message,
                style: AppTypography.bodyRegular,
                color: colors.textMuted,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: AppText(
                      'Cancel',
                      style: AppTypography.buttonPrimary.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Semantics(
                    label: 'Confirm delete record',
                    button: true,
                    child: AppButton(
                      text: 'Delete',
                      backgroundColor: colors.danger,
                      foregroundColor: colors.textOnDark,
                      height: 40,
                      borderRadius: 8,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

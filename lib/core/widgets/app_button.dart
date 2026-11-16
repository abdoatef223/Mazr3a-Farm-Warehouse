import 'package:flutter/material.dart';

import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_text.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.isFullWidth = false,
    this.height = 48,
    this.padding,
    this.borderRadius = 8,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isFullWidth;
  final double height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bgColor = backgroundColor ?? colors.brandInboundButton;
    final fgColor = foregroundColor ?? colors.textOnDark;

    final buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        AppText(
          text,
          style: AppTypography.buttonPrimary,
          color: fgColor,
        ),
      ],
    );

    final button = Material(
      color: onPressed != null ? bgColor : bgColor.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: height,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          child: buttonChild,
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

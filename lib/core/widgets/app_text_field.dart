import 'package:flutter/material.dart';

import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_text.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.initialValue,
    this.useMono = false,
    this.focusNode,
    this.contentPadding,
    this.isDense,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final String? initialValue;
  final bool useMono;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final bool? isDense;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colors.borderDefault),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colors.brandInboundGreen, width: 1.5),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.redAccent),
    );

    final textStyle = useMono
        ? AppTypography.monoData.copyWith(color: colors.textPrimary)
        : AppTypography.bodyRegular.copyWith(color: colors.textPrimary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          AppText(
            label!,
            style: AppTypography.labelField,
            color: colors.textPrimary,
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          initialValue: initialValue,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          style: textStyle,
          decoration: InputDecoration(
            isDense: isDense,
            hintText: hintText,
            hintStyle: AppTypography.bodyRegular.copyWith(
              color: colors.textMuted,
            ),
            filled: true,
            fillColor: readOnly ? colors.surfaceTableHead : colors.surfaceCard,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: border,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
          ),
        ),
      ],
    );
  }
}

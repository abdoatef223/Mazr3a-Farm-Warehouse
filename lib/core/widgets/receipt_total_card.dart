import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';

import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_text.dart';

class ReceiptTotalCard extends StatelessWidget {
  const ReceiptTotalCard({
    required this.total,
    this.accentColor,
    super.key,
  });

  final double total;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final numberFormat = NumberFormat('#,##0.00');
    final safeTotal = total <= 0 || total.isNaN || total.isInfinite ? 0.0 : total;
    final formattedTotal = numberFormat.format(safeTotal);

    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: colors.surfaceTableHead,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            StringsManager.labelTotal,
            style: AppTypography.headingCardTitle.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppText(
            '${StringsManager.currencyEgp} $formattedTotal',
            style: AppTypography.monoDataBold.copyWith(
              fontSize: 22.sp,
              color: accentColor ?? colors.brandInboundGreen,
            ),
          ),
        ],
      ),
    );
  }
}

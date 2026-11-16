import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_button.dart';
import 'package:mazr3a/core/widgets/app_text.dart';

class InventoryEmptyView extends StatelessWidget {
  const InventoryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: colors.surfaceTableHead,
              borderRadius: BorderRadius.circular(16.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.inventory_2_outlined,
              size: 32.sp,
              color: colors.textMuted,
            ),
          ),
          SizedBox(height: 18.h),
          AppText(
            StringsManager.emptyInventoryPrompt,
            style: AppTypography.headingCardTitle,
            color: colors.textPrimary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 18.h),
          AppButton(
            text: StringsManager.newReceipt,
            icon: Icon(
              Icons.add_rounded,
              size: 18.sp,
              color: Colors.white,
            ),
            backgroundColor: colors.brandInboundButton,
            onPressed: () => context.router.navigatePath('/inbound/new'),
          ),
        ],
      ),
    );
  }
}

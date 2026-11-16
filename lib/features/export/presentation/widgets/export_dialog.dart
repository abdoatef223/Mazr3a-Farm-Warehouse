import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';

import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_button.dart';
import 'package:mazr3a/core/widgets/app_text.dart';
import 'package:mazr3a/core/widgets/app_text_field.dart';

enum ExportDateRangeType {
  allTime,
  thisMonth,
  custom,
}

class ExportDateRangeResult {
  const ExportDateRangeResult({
    this.dateFrom,
    this.dateTo,
  });

  final DateTime? dateFrom;
  final DateTime? dateTo;
}

class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  static Future<ExportDateRangeResult?> show(BuildContext context) =>
      showDialog<ExportDateRangeResult>(
        context: context,
        builder: (_) => const ExportDialog(),
      );

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  ExportDateRangeType _selectedType = ExportDateRangeType.allTime;

  DateTime? _customStartDate;
  DateTime? _customEndDate;

  final _startController = TextEditingController();
  final _endController = TextEditingController();

  final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customStartDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _customStartDate = picked;
        _startController.text = _dateFmt.format(picked);
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customEndDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _customEndDate = picked;
        _endController.text = _dateFmt.format(picked);
      });
    }
  }

  void _onConfirm() {
    DateTime? from;
    DateTime? to;

    switch (_selectedType) {
      case ExportDateRangeType.allTime:
        from = null;
        to = null;
      case ExportDateRangeType.thisMonth:
        final now = DateTime.now();
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      case ExportDateRangeType.custom:
        from = _customStartDate;
        to = _customEndDate;
    }

    Navigator.of(context).pop(
      ExportDateRangeResult(dateFrom: from, dateTo: to),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: 480.w,
        padding: EdgeInsets.all(28.w),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colors.borderDefault),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: colors.brandInboundGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.file_download_outlined,
                    color: colors.brandInboundGreen,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        StringsManager.exportDialogTitle,
                        style: AppTypography.headingCardTitle,
                        color: colors.textPrimary,
                      ),
                      SizedBox(height: 4.h),
                      AppText(
                        StringsManager.exportDialogSubtitle,
                        style: AppTypography.bodySmall,
                        color: colors.textMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Radio options
            _buildRadioOption(
              type: ExportDateRangeType.allTime,
              title: StringsManager.allTime,
              colors: colors,
            ),
            SizedBox(height: 10.h),
            _buildRadioOption(
              type: ExportDateRangeType.thisMonth,
              title: StringsManager.thisMonth,
              colors: colors,
            ),
            SizedBox(height: 10.h),
            _buildRadioOption(
              type: ExportDateRangeType.custom,
              title: StringsManager.customRange,
              colors: colors,
            ),

            if (_selectedType == ExportDateRangeType.custom) ...[
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: StringsManager.startDate,
                      controller: _startController,
                      readOnly: true,
                      onTap: _pickStartDate,
                      hintText: StringsManager.selectDateHint,
                      suffixIcon: Icon(
                        Icons.calendar_today_outlined,
                        size: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: AppTextField(
                      label: StringsManager.endDate,
                      controller: _endController,
                      readOnly: true,
                      onTap: _pickEndDate,
                      hintText: StringsManager.selectDateHint,
                      suffixIcon: Icon(
                        Icons.calendar_today_outlined,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 28.h),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: AppText(
                    'Cancel',
                    style: AppTypography.bodyRegular.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    color: colors.textMuted,
                  ),
                ),
                SizedBox(width: 12.w),
                AppButton(
                  text: 'Export .xlsx',
                  icon: const Icon(
                    Icons.download_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  backgroundColor: colors.brandInboundGreen,
                  onPressed: _onConfirm,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required ExportDateRangeType type,
    required String title,
    required AppColors colors,
  }) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.brandInboundGreen.withValues(alpha: 0.08)
              : colors.surfaceTableHead,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? colors.brandInboundGreen : colors.borderDefault,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? colors.brandInboundGreen : colors.textMuted,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            AppText(
              title,
              style: AppTypography.bodyRegular.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              color: isSelected ? colors.textPrimary : colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

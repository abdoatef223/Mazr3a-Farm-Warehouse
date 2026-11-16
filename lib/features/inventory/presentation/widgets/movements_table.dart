import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';

import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_text.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_movement.dart';

class _MovementColumnDef {
  const _MovementColumnDef({
    required this.key,
    required this.label,
    required this.flex,
    this.numeric = false,
  });

  final String key;
  final String label;
  final int flex;
  final bool numeric;
}

const _movementColumns = [
  _MovementColumnDef(
    key: 'date',
    label: StringsManager.colDate,
    flex: 2,
  ),
  _MovementColumnDef(
    key: 'type',
    label: StringsManager.colMovementType,
    flex: 2,
  ),
  _MovementColumnDef(
    key: 'product',
    label: StringsManager.colProduct,
    flex: 3,
  ),
  _MovementColumnDef(
    key: 'itemType',
    label: StringsManager.colType,
    flex: 2,
  ),
  _MovementColumnDef(
    key: 'unit',
    label: StringsManager.labelUnit,
    flex: 1,
  ),
  _MovementColumnDef(
    key: 'quantity',
    label: StringsManager.colQuantity,
    flex: 2,
    numeric: true,
  ),
  _MovementColumnDef(
    key: 'runningBalance',
    label: StringsManager.colRunningBalance,
    flex: 2,
    numeric: true,
  ),
  _MovementColumnDef(
    key: 'reference',
    label: StringsManager.colReference,
    flex: 2,
  ),
];

class MovementsTable extends StatelessWidget {
  const MovementsTable({
    required this.movements,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    super.key,
  });

  final List<InventoryMovement> movements;
  final int currentPage;
  final int totalPages;
  final void Function(int page) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final qtyFormat = NumberFormat('#,##0.##');

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.borderDefault),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minWidth = 900.w;
            final tableWidth = constraints.maxWidth < minWidth
                ? minWidth
                : constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(colors),
                    if (movements.isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 40.h,
                          horizontal: 20.w,
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          StringsManager.noDataFound,
                          style: AppTypography.bodyRegular,
                          color: colors.textMuted,
                        ),
                      )
                    else
                      ...movements.map(
                        (m) => _buildRow(m, colors, qtyFormat),
                      ),
                    if (totalPages > 1) _buildPaginationFooter(colors),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors colors) => Container(
        key: const ValueKey('movements_header'),
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: colors.surfaceTableHead,
          border: Border(
            bottom: BorderSide(color: colors.borderDefault),
          ),
        ),
        child: Row(
          children: _movementColumns.map((col) {
            return Expanded(
              flex: col.flex,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                child: Align(
                  alignment: col.numeric
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: AppText(
                    col.label,
                    style: AppTypography.labelTableHead,
                    color: colors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );

  Widget _buildRow(
    InventoryMovement m,
    AppColors colors,
    NumberFormat qtyFormat,
  ) {
    final isInbound = m.type == MovementType.inbound;
    final formattedQty =
        (isInbound ? '+' : '') + qtyFormat.format(m.quantity);
    final formattedBalance = qtyFormat.format(m.runningBalance);

    final cells = <String, Widget>{
      'date': AppText(
        m.date,
        style: AppTypography.monoData,
        color: colors.textPrimary,
      ),
      'type': _buildMovementBadge(
        type: m.type,
        colors: colors,
      ),
      'product': AppText(
        m.product,
        style: AppTypography.bodyRegular,
        color: colors.textPrimary,
      ),
      'itemType': AppText(
        m.itemType,
        style: AppTypography.bodySmall,
        color: colors.textMuted,
      ),
      'unit': AppText(
        m.unit,
        style: AppTypography.bodySmall,
        color: colors.textMuted,
      ),
      'quantity': AppText(
        formattedQty,
        style: AppTypography.monoDataBold,
        color: isInbound
            ? colors.brandInboundGreen
            : colors.brandOutboundBrown,
      ),
      'runningBalance': AppText(
        formattedBalance,
        style: AppTypography.monoDataBold,
        color: m.runningBalance < 0
            ? colors.danger
            : (m.runningBalance == 0
                ? colors.textMuted
                : colors.textPrimary),
      ),
      'reference': AppText(
        m.reference,
        style: AppTypography.bodySmall,
        color: colors.textMuted,
      ),
    };

    return Container(
      key: ValueKey('movements_row_${m.id}'),
      constraints: BoxConstraints(minHeight: 52.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border(
          bottom: BorderSide(color: colors.borderDefault),
        ),
      ),
      child: Row(
        children: _movementColumns.map((col) {
          return Expanded(
            flex: col.flex,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Align(
                alignment: col.numeric
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: cells[col.key] ?? const SizedBox.shrink(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaginationFooter(AppColors colors) => Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: colors.surfaceTableHead,
          border: Border(
            top: BorderSide(color: colors.borderDefault),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              'Page $currentPage of $totalPages',
              style: AppTypography.bodySmall,
              color: colors.textMuted,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  iconSize: 20.sp,
                  color: currentPage > 1
                      ? colors.textPrimary
                      : colors.textMuted.withValues(alpha: 0.4),
                  onPressed: currentPage > 1
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  iconSize: 20.sp,
                  color: currentPage < totalPages
                      ? colors.textPrimary
                      : colors.textMuted.withValues(alpha: 0.4),
                  onPressed: currentPage < totalPages
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildMovementBadge({
    required MovementType type,
    required AppColors colors,
  }) {
    final isInbound = type == MovementType.inbound;
    final bg = isInbound
        ? colors.badgeCashBg
        : colors.brandOutboundBrown.withValues(alpha: 0.15);
    final fg = isInbound ? colors.badgeCashText : colors.brandOutboundBrown;
    final label = isInbound
        ? StringsManager.movementInboundBadge
        : StringsManager.movementOutboundBadge;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: AppText(
        label,
        style: AppTypography.bodySmall.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        color: fg,
      ),
    );
  }
}

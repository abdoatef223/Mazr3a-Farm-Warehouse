import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';

import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_text.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_item.dart';

class _StockColumnDef {
  const _StockColumnDef({
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

const _stockColumns = [
  _StockColumnDef(
    key: 'product',
    label: StringsManager.colProduct,
    flex: 3,
  ),
  _StockColumnDef(
    key: 'type',
    label: StringsManager.colType,
    flex: 2,
  ),
  _StockColumnDef(
    key: 'unit',
    label: StringsManager.labelUnit,
    flex: 1,
  ),
  _StockColumnDef(
    key: 'totalIn',
    label: StringsManager.colTotalIn,
    flex: 2,
    numeric: true,
  ),
  _StockColumnDef(
    key: 'totalOut',
    label: StringsManager.colTotalOut,
    flex: 2,
    numeric: true,
  ),
  _StockColumnDef(
    key: 'inStock',
    label: StringsManager.colInStock,
    flex: 2,
    numeric: true,
  ),
  _StockColumnDef(
    key: 'lastPrice',
    label: StringsManager.colLastPrice,
    flex: 2,
    numeric: true,
  ),
  _StockColumnDef(
    key: 'stockValue',
    label: StringsManager.colStockValue,
    flex: 2,
    numeric: true,
  ),
];

class StockLevelsTable extends StatelessWidget {
  const StockLevelsTable({
    required this.items,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
    super.key,
  });

  final List<InventoryItem> items;
  final String sortColumn;
  final bool sortAscending;
  final void Function(String column) onSort;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final qtyFormat = NumberFormat('#,##0.##');
    final moneyFormat = NumberFormat('#,##0.00');

    final totalStockValue = items.fold<double>(
      0.0,
      (sum, item) => sum + item.stockValue,
    );

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
                    if (items.isEmpty)
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
                      ...items.map(
                        (item) => _buildRow(
                          item,
                          colors,
                          qtyFormat,
                          moneyFormat,
                        ),
                      ),
                    _buildFooter(
                      colors,
                      items.length,
                      totalStockValue,
                      moneyFormat,
                    ),
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
        key: const ValueKey('stock_levels_header'),
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: colors.surfaceTableHead,
          border: Border(
            bottom: BorderSide(color: colors.borderDefault),
          ),
        ),
        child: Row(
          children: _stockColumns.map((col) {
            final isSelected = sortColumn == col.key;
            return Expanded(
              flex: col.flex,
              child: InkWell(
                onTap: () => onSort(col.key),
                borderRadius: BorderRadius.circular(4.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                  child: Align(
                    alignment: col.numeric
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.centerStart,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: AppText(
                            col.label,
                            style: AppTypography.labelTableHead,
                            color: isSelected
                                ? colors.textPrimary
                                : colors.textMuted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          isSelected
                              ? (sortAscending
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded)
                              : Icons.unfold_more_rounded,
                          size: 14.sp,
                          color: isSelected
                              ? colors.textPrimary
                              : colors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );

  Widget _buildRow(
    InventoryItem item,
    AppColors colors,
    NumberFormat qtyFormat,
    NumberFormat moneyFormat,
  ) {
    final formattedIn = qtyFormat.format(item.totalIn);
    final formattedOut = qtyFormat.format(item.totalOut);
    final formattedInStock = qtyFormat.format(item.inStock);
    final formattedLastPrice = moneyFormat.format(item.lastPrice);
    final formattedStockValue = moneyFormat.format(item.stockValue);

    final Widget inStockWidget;
    if (item.inStock == 0) {
      inStockWidget = AppText(
        '0',
        style: AppTypography.monoData,
        color: colors.textMuted,
      );
    } else if (item.inStock < 0) {
      inStockWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            formattedInStock,
            style: AppTypography.monoDataBold,
            color: colors.danger,
          ),
          SizedBox(width: 6.w),
          Tooltip(
            message: StringsManager.negativeStockTooltip,
            child: Icon(
              Icons.warning_amber_rounded,
              size: 16.sp,
              color: colors.danger,
            ),
          ),
        ],
      );
    } else {
      inStockWidget = AppText(
        formattedInStock,
        style: AppTypography.monoDataBold,
        color: colors.textPrimary,
      );
    }

    final cells = <String, Widget>{
      'product': AppText(
        item.product,
        style: AppTypography.bodyRegular,
        color: colors.textPrimary,
      ),
      'type': AppText(
        item.type,
        style: AppTypography.bodySmall,
        color: colors.textMuted,
      ),
      'unit': AppText(
        item.unit,
        style: AppTypography.bodySmall,
        color: colors.textMuted,
      ),
      'totalIn': AppText(
        formattedIn,
        style: AppTypography.monoData,
        color: colors.textPrimary,
      ),
      'totalOut': AppText(
        formattedOut,
        style: AppTypography.monoData,
        color: colors.textPrimary,
      ),
      'inStock': inStockWidget,
      'lastPrice': AppText(
        '${StringsManager.currencyEgp} $formattedLastPrice',
        style: AppTypography.monoData,
        color: colors.textPrimary,
      ),
      'stockValue': AppText(
        '${StringsManager.currencyEgp} $formattedStockValue',
        style: AppTypography.monoDataBold,
        color: colors.textPrimary,
      ),
    };

    return Container(
      key: ValueKey('stock_levels_row_${item.product}'),
      constraints: BoxConstraints(minHeight: 52.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border(
          bottom: BorderSide(color: colors.borderDefault),
        ),
      ),
      child: Row(
        children: _stockColumns.map((col) {
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

  Widget _buildFooter(
    AppColors colors,
    int count,
    double totalStockValue,
    NumberFormat moneyFormat,
  ) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
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
              StringsManager.recordsCountPlural(count),
              style: AppTypography.bodySmall,
              color: colors.textMuted,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  '${StringsManager.totalStockValueLabel}: ',
                  style: AppTypography.labelTableHead,
                  color: colors.textPrimary,
                ),
                AppText(
                  '${StringsManager.currencyEgp} ${moneyFormat.format(totalStockValue)}',
                  style: AppTypography.monoDataBold.copyWith(
                    fontSize: 16.sp,
                  ),
                  color: colors.brandInboundGreen,
                ),
              ],
            ),
          ],
        ),
      );
}

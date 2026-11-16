import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';

import 'package:mazr3a/core/di/injection.dart';
import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_button.dart';
import 'package:mazr3a/core/widgets/app_snack_bar.dart';
import 'package:mazr3a/core/widgets/app_text.dart';
import 'package:mazr3a/core/widgets/app_text_field.dart';
import 'package:mazr3a/features/export/domain/model/export_scope.dart';
import 'package:mazr3a/features/export/presentation/widgets/export_excel_button.dart';
import 'package:mazr3a/features/inventory/presentation/view_model/inventory_cubit.dart';
import 'package:mazr3a/features/inventory/presentation/widgets/inventory_empty_view.dart';
import 'package:mazr3a/features/inventory/presentation/widgets/movements_table.dart';
import 'package:mazr3a/features/inventory/presentation/widgets/stock_levels_table.dart';

@RoutePage()
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<InventoryCubit>(),
        child: const _InventoryView(),
      );
}

class _InventoryView extends StatefulWidget {
  const _InventoryView();

  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView> {
  late final TextEditingController _stockSearchController;
  late final TextEditingController _movementSearchController;
  @override
  void initState() {
    super.initState();
    _stockSearchController = TextEditingController();
    _movementSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _stockSearchController.dispose();
    _movementSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.surfacePage,
      body: SafeArea(
        child: BlocConsumer<InventoryCubit, InventoryStates>(
          listener: (context, state) {
            if (state is InventoryError) {
              AppSnackBar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            final cubit = InventoryCubit.of(context);

            return switch (state) {
              InventoryInit() || InventoryLoading() => Center(
                  child: CircularProgressIndicator(
                    color: colors.brandInboundGreen,
                  ),
                ),
              InventoryLoaded() => _buildLoadedBody(context, cubit, state, colors),
              InventoryError(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        message,
                        style: AppTypography.bodyRegular,
                        color: colors.danger,
                      ),
                      SizedBox(height: 12.h),
                      AppButton(
                        text: 'Retry',
                        onPressed: cubit.loadInventory,
                      ),
                    ],
                  ),
                ),
            };
          },
        ),
      ),
    );
  }

  Widget _buildLoadedBody(
    BuildContext context,
    InventoryCubit cubit,
    InventoryLoaded state,
    AppColors colors,
  ) =>
      SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        StringsManager.inventoryTitle,
                        style: AppTypography.displayH1,
                        color: colors.textPrimary,
                      ),
                      SizedBox(height: 6.h),
                      AppText(
                        StringsManager.inventorySubtitle,
                        style: AppTypography.bodyRegular,
                        color: colors.textMuted,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExportExcelButton(
                      scope: ExportScope.inventory,
                      searchQuery: state.selectedTab == 0
                          ? state.stockSearchQuery
                          : state.movementSearchQuery,
                      activeFilter: state.selectedTab == 1
                          ? state.movementTypeFilter
                          : null,
                      hideZeroStock: state.selectedTab == 0
                          ? state.hideZeroStock
                          : false,
                    ),
                    SizedBox(width: 12.w),
                    AppButton(
                      text: StringsManager.newReceipt,
                      icon: Icon(
                        Icons.add_rounded,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                      backgroundColor: colors.brandInboundButton,
                      onPressed: () =>
                          context.router.navigatePath('/inbound/new'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Tabs Selector
            _buildTabSelector(cubit, state.selectedTab, colors),
            SizedBox(height: 20.h),

            // Tab Content
            if (state.isEmptyWarehouse)
              const InventoryEmptyView()
            else if (state.selectedTab == 0)
              _buildStockTab(cubit, state, colors)
            else
              _buildMovementsTab(context, cubit, state, colors),
          ],
        ),
      );

  Widget _buildTabSelector(
    InventoryCubit cubit,
    int selectedTab,
    AppColors colors,
  ) =>
      Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: colors.borderDefault),
        ),
        padding: EdgeInsets.all(4.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabButton(
              title: StringsManager.tabStockLevels,
              isSelected: selectedTab == 0,
              colors: colors,
              onTap: () => cubit.setTab(0),
            ),
            SizedBox(width: 4.w),
            _buildTabButton(
              title: StringsManager.tabMovements,
              isSelected: selectedTab == 1,
              colors: colors,
              onTap: () => cubit.setTab(1),
            ),
          ],
        ),
      );

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required AppColors colors,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? colors.surfaceTableHead : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: AppText(
            title,
            style: isSelected
                ? AppTypography.labelTableHead
                : AppTypography.bodySmall,
            color: isSelected ? colors.textPrimary : colors.textMuted,
          ),
        ),
      );

  Widget _buildStockTab(
    InventoryCubit cubit,
    InventoryLoaded state,
    AppColors colors,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Controls: Search & Hide Zero Stock
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _stockSearchController,
                    hintText: StringsManager.searchInventoryHint,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 16.h,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20.sp,
                      color: colors.textMuted,
                    ),
                    suffixIcon: _stockSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            iconSize: 18.sp,
                            color: colors.textMuted,
                            onPressed: () {
                              _stockSearchController.clear();
                              cubit.setStockSearch('');
                            },
                          )
                        : null,
                    onChanged: cubit.setStockSearch,
                  ),
                ),
                SizedBox(width: 16.w),
                InkWell(
                  onTap: cubit.toggleHideZeroStock,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: state.hideZeroStock
                          ? colors.brandInboundGreen.withValues(alpha: 0.12)
                          : colors.surfaceCard,
                      border: Border.all(
                        color: state.hideZeroStock
                            ? colors.brandInboundGreen
                            : colors.borderDefault,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.hideZeroStock
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank_rounded,
                          size: 18.sp,
                          color: state.hideZeroStock
                              ? colors.brandInboundGreen
                              : colors.textMuted,
                        ),
                        SizedBox(width: 8.w),
                        AppText(
                          StringsManager.hideZeroStock,
                          style: AppTypography.bodySmall,
                          color: colors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Table
          StockLevelsTable(
            items: state.filteredStockItems,
            sortColumn: state.sortColumn,
            sortAscending: state.sortAscending,
            onSort: cubit.setSort,
          ),
        ],
      );

  Widget _buildMovementsTab(
    BuildContext context,
    InventoryCubit cubit,
    InventoryLoaded state,
    AppColors colors,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final hasDateFilter =
        state.movementDateFrom != null || state.movementDateTo != null;

    final dateRangeLabel = hasDateFilter
        ? '${state.movementDateFrom != null ? dateFormat.format(state.movementDateFrom!) : '...'} → ${state.movementDateTo != null ? dateFormat.format(state.movementDateTo!) : '...'}'
        : 'Date range';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Controls: Search, Type Filter Pills, Date Picker
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AppTextField(
                  controller: _movementSearchController,
                  hintText: StringsManager.searchInventoryHint,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 16.h,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20.sp,
                    color: colors.textMuted,
                  ),
                  suffixIcon: _movementSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          iconSize: 18.sp,
                          color: colors.textMuted,
                          onPressed: () {
                            _movementSearchController.clear();
                            cubit.setMovementSearch('');
                          },
                        )
                      : null,
                  onChanged: cubit.setMovementSearch,
                ),
              ),
              SizedBox(width: 16.w),

              // Movement type filter chips (All, Inbound, Outbound)
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: colors.borderDefault),
                ),
                padding: EdgeInsets.all(4.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPill(
                      label: StringsManager.filterAllMovements,
                      value: 'All',
                      selected: state.movementTypeFilter,
                      colors: colors,
                      onSelected: cubit.setMovementTypeFilter,
                    ),
                    SizedBox(width: 4.w),
                    _buildPill(
                      label: StringsManager.filterInboundMovement,
                      value: 'Inbound',
                      selected: state.movementTypeFilter,
                      colors: colors,
                      onSelected: cubit.setMovementTypeFilter,
                    ),
                    SizedBox(width: 4.w),
                    _buildPill(
                      label: StringsManager.filterOutboundMovement,
                      value: 'Outbound',
                      selected: state.movementTypeFilter,
                      colors: colors,
                      onSelected: cubit.setMovementTypeFilter,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),

              // Date Range Picker Button
              InkWell(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    initialDateRange: hasDateFilter
                        ? DateTimeRange(
                            start: state.movementDateFrom ?? DateTime.now(),
                            end: state.movementDateTo ?? DateTime.now(),
                          )
                        : null,
                  );
                  if (picked != null) {
                    cubit.setMovementDateRange(picked.start, picked.end);
                  }
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: hasDateFilter
                        ? colors.brandInboundGreen.withValues(alpha: 0.12)
                        : colors.surfaceCard,
                    border: Border.all(
                      color: hasDateFilter
                          ? colors.brandInboundGreen
                          : colors.borderDefault,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.date_range_outlined,
                        size: 18.sp,
                        color: hasDateFilter
                            ? colors.brandInboundGreen
                            : colors.textMuted,
                      ),
                      SizedBox(width: 8.w),
                      AppText(
                        dateRangeLabel,
                        style: AppTypography.bodySmall,
                        color: colors.textPrimary,
                      ),
                      if (hasDateFilter) ...[
                        SizedBox(width: 6.w),
                        InkWell(
                          onTap: cubit.clearMovementDateRange,
                          child: Icon(
                            Icons.close_rounded,
                            size: 16.sp,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Movements Table
        MovementsTable(
          movements: state.pagedMovements,
          currentPage: state.movementsPage,
          totalPages: state.totalMovementPages,
          onPageChanged: cubit.setMovementsPage,
        ),
      ],
    );
  }

  Widget _buildPill({
    required String label,
    required String value,
    required String selected,
    required AppColors colors,
    required ValueChanged<String> onSelected,
  }) {
    final isSelected = selected == value;
    return InkWell(
      onTap: () => onSelected(value),
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? colors.surfaceTableHead : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: AppText(
          label,
          style: isSelected
              ? AppTypography.labelTableHead.copyWith(fontSize: 13.sp)
              : AppTypography.bodySmall.copyWith(fontSize: 13.sp),
          color: isSelected ? colors.textPrimary : colors.textMuted,
        ),
      ),
    );
  }
}

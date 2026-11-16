import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:mazr3a/core/di/injection.dart';
import 'package:mazr3a/core/resources/assets_manager.dart';
import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_button.dart';
import 'package:mazr3a/core/widgets/app_snack_bar.dart';
import 'package:mazr3a/core/widgets/app_text.dart';
import 'package:mazr3a/core/widgets/app_text_field.dart';
import 'package:mazr3a/features/export/domain/model/export_scope.dart';
import 'package:mazr3a/features/export/presentation/widgets/export_excel_button.dart';
import 'package:mazr3a/features/inbound/presentation/view_model/inbound_cubit.dart';
import 'package:mazr3a/features/inbound/presentation/widgets/inbound_table.dart';

@RoutePage()
class InboundLogScreen extends StatelessWidget {
  const InboundLogScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<InboundCubit>(),
        child: const _InboundLogView(),
      );
}

class _InboundLogView extends StatelessWidget {
  const _InboundLogView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final numberFormat = NumberFormat('#,##0');

    return Scaffold(
      backgroundColor: colors.surfacePage,
      body: SafeArea(
        child: BlocConsumer<InboundCubit, InboundStates>(
          listener: (context, state) {
            if (state is InboundDeleteSuccess) {
              AppSnackBar.showSuccess(context, state.message);
            } else if (state is InboundError) {
              AppSnackBar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            final cubit = InboundCubit.of(context);

            return switch (state) {
              InboundInit() || InboundLoading() => Center(
                  child: CircularProgressIndicator(
                    color: colors.brandInboundGreen,
                  ),
                ),
              _ => Builder(
                  builder: (context) {
                    final loaded = state is InboundLoaded
                        ? state
                        : const InboundLoaded(
                            allReceipts: [],
                            filteredReceipts: [],
                          );

                    final totalStr = numberFormat.format(loaded.totalValue);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    StringsManager.inboundLog,
                                    style: AppTypography.displayH1,
                                    color: colors.textPrimary,
                                  ),
                                  const SizedBox(height: 6),
                                  AppText(
                                    '${loaded.filteredReceipts.length} records · Total EGP $totalStr',
                                    style: AppTypography.bodyRegular,
                                    color: colors.textMuted,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ExportExcelButton(
                                    scope: ExportScope.inbound,
                                    activeFilter: loaded.activeFilter,
                                    searchQuery: loaded.searchQuery,
                                  ),
                                  const SizedBox(width: 12),
                                  AppButton(
                                    text: StringsManager.plusNewReceipt,
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      size: 18,
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
                          const SizedBox(height: 28),

                          // Search & Filter Bar
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  hintText: StringsManager.searchHint,
                                  onChanged: cubit.setSearch,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: SvgPicture.asset(
                                      AssetsManager.search,
                                      width: 16,
                                      height: 16,
                                      colorFilter: ColorFilter.mode(
                                        colors.textMuted,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              _FilterChip(
                                label: StringsManager.filterAll,
                                isSelected: loaded.activeFilter == 'All',
                                onTap: () => cubit.setFilter('All'),
                              ),
                              const SizedBox(width: 10),
                              _FilterChip(
                                label: StringsManager.filterCash,
                                isSelected: loaded.activeFilter == 'Cash',
                                onTap: () => cubit.setFilter('Cash'),
                              ),
                              const SizedBox(width: 10),
                              _FilterChip(
                                label: StringsManager.filterDeferred,
                                isSelected: loaded.activeFilter == 'Deferred',
                                onTap: () => cubit.setFilter('Deferred'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Table
                          InboundTable(
                            receipts: loaded.filteredReceipts,
                            deletingId: state.deletingId,
                            onDelete: cubit.deleteRecord,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            };
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: isSelected ? colors.sidebarActive : colors.surfaceCard,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? colors.sidebarActive : colors.borderDefault,
            ),
          ),
          child: AppText(
            label,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            color: isSelected ? colors.textOnDark : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

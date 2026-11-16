import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:mazr3a/core/di/injection.dart';
import 'package:mazr3a/core/helpers/file_folder_helper.dart';
import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_snack_bar.dart';
import 'package:mazr3a/core/widgets/app_text.dart';
import 'package:mazr3a/features/export/domain/model/export_scope.dart';
import 'package:mazr3a/features/export/presentation/view_model/export_cubit.dart';
import 'package:mazr3a/features/export/presentation/widgets/export_dialog.dart';

class ExportExcelButton extends StatelessWidget {
  const ExportExcelButton({
    required this.scope,
    super.key,
    this.searchQuery,
    this.activeFilter,
    this.hideZeroStock = false,
  });

  final ExportScope scope;
  final String? searchQuery;
  final String? activeFilter;
  final bool hideZeroStock;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<ExportCubit>(),
        child: _ExportExcelButtonView(
          scope: scope,
          searchQuery: searchQuery,
          activeFilter: activeFilter,
          hideZeroStock: hideZeroStock,
        ),
      );
}

class _ExportExcelButtonView extends StatelessWidget {
  const _ExportExcelButtonView({
    required this.scope,
    this.searchQuery,
    this.activeFilter,
    this.hideZeroStock = false,
  });

  final ExportScope scope;
  final String? searchQuery;
  final String? activeFilter;
  final bool hideZeroStock;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return BlocConsumer<ExportCubit, ExportStates>(
      listener: (context, state) {
        if (state is ExportSuccess) {
          AppSnackBar.showSuccess(
            context,
            '${StringsManager.exportSaved}: ${state.filePath}',
            actionLabel: StringsManager.openFolder,
            onAction: () =>
                FileFolderHelper.openContainingFolder(state.filePath),
          );
          context.read<ExportCubit>().reset();
        } else if (state is ExportError) {
          if (state.message != StringsManager.exportCancelled) {
            AppSnackBar.showError(context, state.message);
          }
          context.read<ExportCubit>().reset();
        }
      },
      builder: (context, state) {
        final isExporting = state is ExportLoading;

        return OutlinedButton.icon(
          onPressed: isExporting ? null : () => _onPressed(context),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            side: BorderSide(color: colors.borderDefault),
            backgroundColor: colors.surfaceCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          icon: isExporting
              ? SizedBox(
                  width: 16.sp,
                  height: 16.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.brandInboundGreen,
                  ),
                )
              : Icon(
                  Icons.file_download_outlined,
                  size: 18.sp,
                  color: colors.textPrimary,
                ),
          label: AppText(
            isExporting
                ? StringsManager.exporting
                : StringsManager.exportToExcel,
            style: AppTypography.buttonPrimary.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            color: colors.textPrimary,
          ),
        );
      },
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    final cubit = context.read<ExportCubit>();
    final result = await ExportDialog.show(context);
    if (result != null && context.mounted) {
      await cubit.export(
        scope: scope,
        dateFrom: result.dateFrom,
        dateTo: result.dateTo,
        searchQuery: searchQuery,
        activeFilter: activeFilter,
        hideZeroStock: hideZeroStock,
      );
    }
  }
}

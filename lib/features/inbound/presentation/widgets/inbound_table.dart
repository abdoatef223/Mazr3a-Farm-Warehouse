import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_empty_state.dart';
import 'package:mazr3a/core/widgets/app_text.dart';
import 'package:mazr3a/core/widgets/delete_record_button.dart';
import 'package:mazr3a/core/widgets/status_badge.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';

class InboundTable extends StatelessWidget {
  const InboundTable({
    required this.receipts,
    super.key,
    this.onDelete,
    this.deletingId,
  });

  final List<InboundReceiptEntity> receipts;
  final void Function(String id)? onDelete;
  final String? deletingId;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final numberFormat = NumberFormat('#,##0.##');

    if (receipts.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.borderDefault),
        ),
        child: const AppEmptyState(
          message: 'No records yet',
          subMessage: 'Recorded inbound receipts will appear here',
          icon: Icons.inventory_2_outlined,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderDefault),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1150),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(colors.surfaceTableHead),
              dataRowMinHeight: 52,
              dataRowMaxHeight: 56,
              horizontalMargin: 20,
              columnSpacing: 24,
              columns: const [
                DataColumn(label: _TableHeadText(StringsManager.colId)),
                DataColumn(label: _TableHeadText(StringsManager.colDate)),
                DataColumn(label: _TableHeadText(StringsManager.colItem)),
                DataColumn(label: _TableHeadText(StringsManager.colCategory)),
                DataColumn(label: _TableHeadText(StringsManager.colType)),
                DataColumn(label: _TableHeadText(StringsManager.colQuantity)),
                DataColumn(label: _TableHeadText(StringsManager.colPriceUnit)),
                DataColumn(label: _TableHeadText(StringsManager.colTotal)),
                DataColumn(label: _TableHeadText(StringsManager.colSupplier)),
                DataColumn(label: _TableHeadText(StringsManager.colPayment)),
                DataColumn(label: _TableHeadText('')),
              ],
              rows: receipts.map((item) {
                final formattedTotal = numberFormat.format(item.total);
                final formattedPrice = numberFormat.format(item.pricePerUnit);
                final formattedQuantity = numberFormat.format(item.quantity);
                final isDeleting = deletingId == item.id;

                return DataRow(
                  cells: [
                    DataCell(
                      AppText(
                        item.id,
                        style: AppTypography.monoDataBold,
                        color: colors.brandInboundGreen,
                      ),
                    ),
                    DataCell(
                      AppText(
                        item.date,
                        style: AppTypography.monoData,
                        color: colors.textPrimary,
                      ),
                    ),
                    DataCell(
                      AppText(
                        item.item,
                        style: AppTypography.bodyRegular.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        color: colors.textPrimary,
                      ),
                    ),
                    DataCell(
                      AppText(
                        item.category,
                        style: AppTypography.bodyRegular,
                        color: colors.textMuted,
                      ),
                    ),
                    DataCell(
                      AppText(
                        item.type,
                        style: AppTypography.bodyRegular,
                        color: colors.textMuted,
                      ),
                    ),
                    DataCell(
                      AppText(
                        '$formattedQuantity ${item.unit}',
                        style: AppTypography.monoData,
                        color: colors.textPrimary,
                      ),
                    ),
                    DataCell(
                      AppText(
                        'EGP $formattedPrice',
                        style: AppTypography.monoData,
                        color: colors.textPrimary,
                      ),
                    ),
                    DataCell(
                      AppText(
                        'EGP $formattedTotal',
                        style: AppTypography.monoDataBold,
                        color: colors.textPrimary,
                      ),
                    ),
                    DataCell(
                      AppText(
                        item.supplier,
                        style: AppTypography.bodyRegular,
                        color: colors.textPrimary,
                      ),
                    ),
                    DataCell(
                      item.payment.toLowerCase() == 'cash'
                          ? const StatusBadge.cash()
                          : const StatusBadge.deferred(),
                    ),
                    DataCell(
                      DeleteRecordButton(
                        isDeleting: isDeleting,
                        onConfirmedDelete: () async => onDelete?.call(item.id),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _TableHeadText extends StatelessWidget {
  const _TableHeadText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AppText(
      text,
      style: AppTypography.labelTableHead,
      color: colors.textMuted,
    );
  }
}

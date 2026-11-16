import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_empty_state.dart';
import 'package:mazr3a/core/widgets/app_text.dart';
import 'package:mazr3a/core/widgets/data_table_panel.dart';
import 'package:mazr3a/core/widgets/status_badge.dart';
import 'package:mazr3a/features/dashboard/domain/entity/recent_inbound_entity.dart';

class RecentInboundPanel extends StatelessWidget {
  const RecentInboundPanel({
    required this.inbounds,
    super.key,
  });

  final List<RecentInboundEntity> inbounds;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return DataTablePanel(
      title: StringsManager.recentInbound,
      titleColor: colors.brandInboundGreen,
      headerAction: InkWell(
        onTap: () => context.router.navigatePath('/inbound/new'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.brandInboundGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: AppText(
            StringsManager.plusNew,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            color: colors.brandInboundGreen,
          ),
        ),
      ),
      footerText: inbounds.isNotEmpty ? StringsManager.viewAll : null,
      onFooterTap: () => context.router.navigatePath('/inbound/log'),
      child: inbounds.isEmpty
          ? const AppEmptyState(
              message: 'No records yet',
              subMessage: 'Recent inbound receipts will appear here',
              icon: Icons.inventory_2_outlined,
            )
          : Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.1),
                3: FlexColumnWidth(1.2),
                4: FlexColumnWidth(1.1),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: colors.borderDefault),
                    ),
                  ),
                  children: const [
                    _TableHeadCell(StringsManager.colDate),
                    _TableHeadCell(StringsManager.colItem),
                    _TableHeadCell(StringsManager.colQuantity),
                    _TableHeadCell(StringsManager.colTotal),
                    _TableHeadCell(StringsManager.colPayment),
                  ],
                ),
                for (final item in inbounds)
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colors.borderDefault.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    children: [
                      _TableTextCell(item.date, isMono: true),
                      _TableTextCell(item.item, isBold: true),
                      _TableTextCell(item.quantity, isMono: true),
                      _TableTextCell(
                        'EGP ${item.total}',
                        isMono: true,
                        isBold: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: item.payment.toLowerCase() == 'cash'
                              ? const StatusBadge.cash()
                              : const StatusBadge.deferred(),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}

class _TableHeadCell extends StatelessWidget {
  const _TableHeadCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppText(
        text,
        style: AppTypography.labelTableHead,
        color: colors.textMuted,
      ),
    );
  }
}

class _TableTextCell extends StatelessWidget {
  const _TableTextCell(
    this.text, {
    this.isMono = false,
    this.isBold = false,
  });

  final String text;
  final bool isMono;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = isMono
        ? (isBold ? AppTypography.monoDataBold : AppTypography.monoData)
        : (isBold
            ? AppTypography.bodyRegular
                .copyWith(fontWeight: FontWeight.w600)
            : AppTypography.bodyRegular);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: AppText(
        text,
        style: style,
        color: colors.textPrimary,
      ),
    );
  }
}

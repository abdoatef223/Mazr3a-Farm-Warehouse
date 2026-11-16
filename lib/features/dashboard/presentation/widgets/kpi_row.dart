import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mazr3a/core/resources/assets_manager.dart';
import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/widgets/kpi_card.dart';
import 'package:mazr3a/features/dashboard/domain/entity/dashboard_summary_entity.dart';

class KpiRow extends StatelessWidget {
  const KpiRow({
    required this.summary,
    super.key,
  });

  final DashboardSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      children: [
        KpiCard(
          title: StringsManager.totalInboundValue,
          value: summary.totalInboundValue,
          subtitle: '${summary.totalInboundCount} receipts',
          accentColor: colors.brandInboundGreen,
          icon: Icon(
            Icons.arrow_downward_rounded,
            size: 20,
            color: colors.brandInboundGreen,
          ),
        ),
        const SizedBox(width: 16),
        KpiCard(
          title: StringsManager.totalOutboundValue,
          value: summary.totalOutboundValue,
          subtitle: '${summary.totalOutboundCount} shipments',
          accentColor: colors.brandOutboundBrown,
          icon: Icon(
            Icons.arrow_upward_rounded,
            size: 20,
            color: colors.brandOutboundBrown,
          ),
        ),
        const SizedBox(width: 16),
        KpiCard(
          title: StringsManager.cashReceipts,
          value: '${summary.cashReceiptsCount}',
          subtitle: '${summary.deferredReceiptsCount} deferred',
          accentColor: colors.brandAmber,
          icon: Icon(
            Icons.account_balance_wallet_outlined,
            size: 20,
            color: colors.brandAmber,
          ),
        ),
        const SizedBox(width: 16),
        KpiCard(
          title: StringsManager.netInventoryValue,
          value: summary.netInventoryValue,
          subtitle: StringsManager.netInventoryDetail,
          accentColor: colors.brandInboundGreen,
          icon: SvgPicture.asset(
            AssetsManager.inventory,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              colors.brandInboundGreen,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}

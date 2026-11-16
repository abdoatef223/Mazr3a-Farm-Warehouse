import 'package:mazr3a/features/dashboard/domain/entity/recent_inbound_entity.dart';
import 'package:mazr3a/features/dashboard/domain/entity/recent_outbound_entity.dart';

class DashboardSummaryEntity {
  const DashboardSummaryEntity({
    required this.totalInboundValue,
    required this.totalInboundCount,
    required this.totalOutboundValue,
    required this.totalOutboundCount,
    required this.cashReceiptsCount,
    required this.deferredReceiptsCount,
    required this.netInventoryValue,
    required this.recentInbounds,
    required this.recentOutbounds,
  });

  final String totalInboundValue;
  final int totalInboundCount;
  final String totalOutboundValue;
  final int totalOutboundCount;
  final int cashReceiptsCount;
  final int deferredReceiptsCount;
  final String netInventoryValue;
  final List<RecentInboundEntity> recentInbounds;
  final List<RecentOutboundEntity> recentOutbounds;
}

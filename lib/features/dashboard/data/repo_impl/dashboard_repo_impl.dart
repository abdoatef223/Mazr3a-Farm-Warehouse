import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/dashboard/domain/entity/dashboard_summary_entity.dart';
import 'package:mazr3a/features/dashboard/domain/entity/recent_inbound_entity.dart';
import 'package:mazr3a/features/dashboard/domain/entity/recent_outbound_entity.dart';
import 'package:mazr3a/features/dashboard/domain/repo/dashboard_repo.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/inbound/domain/repo/inbound_repo.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';
import 'package:mazr3a/features/outbound/domain/repo/outbound_repo.dart';

@Injectable(as: DashboardRepo)
class DashboardRepoImpl implements DashboardRepo {
  const DashboardRepoImpl(
    this._inboundRepo,
    this._outboundRepo,
  );

  final InboundRepo _inboundRepo;
  final OutboundRepo _outboundRepo;

  @override
  FutureApiResult<DashboardSummaryEntity> getDashboardSummary({
    int limit = 10,
  }) async {
    try {
      final inboundsResult = await _inboundRepo.getInboundLog();
      final List<InboundReceiptEntity> inbounds;
      switch (inboundsResult) {
        case ApiSuccess(:final data):
          inbounds = data;
        case ApiError(:final message):
          return ApiError(message: message);
      }

      final outboundsResult = await _outboundRepo.getOutboundLog();
      final List<OutboundShipmentEntity> outbounds;
      switch (outboundsResult) {
        case ApiSuccess(:final data):
          outbounds = data;
        case ApiError(:final message):
          return ApiError(message: message);
      }

      final totalInboundVal =
          inbounds.fold(0.0, (sum, item) => sum + item.total);
      final totalOutboundVal =
          outbounds.fold(0.0, (sum, item) => sum + item.total);

      final cashCount = inbounds
          .where((item) => item.payment.toLowerCase() == 'cash')
          .length;
      final deferredCount = inbounds
          .where((item) => item.payment.toLowerCase() == 'deferred')
          .length;

      final netVal = totalInboundVal - totalOutboundVal;

      final sortedInbounds = List<InboundReceiptEntity>.from(inbounds)
        ..sort((a, b) {
          final dateComp = b.date.compareTo(a.date);
          return dateComp != 0 ? dateComp : b.id.compareTo(a.id);
        });

      final sortedOutbounds = List<OutboundShipmentEntity>.from(outbounds)
        ..sort((a, b) {
          final dateComp = b.date.compareTo(a.date);
          return dateComp != 0 ? dateComp : b.id.compareTo(a.id);
        });

      final numberFormat = NumberFormat('#,##0.00');
      final compactFormat = NumberFormat('#,##0');

      final recentInbounds = sortedInbounds.take(limit).map((i) {
        final qtyStr = i.quantity.truncateToDouble() == i.quantity
            ? i.quantity.toInt().toString()
            : i.quantity.toString();
        return RecentInboundEntity(
          id: i.id,
          date: i.date,
          item: i.item,
          quantity: '$qtyStr ${i.unit}',
          total: numberFormat.format(i.total),
          payment: i.payment,
        );
      }).toList();

      final recentOutbounds = sortedOutbounds.take(limit).map((o) {
        final qtyStr = o.quantity.truncateToDouble() == o.quantity
            ? o.quantity.toInt().toString()
            : o.quantity.toString();
        return RecentOutboundEntity(
          id: o.id,
          date: o.date,
          product: o.product,
          quantity: '$qtyStr ${o.unit}',
          total: numberFormat.format(o.total),
          type: o.type,
        );
      }).toList();

      return ApiSuccess(
        data: DashboardSummaryEntity(
          totalInboundValue: 'EGP ${compactFormat.format(totalInboundVal)}',
          totalInboundCount: inbounds.length,
          totalOutboundValue: 'EGP ${compactFormat.format(totalOutboundVal)}',
          totalOutboundCount: outbounds.length,
          cashReceiptsCount: cashCount,
          deferredReceiptsCount: deferredCount,
          netInventoryValue: 'EGP ${compactFormat.format(netVal)}',
          recentInbounds: recentInbounds,
          recentOutbounds: recentOutbounds,
        ),
      );
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }
}

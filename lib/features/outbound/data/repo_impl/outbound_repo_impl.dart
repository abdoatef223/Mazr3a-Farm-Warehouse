import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/helpers/text_normalizer.dart';
import 'package:mazr3a/core/helpers/warehouse_change_notifier.dart';
import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/inbound/data/datasource/inbound_local_datasource.dart';
import 'package:mazr3a/features/outbound/data/datasource/outbound_local_datasource.dart';
import 'package:mazr3a/features/outbound/domain/entity/inbound_product_option_entity.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';
import 'package:mazr3a/features/outbound/domain/entity/stock_level_entity.dart';
import 'package:mazr3a/features/outbound/domain/repo/outbound_repo.dart';

@Injectable(as: OutboundRepo)
class OutboundRepoImpl implements OutboundRepo {
  const OutboundRepoImpl(
    this._localDataSource,
    this._changeNotifier,
    this._inboundLocalDataSource,
  );

  final OutboundLocalDataSource _localDataSource;
  final WarehouseChangeNotifier _changeNotifier;
  final InboundLocalDataSource _inboundLocalDataSource;

  @override
  FutureApiResult<List<OutboundShipmentEntity>> getOutboundLog() async {
    try {
      final shipments = await _localDataSource.getOutboundLog();
      return ApiSuccess(data: shipments);
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  FutureApiResult<OutboundShipmentEntity> addOutboundShipment(
    OutboundShipmentEntity shipment,
  ) async {
    try {
      final created = await _localDataSource.addOutboundShipment(shipment);
      _changeNotifier.notifyChanged();
      return ApiSuccess(data: created);
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  FutureApiResult<void> deleteRecord(String id) async {
    try {
      await _localDataSource.deleteOutboundShipment(id);
      _changeNotifier.notifyChanged();
      return const ApiSuccess(data: null);
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  FutureApiResult<List<InboundProductOptionEntity>>
      getInboundProductOptions() async {
    try {
      final inbounds = await _inboundLocalDataSource.getInboundLog();
      final productMap = <String, Set<String>>{};

      for (final r in inbounds) {
        final item = r.item.trim();
        final type = r.type.trim();
        if (item.isNotEmpty) {
          productMap.putIfAbsent(item, () => <String>{});
          if (type.isNotEmpty) {
            productMap[item]!.add(type);
          }
        }
      }

      final options = productMap.entries
          .map(
            (e) => InboundProductOptionEntity(
              product: e.key,
              types: e.value.toList()..sort(),
            ),
          )
          .toList()
        ..sort((a, b) => a.product.compareTo(b.product));

      return ApiSuccess(data: options);
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  FutureApiResult<StockLevelEntity> getStockLevel({
    required String product,
    required String type,
  }) async {
    try {
      final inbounds = await _inboundLocalDataSource.getInboundLog();
      final outbounds = await _localDataSource.getOutboundLog();

      final normProd = normalizeText(product);
      final normType = normalizeText(type);

      final matchingInbounds = inbounds
          .where(
            (r) =>
                normalizeText(r.item) == normProd &&
                normalizeText(r.type) == normType,
          )
          .toList();

      final matchingOutbounds = outbounds
          .where(
            (s) =>
                normalizeText(s.product) == normProd &&
                normalizeText(s.type) == normType,
          )
          .toList();

      // Find most recent inbound record by date, then id descending
      matchingInbounds.sort((a, b) {
        final dateComp = b.date.compareTo(a.date);
        return dateComp != 0 ? dateComp : b.id.compareTo(a.id);
      });

      final latestInbound =
          matchingInbounds.isNotEmpty ? matchingInbounds.first : null;
      final unit = latestInbound?.unit ?? '';
      final latestPrice = latestInbound?.pricePerUnit ?? 0.0;

      final totalInboundQty = matchingInbounds.fold<double>(
        0.0,
        (sum, r) => sum + r.quantity,
      );
      final totalOutboundQty = matchingOutbounds.fold<double>(
        0.0,
        (sum, s) => sum + s.quantity,
      );

      final available = totalInboundQty - totalOutboundQty;

      return ApiSuccess(
        data: StockLevelEntity(
          product: product,
          type: type,
          availableQuantity: available,
          unit: unit,
          latestPrice: latestPrice,
        ),
      );
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }
}

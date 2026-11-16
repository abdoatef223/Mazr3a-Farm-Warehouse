import 'package:injectable/injectable.dart';

import 'package:mazr3a/features/inbound/data/datasource/inbound_local_datasource.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/inventory/data/datasource/inventory_local_datasource.dart';
import 'package:mazr3a/features/outbound/data/datasource/outbound_local_datasource.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';

@LazySingleton(as: InventoryLocalDataSource)
class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  const InventoryLocalDataSourceImpl(
    this._inboundLocalDataSource,
    this._outboundLocalDataSource,
  );

  final InboundLocalDataSource _inboundLocalDataSource;
  final OutboundLocalDataSource _outboundLocalDataSource;

  @override
  Future<List<InboundReceiptEntity>> getInbounds() =>
      _inboundLocalDataSource.getInboundLog();

  @override
  Future<List<OutboundShipmentEntity>> getOutbounds() =>
      _outboundLocalDataSource.getOutboundLog();
}

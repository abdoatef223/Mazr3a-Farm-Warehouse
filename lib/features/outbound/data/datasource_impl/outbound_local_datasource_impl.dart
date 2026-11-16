import 'package:injectable/injectable.dart';

import 'package:mazr3a/features/outbound/data/datasource/outbound_local_datasource.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';

@LazySingleton(as: OutboundLocalDataSource)
class OutboundLocalDataSourceImpl implements OutboundLocalDataSource {
  OutboundLocalDataSourceImpl() {
    _shipments = [];
  }

  late final List<OutboundShipmentEntity> _shipments;

  @override
  Future<List<OutboundShipmentEntity>> getOutboundLog() async =>
      List.unmodifiable(_shipments);

  @override
  Future<OutboundShipmentEntity> addOutboundShipment(
    OutboundShipmentEntity shipment,
  ) async {
    final generatedId = shipment.id.isNotEmpty
        ? shipment.id
        : 'OB-${(_shipments.length + 1).toString().padLeft(3, '0')}';

    final created = OutboundShipmentEntity(
      id: generatedId,
      date: shipment.date,
      product: shipment.product,
      type: shipment.type,
      field: shipment.field,
      quantity: shipment.quantity,
      unit: shipment.unit,
      unitPrice: shipment.unitPrice,
      total: shipment.total,
    );

    _shipments.insert(0, created);
    return created;
  }

  @override
  Future<void> deleteOutboundShipment(String id) async {
    _shipments.removeWhere((s) => s.id == id);
  }
}

import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';

abstract interface class OutboundLocalDataSource {
  Future<List<OutboundShipmentEntity>> getOutboundLog();
  Future<OutboundShipmentEntity> addOutboundShipment(
    OutboundShipmentEntity shipment,
  );
  Future<void> deleteOutboundShipment(String id);
}

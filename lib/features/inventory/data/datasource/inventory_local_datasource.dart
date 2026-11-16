import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';

abstract interface class InventoryLocalDataSource {
  Future<List<InboundReceiptEntity>> getInbounds();
  Future<List<OutboundShipmentEntity>> getOutbounds();
}

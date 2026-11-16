import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/outbound/domain/entity/inbound_product_option_entity.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';
import 'package:mazr3a/features/outbound/domain/entity/stock_level_entity.dart';

abstract interface class OutboundRepo {
  FutureApiResult<List<OutboundShipmentEntity>> getOutboundLog();
  FutureApiResult<OutboundShipmentEntity> addOutboundShipment(
    OutboundShipmentEntity shipment,
  );
  FutureApiResult<void> deleteRecord(String id);
  FutureApiResult<List<InboundProductOptionEntity>> getInboundProductOptions();
  FutureApiResult<StockLevelEntity> getStockLevel({
    required String product,
    required String type,
  });
}

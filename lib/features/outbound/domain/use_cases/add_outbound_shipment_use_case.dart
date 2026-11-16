import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';
import 'package:mazr3a/features/outbound/domain/repo/outbound_repo.dart';

@singleton
class AddOutboundShipmentUseCase {
  const AddOutboundShipmentUseCase(this._outboundRepo);

  final OutboundRepo _outboundRepo;

  FutureApiResult<OutboundShipmentEntity> call(
    OutboundShipmentEntity shipment,
  ) =>
      _outboundRepo.addOutboundShipment(shipment);
}

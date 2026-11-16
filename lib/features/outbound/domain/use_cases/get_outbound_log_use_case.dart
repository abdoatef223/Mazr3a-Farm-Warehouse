import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';
import 'package:mazr3a/features/outbound/domain/repo/outbound_repo.dart';

@singleton
class GetOutboundLogUseCase {
  const GetOutboundLogUseCase(this._outboundRepo);

  final OutboundRepo _outboundRepo;

  FutureApiResult<List<OutboundShipmentEntity>> call() =>
      _outboundRepo.getOutboundLog();
}

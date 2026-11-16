import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/outbound/domain/repo/outbound_repo.dart';

@singleton
class DeleteOutboundShipmentUseCase {
  const DeleteOutboundShipmentUseCase(this._outboundRepo);

  final OutboundRepo _outboundRepo;

  FutureApiResult<void> call(String id) => _outboundRepo.deleteRecord(id);
}

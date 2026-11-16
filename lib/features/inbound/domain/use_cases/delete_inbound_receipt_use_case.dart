import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/inbound/domain/repo/inbound_repo.dart';

@singleton
class DeleteInboundReceiptUseCase {
  const DeleteInboundReceiptUseCase(this._inboundRepo);

  final InboundRepo _inboundRepo;

  FutureApiResult<void> call(String id) => _inboundRepo.deleteRecord(id);
}

import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/inbound/domain/repo/inbound_repo.dart';

@singleton
class GetInboundLogUseCase {
  const GetInboundLogUseCase(this._inboundRepo);

  final InboundRepo _inboundRepo;

  FutureApiResult<List<InboundReceiptEntity>> call() =>
      _inboundRepo.getInboundLog();
}

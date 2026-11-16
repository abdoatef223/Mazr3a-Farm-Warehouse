import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/outbound/domain/entity/inbound_product_option_entity.dart';
import 'package:mazr3a/features/outbound/domain/repo/outbound_repo.dart';

@singleton
class GetInboundProductOptionsUseCase {
  const GetInboundProductOptionsUseCase(this._outboundRepo);

  final OutboundRepo _outboundRepo;

  FutureApiResult<List<InboundProductOptionEntity>> call() =>
      _outboundRepo.getInboundProductOptions();
}

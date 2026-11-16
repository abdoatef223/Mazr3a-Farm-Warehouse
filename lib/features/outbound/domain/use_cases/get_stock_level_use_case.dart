import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/outbound/domain/entity/stock_level_entity.dart';
import 'package:mazr3a/features/outbound/domain/repo/outbound_repo.dart';

@singleton
class GetStockLevelUseCase {
  const GetStockLevelUseCase(this._outboundRepo);

  final OutboundRepo _outboundRepo;

  FutureApiResult<StockLevelEntity> call({
    required String product,
    required String type,
  }) =>
      _outboundRepo.getStockLevel(
        product: product,
        type: type,
      );
}

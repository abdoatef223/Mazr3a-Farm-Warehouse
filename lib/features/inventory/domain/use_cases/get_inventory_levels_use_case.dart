import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_item.dart';
import 'package:mazr3a/features/inventory/domain/repo/inventory_repo.dart';

@singleton
class GetInventoryLevelsUseCase {
  const GetInventoryLevelsUseCase(this._inventoryRepo);

  final InventoryRepo _inventoryRepo;

  FutureApiResult<List<InventoryItem>> call() =>
      _inventoryRepo.getInventoryLevels();
}

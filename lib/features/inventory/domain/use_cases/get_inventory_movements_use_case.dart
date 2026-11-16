import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_movement.dart';
import 'package:mazr3a/features/inventory/domain/repo/inventory_repo.dart';

@singleton
class GetInventoryMovementsUseCase {
  const GetInventoryMovementsUseCase(this._inventoryRepo);

  final InventoryRepo _inventoryRepo;

  FutureApiResult<List<InventoryMovement>> call() =>
      _inventoryRepo.getInventoryMovements();
}

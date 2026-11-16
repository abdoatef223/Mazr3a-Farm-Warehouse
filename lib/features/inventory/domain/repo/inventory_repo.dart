import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_item.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_movement.dart';

abstract interface class InventoryRepo {
  FutureApiResult<List<InventoryItem>> getInventoryLevels();
  FutureApiResult<List<InventoryMovement>> getInventoryMovements();
}

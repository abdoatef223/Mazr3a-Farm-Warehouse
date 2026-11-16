enum MovementType {
  inbound,
  outbound,
}

class InventoryMovement {
  const InventoryMovement({
    required this.id,
    required this.date,
    required this.type,
    required this.product,
    required this.itemType,
    required this.unit,
    required this.quantity,
    required this.runningBalance,
    required this.reference,
    required this.normalizedKey,
  });

  final String id;
  final String date;
  final MovementType type;
  final String product;
  final String itemType;
  final String unit;
  /// Positive for inbound, negative for outbound.
  final double quantity;
  final double runningBalance;
  /// Supplier name for inbound, "Shipment" for outbound.
  final String reference;
  final String normalizedKey;
}

typedef InventoryMovementEntity = InventoryMovement;

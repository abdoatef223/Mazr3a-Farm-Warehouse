class OutboundShipmentEntity {
  const OutboundShipmentEntity({
    required this.id,
    required this.date,
    required this.product,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.total,
    this.field,
  });

  final String id;
  final String date;
  final String product;
  final String type;
  final String? field;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double total;
}

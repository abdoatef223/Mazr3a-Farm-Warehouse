class InboundReceiptEntity {
  const InboundReceiptEntity({
    required this.id,
    required this.date,
    required this.item,
    required this.category,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.total,
    required this.supplier,
    required this.payment,
  });

  final String id;
  final String date;
  final String item;
  final String category;
  final String type;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double total;
  final String supplier;
  final String payment;
}

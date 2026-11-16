class RecentInboundEntity {
  const RecentInboundEntity({
    required this.id,
    required this.date,
    required this.item,
    required this.quantity,
    required this.total,
    required this.payment,
  });

  final String id;
  final String date;
  final String item;
  final String quantity;
  final String total;
  final String payment;
}

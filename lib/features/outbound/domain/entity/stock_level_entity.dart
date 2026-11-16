class StockLevelEntity {
  const StockLevelEntity({
    required this.product,
    required this.type,
    required this.availableQuantity,
    required this.unit,
    required this.latestPrice,
  });

  final String product;
  final String type;
  final double availableQuantity;
  final String unit;
  final double latestPrice;
}

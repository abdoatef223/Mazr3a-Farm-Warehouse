class InventoryItem {
  const InventoryItem({
    required this.product,
    required this.type,
    required this.unit,
    required this.totalIn,
    required this.totalOut,
    required this.inStock,
    required this.lastPrice,
    required this.weightedAvgPrice,
    required this.stockValue,
    required this.normalizedKey,
  });

  final String product;
  final String type;
  final String unit;
  final double totalIn;
  final double totalOut;
  final double inStock;
  final double lastPrice;
  final double weightedAvgPrice;
  final double stockValue;
  final String normalizedKey;
}

typedef InventoryItemEntity = InventoryItem;

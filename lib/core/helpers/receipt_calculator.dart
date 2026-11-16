abstract final class ReceiptCalculator {
  static double calculateTotal({
    required String quantity,
    required String unitPrice,
  }) {
    final cleanQty = quantity.replaceAll(',', '').trim();
    final cleanPrice =
        unitPrice.replaceAll(',', '').replaceAll('EGP', '').trim();

    final q = double.tryParse(cleanQty);
    final p = double.tryParse(cleanPrice);

    if (q == null || p == null || q.isNaN || p.isNaN || q <= 0 || p <= 0) {
      return 0.0;
    }

    final total = q * p;
    if (total.isNaN || total.isInfinite || total <= 0) {
      return 0.0;
    }

    return total;
  }
}

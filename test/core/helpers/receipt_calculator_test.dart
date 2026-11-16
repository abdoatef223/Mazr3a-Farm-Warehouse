import 'package:flutter_test/flutter_test.dart';
import 'package:mazr3a/core/helpers/receipt_calculator.dart';

void main() {
  group('ReceiptCalculator.calculateTotal', () {
    test('returns correct product for valid integer inputs', () {
      final total = ReceiptCalculator.calculateTotal(
        quantity: '10',
        unitPrice: '15',
      );
      expect(total, 150.0);
    });

    test('returns correct product for valid decimal inputs', () {
      final total = ReceiptCalculator.calculateTotal(
        quantity: '2.5',
        unitPrice: '4.2',
      );
      expect(total, closeTo(10.5, 0.0001));
    });

    test('handles inputs with commas and currency symbols safely', () {
      final total = ReceiptCalculator.calculateTotal(
        quantity: '1,000',
        unitPrice: 'EGP 25.50',
      );
      expect(total, 25500.0);
    });

    test('returns 0.0 for empty inputs', () {
      expect(
        ReceiptCalculator.calculateTotal(quantity: '', unitPrice: '10'),
        0.0,
      );
      expect(
        ReceiptCalculator.calculateTotal(quantity: '10', unitPrice: ''),
        0.0,
      );
      expect(
        ReceiptCalculator.calculateTotal(quantity: '', unitPrice: ''),
        0.0,
      );
    });

    test('returns 0.0 for invalid non-numeric inputs', () {
      expect(
        ReceiptCalculator.calculateTotal(quantity: 'abc', unitPrice: '10'),
        0.0,
      );
      expect(
        ReceiptCalculator.calculateTotal(quantity: '10', unitPrice: 'xyz'),
        0.0,
      );
    });

    test('returns 0.0 for negative or zero values', () {
      expect(
        ReceiptCalculator.calculateTotal(quantity: '-5', unitPrice: '10'),
        0.0,
      );
      expect(
        ReceiptCalculator.calculateTotal(quantity: '5', unitPrice: '-10'),
        0.0,
      );
      expect(
        ReceiptCalculator.calculateTotal(quantity: '0', unitPrice: '10'),
        0.0,
      );
      expect(
        ReceiptCalculator.calculateTotal(quantity: '10', unitPrice: '0'),
        0.0,
      );
    });
  });
}

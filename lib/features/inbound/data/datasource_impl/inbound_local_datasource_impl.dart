import 'package:injectable/injectable.dart';

import 'package:mazr3a/features/inbound/data/datasource/inbound_local_datasource.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';

@LazySingleton(as: InboundLocalDataSource)
class InboundLocalDataSourceImpl implements InboundLocalDataSource {
  InboundLocalDataSourceImpl() {
    _receipts = [];
  }

  late final List<InboundReceiptEntity> _receipts;

  @override
  Future<List<InboundReceiptEntity>> getInboundLog() async =>
      List.unmodifiable(_receipts);

  @override
  Future<InboundReceiptEntity> addInboundReceipt(
    InboundReceiptEntity receipt,
  ) async {
    final generatedId = receipt.id.isNotEmpty
        ? receipt.id
        : 'IB-${(_receipts.length + 1).toString().padLeft(3, '0')}';

    final created = InboundReceiptEntity(
      id: generatedId,
      date: receipt.date,
      item: receipt.item,
      category: receipt.category,
      type: receipt.type,
      quantity: receipt.quantity,
      unit: receipt.unit,
      pricePerUnit: receipt.pricePerUnit,
      total: receipt.total,
      supplier: receipt.supplier,
      payment: receipt.payment,
    );

    _receipts.insert(0, created);
    return created;
  }

  @override
  Future<void> deleteInboundReceipt(String id) async {
    _receipts.removeWhere((r) => r.id == id);
  }
}

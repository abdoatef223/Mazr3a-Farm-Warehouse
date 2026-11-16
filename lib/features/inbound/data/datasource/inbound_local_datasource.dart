import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';

abstract interface class InboundLocalDataSource {
  Future<List<InboundReceiptEntity>> getInboundLog();
  Future<InboundReceiptEntity> addInboundReceipt(InboundReceiptEntity receipt);
  Future<void> deleteInboundReceipt(String id);
}

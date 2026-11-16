import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';

abstract interface class InboundRepo {
  FutureApiResult<List<InboundReceiptEntity>> getInboundLog();
  FutureApiResult<InboundReceiptEntity> addInboundReceipt(
    InboundReceiptEntity receipt,
  );
  FutureApiResult<void> deleteRecord(String id);
}

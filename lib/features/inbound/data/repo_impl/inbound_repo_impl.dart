import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/helpers/warehouse_change_notifier.dart';
import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/inbound/data/datasource/inbound_local_datasource.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/inbound/domain/repo/inbound_repo.dart';

@Injectable(as: InboundRepo)
class InboundRepoImpl implements InboundRepo {
  const InboundRepoImpl(
    this._localDataSource,
    this._changeNotifier,
  );

  final InboundLocalDataSource _localDataSource;
  final WarehouseChangeNotifier _changeNotifier;

  @override
  FutureApiResult<List<InboundReceiptEntity>> getInboundLog() async {
    try {
      final receipts = await _localDataSource.getInboundLog();
      return ApiSuccess(data: receipts);
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  FutureApiResult<InboundReceiptEntity> addInboundReceipt(
    InboundReceiptEntity receipt,
  ) async {
    try {
      final created = await _localDataSource.addInboundReceipt(receipt);
      _changeNotifier.notifyChanged();
      return ApiSuccess(data: created);
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  FutureApiResult<void> deleteRecord(String id) async {
    try {
      await _localDataSource.deleteInboundReceipt(id);
      _changeNotifier.notifyChanged();
      return const ApiSuccess(data: null);
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }
}

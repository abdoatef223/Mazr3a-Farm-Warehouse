import 'package:flutter_test/flutter_test.dart';
import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/dashboard/data/repo_impl/dashboard_repo_impl.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/inbound/domain/repo/inbound_repo.dart';
import 'package:mazr3a/features/outbound/domain/entity/inbound_product_option_entity.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';
import 'package:mazr3a/features/outbound/domain/entity/stock_level_entity.dart';
import 'package:mazr3a/features/outbound/domain/repo/outbound_repo.dart';

class _FakeInboundRepo implements InboundRepo {
  _FakeInboundRepo(this.receipts, {this.shouldFail = false});

  final List<InboundReceiptEntity> receipts;
  final bool shouldFail;

  @override
  FutureApiResult<List<InboundReceiptEntity>> getInboundLog() async {
    if (shouldFail) {
      return const ApiError(message: 'Failed to fetch inbound log');
    }
    return ApiSuccess(data: receipts);
  }

  @override
  FutureApiResult<InboundReceiptEntity> addInboundReceipt(
    InboundReceiptEntity receipt,
  ) async =>
      ApiSuccess(data: receipt);

  @override
  FutureApiResult<void> deleteRecord(String id) async {
    receipts.removeWhere((r) => r.id == id);
    return const ApiSuccess(data: null);
  }
}

class _FakeOutboundRepo implements OutboundRepo {
  _FakeOutboundRepo(this.shipments, {this.shouldFail = false});

  final List<OutboundShipmentEntity> shipments;
  final bool shouldFail;

  @override
  FutureApiResult<List<OutboundShipmentEntity>> getOutboundLog() async {
    if (shouldFail) {
      return const ApiError(message: 'Failed to fetch outbound log');
    }
    return ApiSuccess(data: shipments);
  }

  @override
  FutureApiResult<OutboundShipmentEntity> addOutboundShipment(
    OutboundShipmentEntity shipment,
  ) async =>
      ApiSuccess(data: shipment);

  @override
  FutureApiResult<void> deleteRecord(String id) async {
    shipments.removeWhere((s) => s.id == id);
    return const ApiSuccess(data: null);
  }

  @override
  FutureApiResult<List<InboundProductOptionEntity>>
      getInboundProductOptions() async =>
          const ApiSuccess(data: []);

  @override
  FutureApiResult<StockLevelEntity> getStockLevel({
    required String product,
    required String type,
  }) async =>
      ApiSuccess(
        data: StockLevelEntity(
          product: product,
          type: type,
          availableQuantity: 0,
          unit: 'kg',
          latestPrice: 0,
        ),
      );
}

void main() {
  group('DashboardRepoImpl - KPI calculation & limiting', () {
    test('returns empty lists and zero totals when no records exist', () async {
      final repo = DashboardRepoImpl(
        _FakeInboundRepo([]),
        _FakeOutboundRepo([]),
      );

      final result = await repo.getDashboardSummary(limit: 10);
      expect(result, isA<ApiSuccess>());

      final summary = (result as ApiSuccess).data;
      expect(summary.recentInbounds, isEmpty);
      expect(summary.recentOutbounds, isEmpty);
      expect(summary.totalInboundCount, 0);
      expect(summary.totalOutboundCount, 0);
      expect(summary.cashReceiptsCount, 0);
      expect(summary.deferredReceiptsCount, 0);
      expect(summary.totalInboundValue, 'EGP 0');
      expect(summary.totalOutboundValue, 'EGP 0');
      expect(summary.netInventoryValue, 'EGP 0');
    });

    test(
        'calculates totals, counts, net, cash vs deferred accurately',
        () async {
      final inbounds = [
        const InboundReceiptEntity(
          id: 'INB-1',
          date: '2026-03-01',
          item: 'Tomato',
          category: 'Vegetables',
          type: 'Fresh',
          quantity: 100,
          unit: 'kg',
          pricePerUnit: 10,
          total: 1000,
          supplier: 'Sinai Harvest',
          payment: 'cash',
        ),
        const InboundReceiptEntity(
          id: 'INB-2',
          date: '2026-03-02',
          item: 'Wheat',
          category: 'Grains',
          type: 'Dry',
          quantity: 50,
          unit: 'bag',
          pricePerUnit: 20,
          total: 1000,
          supplier: 'Delta Co.',
          payment: 'deferred',
        ),
      ];

      final outbounds = [
        const OutboundShipmentEntity(
          id: 'OUT-1',
          date: '2026-03-03',
          product: 'Tomato',
          type: 'Local',
          quantity: 20,
          unit: 'kg',
          unitPrice: 15,
          total: 300,
        ),
      ];

      final repo = DashboardRepoImpl(
        _FakeInboundRepo(inbounds),
        _FakeOutboundRepo(outbounds),
      );

      final result = await repo.getDashboardSummary(limit: 10);
      expect(result, isA<ApiSuccess>());

      final summary = (result as ApiSuccess).data;
      expect(summary.totalInboundCount, 2);
      expect(summary.totalOutboundCount, 1);
      expect(summary.cashReceiptsCount, 1);
      expect(summary.deferredReceiptsCount, 1);
      expect(summary.totalInboundValue, 'EGP 2,000');
      expect(summary.totalOutboundValue, 'EGP 300');
      expect(summary.netInventoryValue, 'EGP 1,700');
    });

    test(
        'limits to exactly 10 and sorts newest first when 12 records exist',
        () async {
      final inbounds = List.generate(
        12,
        (i) => InboundReceiptEntity(
          id: 'INB-${i + 1}',
          date: '2026-03-${(i + 1).toString().padLeft(2, '0')}',
          item: 'Item $i',
          category: 'Category $i',
          type: 'Fresh',
          quantity: 10,
          unit: 'kg',
          pricePerUnit: 10,
          total: 100,
          supplier: 'Supplier $i',
          payment: 'cash',
        ),
      );

      final outbounds = List.generate(
        12,
        (i) => OutboundShipmentEntity(
          id: 'OUT-${i + 1}',
          date: '2026-03-${(i + 1).toString().padLeft(2, '0')}',
          product: 'Product $i',
          type: 'Wholesale',
          quantity: 5,
          unit: 'kg',
          unitPrice: 20,
          total: 100,
        ),
      );

      final repo = DashboardRepoImpl(
        _FakeInboundRepo(inbounds),
        _FakeOutboundRepo(outbounds),
      );

      final result = await repo.getDashboardSummary(limit: 10);
      expect(result, isA<ApiSuccess>());

      final summary = (result as ApiSuccess).data;
      expect(summary.recentInbounds.length, 10);
      expect(summary.recentOutbounds.length, 10);

      // Newest first check (date 2026-03-12 is first, 2026-03-03 is 10th)
      expect(summary.recentInbounds.first.id, 'INB-12');
      expect(summary.recentInbounds.last.id, 'INB-3');
      expect(summary.recentOutbounds.first.id, 'OUT-12');
      expect(summary.recentOutbounds.last.id, 'OUT-3');
    });

    test('propagates error when an underlying repo fails', () async {
      final repo = DashboardRepoImpl(
        _FakeInboundRepo([], shouldFail: true),
        _FakeOutboundRepo([]),
      );

      final result = await repo.getDashboardSummary(limit: 10);
      expect(result, isA<ApiError>());
      expect((result as ApiError).message, 'Failed to fetch inbound log');
    });

    test('propagates error when outbound repo fails', () async {
      final repo = DashboardRepoImpl(
        _FakeInboundRepo([]),
        _FakeOutboundRepo([], shouldFail: true),
      );

      final result = await repo.getDashboardSummary(limit: 10);
      expect(result, isA<ApiError>());
      expect((result as ApiError).message, 'Failed to fetch outbound log');
    });
  });
}

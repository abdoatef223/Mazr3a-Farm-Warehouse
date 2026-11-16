import 'package:flutter_test/flutter_test.dart';
import 'package:mazr3a/core/helpers/warehouse_change_notifier.dart';
import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/inbound/data/datasource/inbound_local_datasource.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/outbound/data/datasource/outbound_local_datasource.dart';
import 'package:mazr3a/features/outbound/data/repo_impl/outbound_repo_impl.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';
import 'package:mazr3a/features/outbound/domain/use_cases/add_outbound_shipment_use_case.dart';
import 'package:mazr3a/features/outbound/domain/use_cases/delete_outbound_shipment_use_case.dart';
import 'package:mazr3a/features/outbound/domain/use_cases/get_inbound_product_options_use_case.dart';
import 'package:mazr3a/features/outbound/domain/use_cases/get_outbound_log_use_case.dart';
import 'package:mazr3a/features/outbound/domain/use_cases/get_stock_level_use_case.dart';
import 'package:mazr3a/features/outbound/presentation/view_model/outbound_cubit.dart';

class _InMemoryInboundDataSource implements InboundLocalDataSource {
  _InMemoryInboundDataSource([List<InboundReceiptEntity>? initial])
      : _receipts = List<InboundReceiptEntity>.from(initial ?? []);

  final List<InboundReceiptEntity> _receipts;

  @override
  Future<List<InboundReceiptEntity>> getInboundLog() async =>
      List.unmodifiable(_receipts);

  @override
  Future<InboundReceiptEntity> addInboundReceipt(
    InboundReceiptEntity receipt,
  ) async {
    _receipts.insert(0, receipt);
    return receipt;
  }

  @override
  Future<void> deleteInboundReceipt(String id) async {
    _receipts.removeWhere((r) => r.id == id);
  }
}

class _InMemoryOutboundDataSource implements OutboundLocalDataSource {
  _InMemoryOutboundDataSource([List<OutboundShipmentEntity>? initial])
      : _shipments = List<OutboundShipmentEntity>.from(initial ?? []);

  final List<OutboundShipmentEntity> _shipments;

  @override
  Future<List<OutboundShipmentEntity>> getOutboundLog() async =>
      List.unmodifiable(_shipments);

  @override
  Future<OutboundShipmentEntity> addOutboundShipment(
    OutboundShipmentEntity shipment,
  ) async {
    _shipments.insert(0, shipment);
    return shipment;
  }

  @override
  Future<void> deleteOutboundShipment(String id) async {
    _shipments.removeWhere((s) => s.id == id);
  }
}

void main() {
  group('OutboundRepoImpl - Inbound Integration & Stock', () {
    late _InMemoryInboundDataSource inboundDs;
    late _InMemoryOutboundDataSource outboundDs;
    late WarehouseChangeNotifier notifier;
    late OutboundRepoImpl repo;

    setUp(() {
      inboundDs = _InMemoryInboundDataSource();
      outboundDs = _InMemoryOutboundDataSource();
      notifier = WarehouseChangeNotifier();
      repo = OutboundRepoImpl(outboundDs, notifier, inboundDs);
    });

    test('empty inbound state returns empty product options', () async {
      final result = await repo.getInboundProductOptions();
      expect(result, isA<ApiSuccess<dynamic>>());
      final options = (result as ApiSuccess).data;
      expect(options, isEmpty);
    });

    test('extracts distinct products and types, excluding deleted inbound records', () async {
      await inboundDs.addInboundReceipt(
        const InboundReceiptEntity(
          id: 'IB-001',
          date: '2026-10-18',
          item: 'Tomatoes',
          category: 'Vegetables',
          type: 'Cherry',
          quantity: 100,
          unit: 'kg',
          pricePerUnit: 25.0,
          total: 2500.0,
          supplier: 'Farm A',
          payment: 'Cash',
        ),
      );
      await inboundDs.addInboundReceipt(
        const InboundReceiptEntity(
          id: 'IB-002',
          date: '2026-10-19',
          item: 'Tomatoes',
          category: 'Vegetables',
          type: 'Roma',
          quantity: 150,
          unit: 'kg',
          pricePerUnit: 20.0,
          total: 3000.0,
          supplier: 'Farm B',
          payment: 'Cash',
        ),
      );
      await inboundDs.addInboundReceipt(
        const InboundReceiptEntity(
          id: 'IB-003',
          date: '2026-10-19',
          item: 'Cucumbers',
          category: 'Vegetables',
          type: 'English',
          quantity: 80,
          unit: 'box',
          pricePerUnit: 15.0,
          total: 1200.0,
          supplier: 'Farm C',
          payment: 'Deferred',
        ),
      );

      final resultBefore = await repo.getInboundProductOptions();
      expect(resultBefore, isA<ApiSuccess<dynamic>>());
      final optionsBefore = (resultBefore as ApiSuccess).data;
      expect(optionsBefore.length, 2);

      final cucumbers = optionsBefore.firstWhere((o) => o.product == 'Cucumbers');
      expect(cucumbers.types, ['English']);

      final tomatoes = optionsBefore.firstWhere((o) => o.product == 'Tomatoes');
      expect(tomatoes.types, ['Cherry', 'Roma']);

      // Delete IB-003 (Cucumbers)
      await inboundDs.deleteInboundReceipt('IB-003');

      final resultAfter = await repo.getInboundProductOptions();
      final optionsAfter = (resultAfter as ApiSuccess).data;
      expect(optionsAfter.any((o) => o.product == 'Cucumbers'), isFalse);
      expect(optionsAfter.length, 1);
      expect(optionsAfter.first.product, 'Tomatoes');
    });

    test('getStockLevel selects latest inbound price and calculates stock accurately', () async {
      // Add older inbound record
      await inboundDs.addInboundReceipt(
        const InboundReceiptEntity(
          id: 'IB-001',
          date: '2026-10-10',
          item: 'Apples',
          category: 'Fruits',
          type: 'Fuji',
          quantity: 200,
          unit: 'kg',
          pricePerUnit: 30.0,
          total: 6000.0,
          supplier: 'Supplier 1',
          payment: 'Cash',
        ),
      );

      // Add newer inbound record with updated price
      await inboundDs.addInboundReceipt(
        const InboundReceiptEntity(
          id: 'IB-002',
          date: '2026-10-15',
          item: 'Apples',
          category: 'Fruits',
          type: 'Fuji',
          quantity: 300,
          unit: 'kg',
          pricePerUnit: 35.5,
          total: 10650.0,
          supplier: 'Supplier 2',
          payment: 'Cash',
        ),
      );

      // Add outbound shipment
      await outboundDs.addOutboundShipment(
        const OutboundShipmentEntity(
          id: 'OB-001',
          date: '2026-10-16',
          product: 'Apples',
          type: 'Fuji',
          quantity: 120,
          unit: 'kg',
          unitPrice: 45.0,
          total: 5400.0,
          field: 'Field North',
        ),
      );

      final stockResult = await repo.getStockLevel(product: 'Apples', type: 'Fuji');
      expect(stockResult, isA<ApiSuccess<dynamic>>());
      final stock = (stockResult as ApiSuccess).data;

      // Inbound: 200 + 300 = 500. Outbound: 120. Available: 380.
      expect(stock.availableQuantity, 380.0);
      expect(stock.unit, 'kg');
      // Latest inbound price should be 35.5 (from IB-002, dated 2026-10-15)
      expect(stock.latestPrice, 35.5);
    });

    test('deleting outbound shipment restores available stock', () async {
      await inboundDs.addInboundReceipt(
        const InboundReceiptEntity(
          id: 'IB-001',
          date: '2026-10-10',
          item: 'Oranges',
          category: 'Fruits',
          type: 'Valencia',
          quantity: 500,
          unit: 'crate',
          pricePerUnit: 50.0,
          total: 25000.0,
          supplier: 'Supplier 1',
          payment: 'Cash',
        ),
      );

      await outboundDs.addOutboundShipment(
        const OutboundShipmentEntity(
          id: 'OB-001',
          date: '2026-10-12',
          product: 'Oranges',
          type: 'Valencia',
          quantity: 150,
          unit: 'crate',
          unitPrice: 65.0,
          total: 9750.0,
          field: 'East Plot',
        ),
      );

      var stock = (await repo.getStockLevel(product: 'Oranges', type: 'Valencia')
              as ApiSuccess)
          .data;
      expect(stock.availableQuantity, 350.0);

      await repo.deleteRecord('OB-001');

      stock = (await repo.getStockLevel(product: 'Oranges', type: 'Valencia')
              as ApiSuccess)
          .data;
      expect(stock.availableQuantity, 500.0);
    });
  });

  group('OutboundCubit - State, Over-Quantity Warning & Reset', () {
    late _InMemoryInboundDataSource inboundDs;
    late _InMemoryOutboundDataSource outboundDs;
    late WarehouseChangeNotifier notifier;
    late OutboundRepoImpl repo;
    late OutboundCubit cubit;

    setUp(() {
      inboundDs = _InMemoryInboundDataSource([
        const InboundReceiptEntity(
          id: 'IB-001',
          date: '2026-10-10',
          item: 'Wheat',
          category: 'Grains',
          type: 'Hard Red',
          quantity: 1000,
          unit: 'ton',
          pricePerUnit: 200.0,
          total: 200000.0,
          supplier: 'Grain Supplier',
          payment: 'Cash',
        ),
      ]);
      outboundDs = _InMemoryOutboundDataSource([
        const OutboundShipmentEntity(
          id: 'OB-001',
          date: '2026-10-12',
          product: 'Wheat',
          type: 'Hard Red',
          quantity: 400,
          unit: 'ton',
          unitPrice: 240.0,
          total: 96000.0,
          field: 'Sector 4',
        ),
      ]);
      notifier = WarehouseChangeNotifier();
      repo = OutboundRepoImpl(outboundDs, notifier, inboundDs);

      cubit = OutboundCubit(
        GetOutboundLogUseCase(repo),
        AddOutboundShipmentUseCase(repo),
        DeleteOutboundShipmentUseCase(repo),
        GetInboundProductOptionsUseCase(repo),
        GetStockLevelUseCase(repo),
        notifier,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('selectProduct updates product and clears previous selections', () async {
      await cubit.loadProductOptions();
      expect(cubit.state.options.length, 1);
      expect(cubit.state.options.first.product, 'Wheat');

      cubit.selectProduct('Wheat');
      expect(cubit.state.selectedProduct, 'Wheat');
      expect(cubit.state.selectedType, isNull);
      expect(cubit.state.unit, isNull);
      expect(cubit.state.unitPrice, isNull);
      expect(cubit.state.availableQuantity, isNull);
      expect(cubit.state.quantityWarning, isNull);
    });

    test('selectType populates unit, latest price, available stock and calculates total', () async {
      await cubit.loadProductOptions();
      cubit.selectProduct('Wheat');
      await cubit.selectType('Hard Red', currentQuantity: '200');

      expect(cubit.state.selectedProduct, 'Wheat');
      expect(cubit.state.selectedType, 'Hard Red');
      expect(cubit.state.unit, 'ton');
      expect(cubit.state.unitPrice, 200.0);
      // Available: 1000 - 400 = 600
      expect(cubit.state.availableQuantity, 600.0);
      expect(cubit.state.quantityWarning, isNull);
      // Total: 200 * 200 = 40000
      expect(cubit.state.liveTotal, 40000.0);
    });

    test('updateQuantity triggers warning when quantity exceeds available stock', () async {
      await cubit.loadProductOptions();
      cubit.selectProduct('Wheat');
      await cubit.selectType('Hard Red');

      expect(cubit.state.availableQuantity, 600.0);

      // Within available stock: 500 <= 600
      cubit.updateQuantity(quantity: '500');
      expect(cubit.state.quantityWarning, isNull);
      expect(cubit.state.liveTotal, 500 * 200.0);

      // Exceeds available stock: 700 > 600
      cubit.updateQuantity(quantity: '700');
      expect(cubit.state.quantityWarning, isNotNull);
      expect(cubit.state.liveTotal, 700 * 200.0);

      // Back to valid amount
      cubit.updateQuantity(quantity: '600');
      expect(cubit.state.quantityWarning, isNull);
    });

    test('snapshot storage: saves shipment with snapshot values and optional field', () async {
      const shipment = OutboundShipmentEntity(
        id: 'OB-002',
        date: '2026-10-20',
        product: 'Wheat',
        type: 'Hard Red',
        quantity: 150,
        unit: 'ton',
        unitPrice: 260.0,
        total: 39000.0,
        field: 'North Field A',
      );

      await cubit.addShipment(shipment);

      final logResult = await repo.getOutboundLog();
      final shipments = (logResult as ApiSuccess).data;
      expect(shipments.any((s) => s.id == 'OB-002'), isTrue);

      final saved = shipments.firstWhere((s) => s.id == 'OB-002');
      expect(saved.product, 'Wheat');
      expect(saved.type, 'Hard Red');
      expect(saved.quantity, 150.0);
      expect(saved.unit, 'ton');
      expect(saved.unitPrice, 260.0);
      expect(saved.total, 39000.0);
      expect(saved.field, 'North Field A');
    });

    test('warehouse change notifier triggers options reload', () async {
      await cubit.loadProductOptions();
      expect(cubit.state.options.length, 1);

      // Add a new inbound receipt
      await inboundDs.addInboundReceipt(
        const InboundReceiptEntity(
          id: 'IB-002',
          date: '2026-10-21',
          item: 'Barley',
          category: 'Grains',
          type: 'Two-Row',
          quantity: 300,
          unit: 'ton',
          pricePerUnit: 180.0,
          total: 54000.0,
          supplier: 'Grain Supplier 2',
          payment: 'Cash',
        ),
      );

      // Notify warehouse changed
      notifier.notifyChanged();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(cubit.state.options.length, 2);
      expect(cubit.state.options.any((o) => o.product == 'Barley'), isTrue);
    });
  });
}

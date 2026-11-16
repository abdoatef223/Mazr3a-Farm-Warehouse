import 'package:flutter_test/flutter_test.dart';
import 'package:mazr3a/core/helpers/text_normalizer.dart';
import 'package:mazr3a/core/helpers/warehouse_change_notifier.dart';
import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/inventory/data/datasource/inventory_local_datasource.dart';
import 'package:mazr3a/features/inventory/data/repo_impl/inventory_repo_impl.dart';
import 'package:mazr3a/features/inventory/domain/use_cases/get_inventory_levels_use_case.dart';
import 'package:mazr3a/features/inventory/domain/use_cases/get_inventory_movements_use_case.dart';
import 'package:mazr3a/features/inventory/presentation/view_model/inventory_cubit.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';

class _FakeInventoryLocalDataSource implements InventoryLocalDataSource {
  _FakeInventoryLocalDataSource({
    List<InboundReceiptEntity>? inbounds,
    List<OutboundShipmentEntity>? outbounds,
  })  : _inbounds = inbounds ?? [],
        _outbounds = outbounds ?? [];

  final List<InboundReceiptEntity> _inbounds;
  final List<OutboundShipmentEntity> _outbounds;

  @override
  Future<List<InboundReceiptEntity>> getInbounds() async =>
      List.unmodifiable(_inbounds);

  @override
  Future<List<OutboundShipmentEntity>> getOutbounds() async =>
      List.unmodifiable(_outbounds);

  void addInbound(InboundReceiptEntity receipt) => _inbounds.insert(0, receipt);
  void addOutbound(OutboundShipmentEntity shipment) =>
      _outbounds.insert(0, shipment);
  void deleteInbound(String id) => _inbounds.removeWhere((r) => r.id == id);
  void deleteOutbound(String id) => _outbounds.removeWhere((s) => s.id == id);
}

void main() {
  group('Text Normalizer Tests', () {
    test('Arabic variants merge into the same normalized string', () {
      expect(normalizeText('أسمدة'), normalizeText('اسمدة'));
      expect(normalizeText('إسمنت'), normalizeText('اسمنت'));
      expect(normalizeText('آلات'), normalizeText('الات'));
      expect(normalizeText('حَبَّاتٌ'), normalizeText('حبات'));
      expect(normalizeText('طـمـاطـم'), normalizeText('طماطم'));
      expect(normalizeText('ذرة شامي'), normalizeText('ذرة شامى'));
      expect(normalizeText('شجرة'), normalizeText('شجره'));
    });

    test('Collapses whitespace and lowercases Latin letters', () {
      expect(normalizeText('  Sweet   Orange  '), 'sweet orange');
      expect(normalizeText('Fuji   Apple'), 'fuji apple');
    });
  });

  group('InventoryRepoImpl Unit Tests', () {
    late _FakeInventoryLocalDataSource dataSource;
    late InventoryRepoImpl repo;

    setUp(() {
      dataSource = _FakeInventoryLocalDataSource();
      repo = InventoryRepoImpl(dataSource);
    });

    test('1. stock = inbound - outbound for one group', () async {
      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-001',
          date: '2026-10-10',
          item: 'Wheat',
          category: 'Grains',
          type: 'Giza 171',
          quantity: 100,
          unit: 'kg',
          pricePerUnit: 15.0,
          total: 1500.0,
          supplier: 'Sinai Co.',
          payment: 'Cash',
        ),
      );

      dataSource.addOutbound(
        const OutboundShipmentEntity(
          id: 'OB-001',
          date: '2026-10-12',
          product: 'Wheat',
          type: 'Giza 171',
          quantity: 40,
          unit: 'kg',
          unitPrice: 20.0,
          total: 800.0,
        ),
      );

      final result = await repo.getInventoryLevels();
      expect(result, isA<ApiSuccess<dynamic>>());
      final items = (result as ApiSuccess).data;
      expect(items.length, 1);

      final item = items.first;
      expect(item.product, 'Wheat');
      expect(item.type, 'Giza 171');
      expect(item.unit, 'kg');
      expect(item.totalIn, 100.0);
      expect(item.totalOut, 40.0);
      expect(item.inStock, 60.0);
      expect(item.lastPrice, 15.0);
      expect(item.stockValue, 60.0 * 15.0);
    });

    test('2. two groups with different units stay separate', () async {
      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-001',
          date: '2026-10-10',
          item: 'Tomatoes',
          category: 'Vegetables',
          type: 'Cherry',
          quantity: 50,
          unit: 'kg',
          pricePerUnit: 20.0,
          total: 1000.0,
          supplier: 'Farm A',
          payment: 'Cash',
        ),
      );

      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-002',
          date: '2026-10-11',
          item: 'Tomatoes',
          category: 'Vegetables',
          type: 'Cherry',
          quantity: 20,
          unit: 'box',
          pricePerUnit: 180.0,
          total: 3600.0,
          supplier: 'Farm B',
          payment: 'Cash',
        ),
      );

      final result = await repo.getInventoryLevels();
      final items = (result as ApiSuccess).data;
      expect(items.length, 2);

      final kgItem = items.firstWhere((i) => i.unit == 'kg');
      final boxItem = items.firstWhere((i) => i.unit == 'box');

      expect(kgItem.totalIn, 50.0);
      expect(boxItem.totalIn, 20.0);
    });

    test('3. deleted inbound/outbound records are excluded from calculation',
        () async {
      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-001',
          date: '2026-10-10',
          item: 'Barley',
          category: 'Grains',
          type: 'Spring',
          quantity: 200,
          unit: 'ton',
          pricePerUnit: 300.0,
          total: 60000.0,
          supplier: 'Farm 1',
          payment: 'Cash',
        ),
      );

      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-002',
          date: '2026-10-11',
          item: 'Barley',
          category: 'Grains',
          type: 'Spring',
          quantity: 100,
          unit: 'ton',
          pricePerUnit: 300.0,
          total: 30000.0,
          supplier: 'Farm 2',
          payment: 'Cash',
        ),
      );

      dataSource.addOutbound(
        const OutboundShipmentEntity(
          id: 'OB-001',
          date: '2026-10-12',
          product: 'Barley',
          type: 'Spring',
          quantity: 50,
          unit: 'ton',
          unitPrice: 350.0,
          total: 17500.0,
        ),
      );

      // Initial: in: 300, out: 50 -> inStock: 250
      var items = (await repo.getInventoryLevels() as ApiSuccess).data;
      expect(items.first.inStock, 250.0);

      // Delete IB-002 (100 ton)
      dataSource.deleteInbound('IB-002');
      items = (await repo.getInventoryLevels() as ApiSuccess).data;
      expect(items.first.totalIn, 200.0);
      expect(items.first.inStock, 150.0);

      // Delete OB-001 (50 ton)
      dataSource.deleteOutbound('OB-001');
      items = (await repo.getInventoryLevels() as ApiSuccess).data;
      expect(items.first.totalOut, 0.0);
      expect(items.first.inStock, 200.0);
    });

    test('4. negative stock appears when shipment has no or insufficient inbound',
        () async {
      dataSource.addOutbound(
        const OutboundShipmentEntity(
          id: 'OB-001',
          date: '2026-10-15',
          product: 'Potatoes',
          type: 'Spunta',
          quantity: 75,
          unit: 'bag',
          unitPrice: 50.0,
          total: 3750.0,
        ),
      );

      final result = await repo.getInventoryLevels();
      final items = (result as ApiSuccess).data;
      expect(items.length, 1);

      final item = items.first;
      expect(item.product, 'Potatoes');
      expect(item.type, 'Spunta');
      expect(item.unit, 'bag');
      expect(item.totalIn, 0.0);
      expect(item.totalOut, 75.0);
      expect(item.inStock, -75.0);
      expect(item.lastPrice, 0.0);
      expect(item.stockValue, 0.0); // Negative stock has 0 stock value
    });

    test('5. Arabic variants ("اسمدة" and "أسمدة") merge into one row',
        () async {
      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-001',
          date: '2026-10-01',
          item: 'أسمدة',
          category: 'Chemicals',
          type: 'NPK',
          quantity: 100,
          unit: 'bag',
          pricePerUnit: 250.0,
          total: 25000.0,
          supplier: 'Delta',
          payment: 'Cash',
        ),
      );

      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-002',
          date: '2026-10-05',
          item: 'اسمدة',
          category: 'Chemicals',
          type: 'NPK',
          quantity: 150,
          unit: 'bag',
          pricePerUnit: 260.0,
          total: 39000.0,
          supplier: 'Delta 2',
          payment: 'Cash',
        ),
      );

      final result = await repo.getInventoryLevels();
      final items = (result as ApiSuccess).data;
      expect(items.length, 1);

      final merged = items.first;
      expect(merged.totalIn, 250.0);
      // Display label is from the most recent inbound record (IB-002: 2026-10-05)
      expect(merged.product, 'اسمدة');
      expect(merged.lastPrice, 260.0);
    });

    test('6. weighted average price and stock value calculation', () async {
      // Receipt 1: 100 units @ 10 EGP = 1000 EGP
      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-001',
          date: '2026-10-01',
          item: 'Olives',
          category: 'Fruits',
          type: 'Kalamata',
          quantity: 100,
          unit: 'kg',
          pricePerUnit: 10.0,
          total: 1000.0,
          supplier: 'Farm S',
          payment: 'Cash',
        ),
      );

      // Receipt 2: 200 units @ 25 EGP = 5000 EGP
      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-002',
          date: '2026-10-05',
          item: 'Olives',
          category: 'Fruits',
          type: 'Kalamata',
          quantity: 200,
          unit: 'kg',
          pricePerUnit: 25.0,
          total: 5000.0,
          supplier: 'Farm S',
          payment: 'Cash',
        ),
      );

      // Total inbound value = 6000, Total inbound quantity = 300
      // Weighted average price = 6000 / 300 = 20.0 EGP / unit

      // Outbound 50 units -> In Stock: 250 units
      dataSource.addOutbound(
        const OutboundShipmentEntity(
          id: 'OB-001',
          date: '2026-10-06',
          product: 'Olives',
          type: 'Kalamata',
          quantity: 50,
          unit: 'kg',
          unitPrice: 35.0,
          total: 1750.0,
        ),
      );

      final result = await repo.getInventoryLevels();
      final item = (result as ApiSuccess).data.first;

      expect(item.totalIn, 300.0);
      expect(item.totalOut, 50.0);
      expect(item.inStock, 250.0);
      expect(item.lastPrice, 25.0); // Most recent inbound price
      expect(item.weightedAvgPrice, 20.0);
      // Stock value = 250 * 20.0 = 5000.0
      expect(item.stockValue, 5000.0);
    });

    test('8. running balance order in Movements', () async {
      // Oct 10: Inbound +100 (balance: 100)
      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-001',
          date: '2026-10-10',
          item: 'Corn',
          category: 'Grains',
          type: 'Yellow',
          quantity: 100,
          unit: 'ton',
          pricePerUnit: 50.0,
          total: 5000.0,
          supplier: 'Corn Farm',
          payment: 'Cash',
        ),
      );

      // Oct 12: Outbound -30 (balance: 70)
      dataSource.addOutbound(
        const OutboundShipmentEntity(
          id: 'OB-001',
          date: '2026-10-12',
          product: 'Corn',
          type: 'Yellow',
          quantity: 30,
          unit: 'ton',
          unitPrice: 65.0,
          total: 1950.0,
        ),
      );

      // Oct 15: Inbound +50 (balance: 120)
      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-002',
          date: '2026-10-15',
          item: 'Corn',
          category: 'Grains',
          type: 'Yellow',
          quantity: 50,
          unit: 'ton',
          pricePerUnit: 52.0,
          total: 2600.0,
          supplier: 'Corn Farm 2',
          payment: 'Cash',
        ),
      );

      // Oct 18: Outbound -40 (balance: 80)
      dataSource.addOutbound(
        const OutboundShipmentEntity(
          id: 'OB-002',
          date: '2026-10-18',
          product: 'Corn',
          type: 'Yellow',
          quantity: 40,
          unit: 'ton',
          unitPrice: 70.0,
          total: 2800.0,
        ),
      );

      final result = await repo.getInventoryMovements();
      final movements = (result as ApiSuccess).data;
      expect(movements.length, 4);

      // Movements returned newest first: OB-002 (Oct 18), IB-002 (Oct 15), OB-001 (Oct 12), IB-001 (Oct 10)
      expect(movements[0].id, 'OB-002');
      expect(movements[0].quantity, -40.0);
      expect(movements[0].runningBalance, 80.0);

      expect(movements[1].id, 'IB-002');
      expect(movements[1].quantity, 50.0);
      expect(movements[1].runningBalance, 120.0);

      expect(movements[2].id, 'OB-001');
      expect(movements[2].quantity, -30.0);
      expect(movements[2].runningBalance, 70.0);

      expect(movements[3].id, 'IB-001');
      expect(movements[3].quantity, 100.0);
      expect(movements[3].runningBalance, 100.0);
    });

    test('9. empty warehouse returns empty lists and empty state', () async {
      final levelsResult = await repo.getInventoryLevels();
      final movementsResult = await repo.getInventoryMovements();

      expect((levelsResult as ApiSuccess).data, isEmpty);
      expect((movementsResult as ApiSuccess).data, isEmpty);
    });
  });

  group('InventoryCubit & Reactive Updates Tests', () {
    late _FakeInventoryLocalDataSource dataSource;
    late WarehouseChangeNotifier notifier;
    late InventoryRepoImpl repo;
    late InventoryCubit cubit;

    setUp(() {
      dataSource = _FakeInventoryLocalDataSource();
      notifier = WarehouseChangeNotifier();
      repo = InventoryRepoImpl(dataSource);
      cubit = InventoryCubit(
        GetInventoryLevelsUseCase(repo),
        GetInventoryMovementsUseCase(repo),
        notifier,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('7. hide-zero toggle filters out zero-stock items while preserving others',
        () async {
      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-001',
          date: '2026-10-10',
          item: 'Item Zero',
          category: 'Test',
          type: 'A',
          quantity: 50,
          unit: 'kg',
          pricePerUnit: 10.0,
          total: 500.0,
          supplier: 'S',
          payment: 'Cash',
        ),
      );
      dataSource.addOutbound(
        const OutboundShipmentEntity(
          id: 'OB-001',
          date: '2026-10-11',
          product: 'Item Zero',
          type: 'A',
          quantity: 50,
          unit: 'kg',
          unitPrice: 12.0,
          total: 600.0,
        ),
      );

      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-002',
          date: '2026-10-10',
          item: 'Item Positive',
          category: 'Test',
          type: 'B',
          quantity: 100,
          unit: 'kg',
          pricePerUnit: 15.0,
          total: 1500.0,
          supplier: 'S',
          payment: 'Cash',
        ),
      );

      await cubit.loadInventory();
      var state = cubit.state as InventoryLoaded;
      expect(state.allStockItems.length, 2);
      expect(state.filteredStockItems.length, 2);

      // Toggle hide zero stock -> only Item Positive remains
      cubit.toggleHideZeroStock();
      state = cubit.state as InventoryLoaded;
      expect(state.hideZeroStock, isTrue);
      expect(state.filteredStockItems.length, 1);
      expect(state.filteredStockItems.first.product, 'Item Positive');

      // Toggle back -> both appear
      cubit.toggleHideZeroStock();
      state = cubit.state as InventoryLoaded;
      expect(state.hideZeroStock, isFalse);
      expect(state.filteredStockItems.length, 2);
    });

    test(
        '10. saving an outbound shipment reduces In Stock without a manual reload via WarehouseChangeNotifier',
        () async {
      dataSource.addInbound(
        const InboundReceiptEntity(
          id: 'IB-001',
          date: '2026-10-10',
          item: 'Apples',
          category: 'Fruits',
          type: 'Golden',
          quantity: 500,
          unit: 'kg',
          pricePerUnit: 30.0,
          total: 15000.0,
          supplier: 'Apple Orchards',
          payment: 'Cash',
        ),
      );

      await cubit.loadInventory();
      var state = cubit.state as InventoryLoaded;
      expect(state.filteredStockItems.first.inStock, 500.0);

      // An outbound shipment is saved by the outbound feature
      dataSource.addOutbound(
        const OutboundShipmentEntity(
          id: 'OB-001',
          date: '2026-10-12',
          product: 'Apples',
          type: 'Golden',
          quantity: 120,
          unit: 'kg',
          unitPrice: 40.0,
          total: 4800.0,
        ),
      );

      // OutboundRepo notifies the warehouse changed
      notifier.notifyChanged();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Inventory cubit automatically reloaded!
      state = cubit.state as InventoryLoaded;
      expect(state.filteredStockItems.first.inStock, 380.0);
      expect(state.allMovements.length, 2);
    });
  });
}

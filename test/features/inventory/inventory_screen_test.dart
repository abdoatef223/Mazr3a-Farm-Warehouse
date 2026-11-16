import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mazr3a/core/di/injection.dart';
import 'package:mazr3a/core/helpers/warehouse_change_notifier.dart';
import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/theme_modes.dart';
import 'package:mazr3a/features/export/domain/model/export_params.dart';
import 'package:mazr3a/features/export/domain/repo/export_repo.dart';
import 'package:mazr3a/features/export/domain/use_cases/export_to_excel_use_case.dart';
import 'package:mazr3a/features/export/presentation/view_model/export_cubit.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/inventory/data/datasource/inventory_local_datasource.dart';
import 'package:mazr3a/features/inventory/data/repo_impl/inventory_repo_impl.dart';
import 'package:mazr3a/features/inventory/domain/use_cases/get_inventory_levels_use_case.dart';
import 'package:mazr3a/features/inventory/domain/use_cases/get_inventory_movements_use_case.dart';
import 'package:mazr3a/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:mazr3a/features/inventory/presentation/view_model/inventory_cubit.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';

class _FakeInventoryDs implements InventoryLocalDataSource {
  _FakeInventoryDs({
    List<InboundReceiptEntity>? inbounds,
    List<OutboundShipmentEntity>? outbounds,
  })  : inbounds = inbounds ?? [],
        outbounds = outbounds ?? [];

  final List<InboundReceiptEntity> inbounds;
  final List<OutboundShipmentEntity> outbounds;

  @override
  Future<List<InboundReceiptEntity>> getInbounds() async => inbounds;

  @override
  Future<List<OutboundShipmentEntity>> getOutbounds() async => outbounds;
}

class _FakeExportRepo implements ExportRepo {
  @override
  FutureApiResult<String> exportToExcel(ExportParams params) async =>
      const ApiSuccess(data: 'C:/exports/inventory.xlsx');
}

void main() {
  Widget buildTestableWidget({TextScaler? textScaler}) => ScreenUtilPlusInit(
        designSize: const Size(1920, 900),
        minTextAdapt: true,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: textScaler ?? TextScaler.noScaling,
          ),
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: InventoryScreen(),
            ),
          ),
        ),
      );

  tearDown(() {
    getIt.reset();
  });

  testWidgets('renders empty state when warehouse has no records', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final ds = _FakeInventoryDs();
    final notifier = WarehouseChangeNotifier();
    final repo = InventoryRepoImpl(ds);

    getIt.registerFactory<InventoryCubit>(
      () => InventoryCubit(
        GetInventoryLevelsUseCase(repo),
        GetInventoryMovementsUseCase(repo),
        notifier,
      ),
    );
    getIt.registerFactory<ExportCubit>(
      () => ExportCubit(ExportToExcelUseCase(_FakeExportRepo())),
    );

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text(StringsManager.inventoryTitle), findsOneWidget);
    expect(find.text(StringsManager.tabStockLevels), findsOneWidget);
    expect(find.text(StringsManager.tabMovements), findsOneWidget);
    expect(find.text(StringsManager.emptyInventoryPrompt), findsOneWidget);
    // Button shows "New Receipt" without a double plus
    expect(find.text(StringsManager.newReceipt), findsAtLeast(1));
  });

  testWidgets('renders Stock Levels table with proper pluralization and switches to Movements tab', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final ds = _FakeInventoryDs(
      inbounds: [
        const InboundReceiptEntity(
          id: 'rec-1',
          date: '2026-10-01',
          item: 'Urea 46%',
          category: 'Fertilizer',
          type: 'Granular',
          supplier: 'Delta Chem',
          quantity: 100,
          unit: 'Bag',
          pricePerUnit: 25.0,
          total: 2500.0,
          payment: 'Cash',
        ),
      ],
      outbounds: [
        const OutboundShipmentEntity(
          id: 'ship-1',
          date: '2026-10-05',
          product: 'Urea 46%',
          type: 'Granular',
          quantity: 30,
          unit: 'Bag',
          unitPrice: 35.0,
          total: 1050.0,
          field: 'North Field',
        ),
      ],
    );
    final notifier = WarehouseChangeNotifier();
    final repo = InventoryRepoImpl(ds);

    getIt.registerFactory<InventoryCubit>(
      () => InventoryCubit(
        GetInventoryLevelsUseCase(repo),
        GetInventoryMovementsUseCase(repo),
        notifier,
      ),
    );
    getIt.registerFactory<ExportCubit>(
      () => ExportCubit(ExportToExcelUseCase(_FakeExportRepo())),
    );

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify Stock Levels table items
    expect(find.text('Urea 46%'), findsOneWidget);
    expect(find.text('Granular'), findsOneWidget);
    expect(find.text('Bag'), findsOneWidget);
    expect(find.text('100'), findsOneWidget); // Total In
    expect(find.text('30'), findsOneWidget); // Total Out
    expect(find.text('70'), findsOneWidget); // In Stock

    // Proper singular pluralization check: "1 record"
    expect(find.text(StringsManager.recordsCountPlural(1)), findsOneWidget);
    expect(find.text('1 record'), findsOneWidget);

    // Switch to Movements Tab
    await tester.tap(find.text(StringsManager.tabMovements));
    await tester.pumpAndSettle();

    // Verify Movements view renders
    expect(find.text('Delta Chem'), findsOneWidget);
    expect(find.text(StringsManager.shipmentReference), findsOneWidget);
    expect(find.text('+100'), findsOneWidget);
    expect(find.text('-30'), findsOneWidget);
  });

  testWidgets('renders at 1920x1080 without overflow and header/data rows have equal width', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final ds = _FakeInventoryDs(
      inbounds: [
        const InboundReceiptEntity(
          id: 'rec-1',
          date: '2026-10-01',
          item: 'Urea 46%',
          category: 'Fertilizer',
          type: 'Granular',
          supplier: 'Delta Chem',
          quantity: 100,
          unit: 'Bag',
          pricePerUnit: 25.0,
          total: 2500.0,
          payment: 'Cash',
        ),
      ],
      outbounds: [
        const OutboundShipmentEntity(
          id: 'ship-1',
          date: '2026-10-05',
          product: 'Urea 46%',
          type: 'Granular',
          quantity: 30,
          unit: 'Bag',
          unitPrice: 35.0,
          total: 1050.0,
          field: 'North Field',
        ),
      ],
    );
    final notifier = WarehouseChangeNotifier();
    final repo = InventoryRepoImpl(ds);

    getIt.registerFactory<InventoryCubit>(
      () => InventoryCubit(
        GetInventoryLevelsUseCase(repo),
        GetInventoryMovementsUseCase(repo),
        notifier,
      ),
    );
    getIt.registerFactory<ExportCubit>(
      () => ExportCubit(ExportToExcelUseCase(_FakeExportRepo())),
    );

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Verify header and data row have equal width
    final headerFinder = find.byKey(const ValueKey('stock_levels_header'));
    final rowFinder = find.byKey(const ValueKey('stock_levels_row_Urea 46%'));

    expect(headerFinder, findsOneWidget);
    expect(rowFinder, findsOneWidget);

    final headerWidth = tester.getSize(headerFinder).width;
    final rowWidth = tester.getSize(rowFinder).width;
    expect(headerWidth, equals(rowWidth));
  });

  testWidgets('renders at narrow 1100px width with 1.3x text scale without overflow exceptions', (tester) async {
    tester.view.physicalSize = const Size(1100, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final ds = _FakeInventoryDs(
      inbounds: [
        const InboundReceiptEntity(
          id: 'rec-1',
          date: '2026-10-01',
          item: 'Urea 46%',
          category: 'Fertilizer',
          type: 'Granular',
          supplier: 'Delta Chem',
          quantity: 100,
          unit: 'Bag',
          pricePerUnit: 25.0,
          total: 2500.0,
          payment: 'Cash',
        ),
      ],
      outbounds: [
        const OutboundShipmentEntity(
          id: 'ship-1',
          date: '2026-10-05',
          product: 'Urea 46%',
          type: 'Granular',
          quantity: 30,
          unit: 'Bag',
          unitPrice: 35.0,
          total: 1050.0,
          field: 'North Field',
        ),
      ],
    );
    final notifier = WarehouseChangeNotifier();
    final repo = InventoryRepoImpl(ds);

    getIt.registerFactory<InventoryCubit>(
      () => InventoryCubit(
        GetInventoryLevelsUseCase(repo),
        GetInventoryMovementsUseCase(repo),
        notifier,
      ),
    );
    getIt.registerFactory<ExportCubit>(
      () => ExportCubit(ExportToExcelUseCase(_FakeExportRepo())),
    );

    await tester.pumpWidget(
      buildTestableWidget(textScaler: const TextScaler.linear(1.3)),
    );
    await tester.pumpAndSettle();

    // No overflow exception thrown!
    expect(tester.takeException(), isNull);

    // Verify header and row still have equal width
    final headerFinder = find.byKey(const ValueKey('stock_levels_header'));
    final rowFinder = find.byKey(const ValueKey('stock_levels_row_Urea 46%'));

    expect(headerFinder, findsOneWidget);
    expect(rowFinder, findsOneWidget);

    final headerWidth = tester.getSize(headerFinder).width;
    final rowWidth = tester.getSize(rowFinder).width;
    expect(headerWidth, equals(rowWidth));

    // Also switch to Movements tab under 1.3x font scale & narrow width
    await tester.tap(find.text(StringsManager.tabMovements));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final movementsHeaderFinder = find.byKey(const ValueKey('movements_header'));
    final movementsRowFinder = find.byKey(const ValueKey('movements_row_rec-1'));
    expect(movementsHeaderFinder, findsOneWidget);
    expect(movementsRowFinder, findsOneWidget);
    expect(
      tester.getSize(movementsHeaderFinder).width,
      equals(tester.getSize(movementsRowFinder).width),
    );
  });
}

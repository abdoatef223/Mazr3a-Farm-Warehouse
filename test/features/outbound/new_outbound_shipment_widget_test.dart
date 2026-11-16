import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mazr3a/core/di/injection.dart';
import 'package:mazr3a/core/helpers/warehouse_change_notifier.dart';
import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/theme_modes.dart';
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
import 'package:mazr3a/features/outbound/presentation/screens/new_outbound_shipment_screen.dart';
import 'package:mazr3a/features/outbound/presentation/view_model/outbound_cubit.dart';

class _FakeInboundDs implements InboundLocalDataSource {
  _FakeInboundDs(this.receipts);
  final List<InboundReceiptEntity> receipts;

  @override
  Future<List<InboundReceiptEntity>> getInboundLog() async => receipts;

  @override
  Future<InboundReceiptEntity> addInboundReceipt(InboundReceiptEntity receipt) async {
    receipts.add(receipt);
    return receipt;
  }

  @override
  Future<void> deleteInboundReceipt(String id) async {
    receipts.removeWhere((r) => r.id == id);
  }
}

class _FakeOutboundDs implements OutboundLocalDataSource {
  _FakeOutboundDs(this.shipments);
  final List<OutboundShipmentEntity> shipments;

  @override
  Future<List<OutboundShipmentEntity>> getOutboundLog() async => shipments;

  @override
  Future<OutboundShipmentEntity> addOutboundShipment(OutboundShipmentEntity shipment) async {
    shipments.add(shipment);
    return shipment;
  }

  @override
  Future<void> deleteOutboundShipment(String id) async {
    shipments.removeWhere((s) => s.id == id);
  }
}

void main() {
  Widget buildTestableWidget() => ScreenUtilPlusInit(
        designSize: const Size(1920, 900),
        minTextAdapt: true,
        builder: (context, child) => MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: NewOutboundShipmentScreen(),
          ),
        ),
      );

  tearDown(() {
    getIt.reset();
  });

  testWidgets('renders empty inbound state banner and button when no inbound records exist', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final inboundDs = _FakeInboundDs([]);
    final outboundDs = _FakeOutboundDs([]);
    final notifier = WarehouseChangeNotifier();
    final repo = OutboundRepoImpl(outboundDs, notifier, inboundDs);

    getIt.registerFactory<OutboundCubit>(
      () => OutboundCubit(
        GetOutboundLogUseCase(repo),
        AddOutboundShipmentUseCase(repo),
        DeleteOutboundShipmentUseCase(repo),
        GetInboundProductOptionsUseCase(repo),
        GetStockLevelUseCase(repo),
        notifier,
      ),
    );

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text(StringsManager.addInboundFirst), findsOneWidget);
    expect(find.text(StringsManager.newReceipt), findsOneWidget);
    expect(find.text(StringsManager.labelField), findsOneWidget);
    expect(find.text(StringsManager.saveShipment), findsOneWidget);
  });

  testWidgets('renders form fields including Field and handles product selection', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final inboundDs = _FakeInboundDs([
      const InboundReceiptEntity(
        id: 'IB-001',
        date: '2026-10-18',
        item: 'Sweet Oranges',
        category: 'Citrus',
        type: 'Navel',
        quantity: 200,
        unit: 'box',
        pricePerUnit: 35.0,
        total: 7000.0,
        supplier: 'Citrus Farm',
        payment: 'Cash',
      ),
    ]);
    final outboundDs = _FakeOutboundDs([]);
    final notifier = WarehouseChangeNotifier();
    final repo = OutboundRepoImpl(outboundDs, notifier, inboundDs);

    getIt.registerFactory<OutboundCubit>(
      () => OutboundCubit(
        GetOutboundLogUseCase(repo),
        AddOutboundShipmentUseCase(repo),
        DeleteOutboundShipmentUseCase(repo),
        GetInboundProductOptionsUseCase(repo),
        GetStockLevelUseCase(repo),
        notifier,
      ),
    );

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Verify empty state is NOT shown
    expect(find.text(StringsManager.addInboundFirst), findsNothing);

    // Verify Field label exists
    expect(find.text(StringsManager.labelField), findsOneWidget);
    expect(find.text(StringsManager.labelQuantity), findsOneWidget);
    expect(find.text(StringsManager.colUnitPrice), findsOneWidget);
    expect(find.text(StringsManager.labelUnit), findsOneWidget);
  });
}

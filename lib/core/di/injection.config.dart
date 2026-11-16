// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:mazr3a/core/general_cubit/general_cubit.dart' as _i906;
import 'package:mazr3a/core/helpers/warehouse_change_notifier.dart' as _i332;
import 'package:mazr3a/core/routing/app_router.dart' as _i159;
import 'package:mazr3a/features/dashboard/data/repo_impl/dashboard_repo_impl.dart'
    as _i388;
import 'package:mazr3a/features/dashboard/domain/repo/dashboard_repo.dart'
    as _i689;
import 'package:mazr3a/features/dashboard/domain/use_cases/get_dashboard_summary_use_case.dart'
    as _i488;
import 'package:mazr3a/features/dashboard/presentation/view_model/dashboard_cubit.dart'
    as _i884;
import 'package:mazr3a/features/export/data/repo_impl/export_repo_impl.dart'
    as _i217;
import 'package:mazr3a/features/export/domain/repo/export_repo.dart' as _i143;
import 'package:mazr3a/features/export/domain/use_cases/export_to_excel_use_case.dart'
    as _i731;
import 'package:mazr3a/features/export/presentation/view_model/export_cubit.dart'
    as _i965;
import 'package:mazr3a/features/inbound/data/datasource/inbound_local_datasource.dart'
    as _i96;
import 'package:mazr3a/features/inbound/data/datasource_impl/inbound_local_datasource_impl.dart'
    as _i711;
import 'package:mazr3a/features/inbound/data/repo_impl/inbound_repo_impl.dart'
    as _i955;
import 'package:mazr3a/features/inbound/domain/repo/inbound_repo.dart' as _i83;
import 'package:mazr3a/features/inbound/domain/use_cases/add_inbound_receipt_use_case.dart'
    as _i482;
import 'package:mazr3a/features/inbound/domain/use_cases/delete_inbound_receipt_use_case.dart'
    as _i829;
import 'package:mazr3a/features/inbound/domain/use_cases/get_inbound_log_use_case.dart'
    as _i41;
import 'package:mazr3a/features/inbound/presentation/view_model/inbound_cubit.dart'
    as _i262;
import 'package:mazr3a/features/inventory/data/datasource/inventory_local_datasource.dart'
    as _i241;
import 'package:mazr3a/features/inventory/data/datasource_impl/inventory_local_datasource_impl.dart'
    as _i421;
import 'package:mazr3a/features/inventory/data/repo_impl/inventory_repo_impl.dart'
    as _i220;
import 'package:mazr3a/features/inventory/domain/repo/inventory_repo.dart'
    as _i781;
import 'package:mazr3a/features/inventory/domain/use_cases/get_inventory_levels_use_case.dart'
    as _i622;
import 'package:mazr3a/features/inventory/domain/use_cases/get_inventory_movements_use_case.dart'
    as _i628;
import 'package:mazr3a/features/inventory/presentation/view_model/inventory_cubit.dart'
    as _i17;
import 'package:mazr3a/features/outbound/data/datasource/outbound_local_datasource.dart'
    as _i277;
import 'package:mazr3a/features/outbound/data/datasource_impl/outbound_local_datasource_impl.dart'
    as _i417;
import 'package:mazr3a/features/outbound/data/repo_impl/outbound_repo_impl.dart'
    as _i974;
import 'package:mazr3a/features/outbound/domain/repo/outbound_repo.dart'
    as _i443;
import 'package:mazr3a/features/outbound/domain/use_cases/add_outbound_shipment_use_case.dart'
    as _i631;
import 'package:mazr3a/features/outbound/domain/use_cases/delete_outbound_shipment_use_case.dart'
    as _i525;
import 'package:mazr3a/features/outbound/domain/use_cases/get_inbound_product_options_use_case.dart'
    as _i550;
import 'package:mazr3a/features/outbound/domain/use_cases/get_outbound_log_use_case.dart'
    as _i287;
import 'package:mazr3a/features/outbound/domain/use_cases/get_stock_level_use_case.dart'
    as _i687;
import 'package:mazr3a/features/outbound/presentation/view_model/outbound_cubit.dart'
    as _i432;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i906.GeneralCubit>(() => _i906.GeneralCubit());
    gh.lazySingleton<_i332.WarehouseChangeNotifier>(
      () => _i332.WarehouseChangeNotifier(),
    );
    gh.lazySingleton<_i159.AppRouter>(() => _i159.AppRouter());
    gh.lazySingleton<_i96.InboundLocalDataSource>(
      () => _i711.InboundLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i277.OutboundLocalDataSource>(
      () => _i417.OutboundLocalDataSourceImpl(),
    );
    gh.factory<_i83.InboundRepo>(
      () => _i955.InboundRepoImpl(
        gh<_i96.InboundLocalDataSource>(),
        gh<_i332.WarehouseChangeNotifier>(),
      ),
    );
    gh.singleton<_i482.AddInboundReceiptUseCase>(
      () => _i482.AddInboundReceiptUseCase(gh<_i83.InboundRepo>()),
    );
    gh.singleton<_i829.DeleteInboundReceiptUseCase>(
      () => _i829.DeleteInboundReceiptUseCase(gh<_i83.InboundRepo>()),
    );
    gh.singleton<_i41.GetInboundLogUseCase>(
      () => _i41.GetInboundLogUseCase(gh<_i83.InboundRepo>()),
    );
    gh.factory<_i262.InboundCubit>(
      () => _i262.InboundCubit(
        gh<_i41.GetInboundLogUseCase>(),
        gh<_i482.AddInboundReceiptUseCase>(),
        gh<_i829.DeleteInboundReceiptUseCase>(),
      ),
    );
    gh.lazySingleton<_i241.InventoryLocalDataSource>(
      () => _i421.InventoryLocalDataSourceImpl(
        gh<_i96.InboundLocalDataSource>(),
        gh<_i277.OutboundLocalDataSource>(),
      ),
    );
    gh.factory<_i443.OutboundRepo>(
      () => _i974.OutboundRepoImpl(
        gh<_i277.OutboundLocalDataSource>(),
        gh<_i332.WarehouseChangeNotifier>(),
        gh<_i96.InboundLocalDataSource>(),
      ),
    );
    gh.singleton<_i631.AddOutboundShipmentUseCase>(
      () => _i631.AddOutboundShipmentUseCase(gh<_i443.OutboundRepo>()),
    );
    gh.singleton<_i525.DeleteOutboundShipmentUseCase>(
      () => _i525.DeleteOutboundShipmentUseCase(gh<_i443.OutboundRepo>()),
    );
    gh.singleton<_i550.GetInboundProductOptionsUseCase>(
      () => _i550.GetInboundProductOptionsUseCase(gh<_i443.OutboundRepo>()),
    );
    gh.singleton<_i287.GetOutboundLogUseCase>(
      () => _i287.GetOutboundLogUseCase(gh<_i443.OutboundRepo>()),
    );
    gh.singleton<_i687.GetStockLevelUseCase>(
      () => _i687.GetStockLevelUseCase(gh<_i443.OutboundRepo>()),
    );
    gh.factory<_i689.DashboardRepo>(
      () => _i388.DashboardRepoImpl(
        gh<_i83.InboundRepo>(),
        gh<_i443.OutboundRepo>(),
      ),
    );
    gh.singleton<_i488.GetDashboardSummaryUseCase>(
      () => _i488.GetDashboardSummaryUseCase(gh<_i689.DashboardRepo>()),
    );
    gh.lazySingleton<_i884.DashboardCubit>(
      () => _i884.DashboardCubit(
        gh<_i488.GetDashboardSummaryUseCase>(),
        gh<_i332.WarehouseChangeNotifier>(),
      ),
    );
    gh.factory<_i432.OutboundCubit>(
      () => _i432.OutboundCubit(
        gh<_i287.GetOutboundLogUseCase>(),
        gh<_i631.AddOutboundShipmentUseCase>(),
        gh<_i525.DeleteOutboundShipmentUseCase>(),
        gh<_i550.GetInboundProductOptionsUseCase>(),
        gh<_i687.GetStockLevelUseCase>(),
        gh<_i332.WarehouseChangeNotifier>(),
      ),
    );
    gh.factory<_i781.InventoryRepo>(
      () => _i220.InventoryRepoImpl(gh<_i241.InventoryLocalDataSource>()),
    );
    gh.singleton<_i622.GetInventoryLevelsUseCase>(
      () => _i622.GetInventoryLevelsUseCase(gh<_i781.InventoryRepo>()),
    );
    gh.singleton<_i628.GetInventoryMovementsUseCase>(
      () => _i628.GetInventoryMovementsUseCase(gh<_i781.InventoryRepo>()),
    );
    gh.factory<_i143.ExportRepo>(
      () => _i217.ExportRepoImpl(
        gh<_i83.InboundRepo>(),
        gh<_i443.OutboundRepo>(),
        gh<_i781.InventoryRepo>(),
      ),
    );
    gh.factory<_i17.InventoryCubit>(
      () => _i17.InventoryCubit(
        gh<_i622.GetInventoryLevelsUseCase>(),
        gh<_i628.GetInventoryMovementsUseCase>(),
        gh<_i332.WarehouseChangeNotifier>(),
      ),
    );
    gh.singleton<_i731.ExportToExcelUseCase>(
      () => _i731.ExportToExcelUseCase(gh<_i143.ExportRepo>()),
    );
    gh.factory<_i965.ExportCubit>(
      () => _i965.ExportCubit(gh<_i731.ExportToExcelUseCase>()),
    );
    return this;
  }
}

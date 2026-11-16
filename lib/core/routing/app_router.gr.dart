// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i8;
import 'package:mazr3a/features/dashboard/presentation/screens/dashboard_screen.dart'
    as _i1;
import 'package:mazr3a/features/inbound/presentation/screens/inbound_log_screen.dart'
    as _i2;
import 'package:mazr3a/features/inbound/presentation/screens/new_inbound_receipt_screen.dart'
    as _i4;
import 'package:mazr3a/features/inventory/presentation/screens/inventory_screen.dart'
    as _i3;
import 'package:mazr3a/features/outbound/presentation/screens/new_outbound_shipment_screen.dart'
    as _i5;
import 'package:mazr3a/features/outbound/presentation/screens/outbound_log_screen.dart'
    as _i6;
import 'package:mazr3a/features/shell/presentation/screens/shell_screen.dart'
    as _i7;

/// generated route for
/// [_i1.DashboardScreen]
class DashboardRoute extends _i8.PageRouteInfo<void> {
  const DashboardRoute({List<_i8.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i1.DashboardScreen();
    },
  );
}

/// generated route for
/// [_i2.InboundLogScreen]
class InboundLogRoute extends _i8.PageRouteInfo<void> {
  const InboundLogRoute({List<_i8.PageRouteInfo>? children})
    : super(InboundLogRoute.name, initialChildren: children);

  static const String name = 'InboundLogRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i2.InboundLogScreen();
    },
  );
}

/// generated route for
/// [_i3.InventoryScreen]
class InventoryRoute extends _i8.PageRouteInfo<void> {
  const InventoryRoute({List<_i8.PageRouteInfo>? children})
    : super(InventoryRoute.name, initialChildren: children);

  static const String name = 'InventoryRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i3.InventoryScreen();
    },
  );
}

/// generated route for
/// [_i4.NewInboundReceiptScreen]
class NewInboundReceiptRoute extends _i8.PageRouteInfo<void> {
  const NewInboundReceiptRoute({List<_i8.PageRouteInfo>? children})
    : super(NewInboundReceiptRoute.name, initialChildren: children);

  static const String name = 'NewInboundReceiptRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i4.NewInboundReceiptScreen();
    },
  );
}

/// generated route for
/// [_i5.NewOutboundShipmentScreen]
class NewOutboundShipmentRoute extends _i8.PageRouteInfo<void> {
  const NewOutboundShipmentRoute({List<_i8.PageRouteInfo>? children})
    : super(NewOutboundShipmentRoute.name, initialChildren: children);

  static const String name = 'NewOutboundShipmentRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i5.NewOutboundShipmentScreen();
    },
  );
}

/// generated route for
/// [_i6.OutboundLogScreen]
class OutboundLogRoute extends _i8.PageRouteInfo<void> {
  const OutboundLogRoute({List<_i8.PageRouteInfo>? children})
    : super(OutboundLogRoute.name, initialChildren: children);

  static const String name = 'OutboundLogRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i6.OutboundLogScreen();
    },
  );
}

/// generated route for
/// [_i7.ShellScreen]
class ShellRoute extends _i8.PageRouteInfo<void> {
  const ShellRoute({List<_i8.PageRouteInfo>? children})
    : super(ShellRoute.name, initialChildren: children);

  static const String name = 'ShellRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i7.ShellScreen();
    },
  );
}

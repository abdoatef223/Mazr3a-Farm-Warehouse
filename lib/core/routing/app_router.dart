import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/routing/app_router.gr.dart';

@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: ShellRoute.page,
          initial: true,
          children: [
            AutoRoute(
              page: DashboardRoute.page,
              initial: true,
              path: '',
            ),
            AutoRoute(
              page: InventoryRoute.page,
              path: 'inventory',
            ),
            AutoRoute(
              page: NewInboundReceiptRoute.page,
              path: 'inbound/new',
            ),
            AutoRoute(
              page: InboundLogRoute.page,
              path: 'inbound/log',
            ),
            AutoRoute(
              page: NewOutboundShipmentRoute.page,
              path: 'outbound/new',
            ),
            AutoRoute(
              page: OutboundLogRoute.page,
              path: 'outbound/log',
            ),
          ],
        ),
      ];
}

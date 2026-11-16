import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mazr3a/core/di/injection.dart';
import 'package:mazr3a/core/resources/assets_manager.dart';
import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_text.dart';
import 'package:mazr3a/features/dashboard/presentation/view_model/dashboard_cubit.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final currentRoute = context.router.current.name;

    return Container(
      width: 280,
      color: colors.sidebarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo & Brand Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.sidebarActive,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    AssetsManager.logo,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      colors.textOnDark,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      StringsManager.logo,
                      style: AppTypography.displayBrand,
                      color: colors.textOnDark,
                    ),
                    AppText(
                      StringsManager.farmWarehouse,
                      style: AppTypography.bodySmall,
                      color: colors.sidebarMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: colors.sidebarActive.withValues(alpha: 0.35),
            height: 1,
          ),

          // Nav Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _buildSectionHeader(StringsManager.overView, colors),
                const SizedBox(height: 8),
                _buildNavItem(
                  context: context,
                  label: StringsManager.navDashboard,
                  iconAsset: AssetsManager.dashBoard,
                  isActive: currentRoute == 'DashboardRoute',
                  targetPath: '/',
                  colors: colors,
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  context: context,
                  label: StringsManager.navInventory,
                  iconAsset: AssetsManager.inventory,
                  isActive: currentRoute == 'InventoryRoute',
                  targetPath: '/inventory',
                  colors: colors,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(StringsManager.inBound, colors),
                const SizedBox(height: 8),
                _buildNavItem(
                  context: context,
                  label: StringsManager.newReceipt,
                  iconAsset: AssetsManager.inBound,
                  isActive: currentRoute == 'NewInboundReceiptRoute',
                  targetPath: '/inbound/new',
                  colors: colors,
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  context: context,
                  label: StringsManager.inboundLog,
                  iconAsset: AssetsManager.log,
                  isActive: currentRoute == 'InboundLogRoute',
                  targetPath: '/inbound/log',
                  colors: colors,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(StringsManager.outBound, colors),
                const SizedBox(height: 8),
                _buildNavItem(
                  context: context,
                  label: StringsManager.newShipment,
                  iconAsset: AssetsManager.outBound,
                  isActive: currentRoute == 'NewOutboundShipmentRoute',
                  targetPath: '/outbound/new',
                  colors: colors,
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  context: context,
                  label: StringsManager.outBoundLog,
                  iconAsset: AssetsManager.log,
                  isActive: currentRoute == 'OutboundLogRoute',
                  targetPath: '/outbound/log',
                  colors: colors,
                ),
              ],
            ),
          ),

          // Pinned Footer
          Divider(
            color: colors.sidebarActive.withValues(alpha: 0.35),
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: AppText(
              StringsManager.versionFooter,
              style: AppTypography.monoData,
              color: colors.sidebarMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppColors colors) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: AppText(
          title,
          style: AppTypography.labelSectionMono,
          color: colors.sidebarMuted,
        ),
      );

  Widget _buildNavItem({
    required BuildContext context,
    required String label,
    required String iconAsset,
    required bool isActive,
    required String targetPath,
    required AppColors colors,
  }) {
    final fgColor = isActive ? colors.textOnDark : colors.sidebarText;

    return Material(
      color: isActive ? colors.sidebarActive : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          if (!isActive) {
            if (targetPath == '/') {
              getIt<DashboardCubit>().loadSummary();
            }
            context.router.navigatePath(targetPath);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  fgColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AppText(
                  label,
                  style: AppTypography.labelNav,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

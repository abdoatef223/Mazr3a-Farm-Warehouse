import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:mazr3a/core/di/injection.dart';
import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_button.dart';
import 'package:mazr3a/core/widgets/app_text.dart';
import 'package:mazr3a/features/dashboard/presentation/view_model/dashboard_cubit.dart';
import 'package:mazr3a/features/dashboard/presentation/widgets/kpi_row.dart';
import 'package:mazr3a/features/dashboard/presentation/widgets/recent_inbound_panel.dart';
import 'package:mazr3a/features/dashboard/presentation/widgets/recent_outbound_panel.dart';

@RoutePage()
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: getIt<DashboardCubit>(),
        child: const _DashboardView(),
      );
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        DashboardCubit.of(context).loadSummary();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.surfacePage,
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardStates>(
          builder: (context, state) => switch (state) {
            DashboardInit() || DashboardLoading() => Center(
                child: CircularProgressIndicator(
                  color: colors.brandInboundGreen,
                ),
              ),
            DashboardError(:final message) => Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48.sp,
                        color: Colors.redAccent,
                      ),
                      SizedBox(height: 16.h),
                      AppText(
                        'Failed to load warehouse summary',
                        style: AppTypography.headingCardTitle,
                        color: colors.textPrimary,
                      ),
                      SizedBox(height: 8.h),
                      AppText(
                        message,
                        style: AppTypography.bodyRegular,
                        color: colors.textMuted,
                      ),
                      SizedBox(height: 24.h),
                      AppButton(
                        text: 'Retry',
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        backgroundColor: colors.brandInboundGreen,
                        onPressed: () =>
                            DashboardCubit.of(context).loadSummary(),
                      ),
                    ],
                  ),
                ),
              ),
            DashboardLoaded(:final summary) => SingleChildScrollView(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          StringsManager.wareHouseOverView,
                          style: AppTypography.displayH1,
                          color: colors.textPrimary,
                        ),
                        SizedBox(height: 6.h),
                        AppText(
                          StringsManager.dashboardSubtitle,
                          style: AppTypography.bodyRegular,
                          color: colors.textMuted,
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),

                    // KPI Row
                    KpiRow(summary: summary),
                    SizedBox(height: 28.h),

                    // Side-by-side Recent Panels
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RecentInboundPanel(
                            inbounds: summary.recentInbounds,
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: RecentOutboundPanel(
                            outbounds: summary.recentOutbounds,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          },
        ),
      ),
    );
  }
}

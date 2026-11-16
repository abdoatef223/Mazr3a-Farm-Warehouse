import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/features/shell/presentation/widgets/app_sidebar.dart';

@RoutePage()
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.surfacePage,
      body: const Row(
        children: [
          AppSidebar(),
          Expanded(
            child: AutoRouter(),
          ),
        ],
      ),
    );
  }
}

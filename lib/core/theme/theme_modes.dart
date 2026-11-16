import 'package:flutter/material.dart';

import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: FontAssetsManager.dmSans,
        primaryColor: AppColors.light.brandInboundGreen,
        scaffoldBackgroundColor: AppColors.light.surfacePage,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.light.brandInboundGreen,
          brightness: Brightness.light,
          error: AppColors.light.danger,
        ),
        extensions: const <ThemeExtension<dynamic>>[
          AppColors.light,
        ],
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: FontAssetsManager.dmSans,
        primaryColor: AppColors.dark.brandInboundGreen,
        scaffoldBackgroundColor: AppColors.dark.surfacePage,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.dark.brandInboundGreen,
          brightness: Brightness.dark,
          error: AppColors.dark.danger,
        ),
        extensions: const <ThemeExtension<dynamic>>[
          AppColors.dark,
        ],
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

// TODO(fonts): Add the following font files to assets/fonts/ and declare them in pubspec.yaml:
// - Fraunces-Bold
// - DMSans-Regular
// - DMSans-Medium
// - DMSans-SemiBold
// - JetBrainsMono-Regular
// - JetBrainsMono-Medium
// - JetBrainsMono-Bold

/// Font family constants accessed per rules.md 9.4 (flutter_gen / FontAssetsManager).
abstract final class FontAssetsManager {
  static const String fraunces = 'Fraunces';
  static const String dmSans = 'DM Sans';
  static const String jetBrainsMono = 'JetBrains Mono';
}

/// Compatibility alias for flutter_gen / FontFamily access.
abstract final class FontFamily {
  static const String fraunces = FontAssetsManager.fraunces;
  static const String dmSans = FontAssetsManager.dmSans;
  static const String jetBrainsMono = FontAssetsManager.jetBrainsMono;
}

abstract final class AppTypography {
  static TextStyle get displayH1 => TextStyle(
        fontFamily: FontAssetsManager.fraunces,
        fontSize: 42.sp,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get displayBrand => TextStyle(
        fontFamily: FontAssetsManager.fraunces,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get displayKpiValue => TextStyle(
        fontFamily: FontAssetsManager.fraunces,
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get headingCardTitle => TextStyle(
        fontFamily: FontAssetsManager.dmSans,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyRegular => TextStyle(
        fontFamily: FontAssetsManager.dmSans,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: FontAssetsManager.dmSans,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get labelField => TextStyle(
        fontFamily: FontAssetsManager.dmSans,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get labelNav => TextStyle(
        fontFamily: FontAssetsManager.dmSans,
        fontSize: 17.sp,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get labelTableHead => TextStyle(
        fontFamily: FontAssetsManager.dmSans,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get labelSectionMono => TextStyle(
        fontFamily: FontAssetsManager.jetBrainsMono,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
      );

  static TextStyle get monoData => TextStyle(
        fontFamily: FontAssetsManager.jetBrainsMono,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get monoDataBold => TextStyle(
        fontFamily: FontAssetsManager.jetBrainsMono,
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get buttonPrimary => TextStyle(
        fontFamily: FontAssetsManager.dmSans,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      );
}

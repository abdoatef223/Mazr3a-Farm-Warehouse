import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.sidebarBackground,
    required this.sidebarActive,
    required this.sidebarText,
    required this.sidebarMuted,
    required this.surfacePage,
    required this.surfaceCard,
    required this.surfaceTableHead,
    required this.borderDefault,
    required this.textPrimary,
    required this.textMuted,
    required this.textOnDark,
    required this.brandInboundGreen,
    required this.brandInboundButton,
    required this.brandOutboundBrown,
    required this.brandAmber,
    required this.badgeCashBg,
    required this.badgeCashText,
    required this.badgeDeferredBg,
    required this.badgeDeferredText,
    required this.badgeTypeBg,
    required this.badgeTypeText,
    required this.danger,
  });

  static const AppColors light = AppColors(
    sidebarBackground: Color(0xFF1F2F20),
    sidebarActive: Color(0xFF3D6B40),
    sidebarText: Color(0xFFDDE5DA),
    sidebarMuted: Color(0xFF7C8C78),
    surfacePage: Color(0xFFF4F0E8),
    surfaceCard: Color(0xFFFAF7F0),
    surfaceTableHead: Color(0xFFE8E1D3),
    borderDefault: Color(0xFFDDD6C6),
    textPrimary: Color(0xFF1A1A14),
    textMuted: Color(0xFF6B675C),
    textOnDark: Color(0xFFFFFFFF),
    brandInboundGreen: Color(0xFF2D5A3D),
    brandInboundButton: Color(0xFF3D6B40),
    brandOutboundBrown: Color(0xFF8B4513),
    brandAmber: Color(0xFFC17F3E),
    badgeCashBg: Color(0xFFDFF0E4),
    badgeCashText: Color(0xFF2D5A3D),
    badgeDeferredBg: Color(0xFFFBEBD0),
    badgeDeferredText: Color(0xFF9A5B13),
    badgeTypeBg: Color(0xFFE4E9F7),
    badgeTypeText: Color(0xFF3B4FA6),
    danger: Color(0xFFB3261E),
  );

  static const AppColors dark = AppColors(
    sidebarBackground: Color(0xFF1F2F20),
    sidebarActive: Color(0xFF3D6B40),
    sidebarText: Color(0xFFDDE5DA),
    sidebarMuted: Color(0xFF7C8C78),
    surfacePage: Color(0xFF131513),
    surfaceCard: Color(0xFF1C1F1C),
    surfaceTableHead: Color(0xFF242824),
    borderDefault: Color(0xFF2E332E),
    textPrimary: Color(0xFFEDEAE3),
    textMuted: Color(0xFF9E9A90),
    textOnDark: Color(0xFFFFFFFF),
    brandInboundGreen: Color(0xFF4E8C5E),
    brandInboundButton: Color(0xFF538C57),
    brandOutboundBrown: Color(0xFFC07038),
    brandAmber: Color(0xFFDCA05C),
    badgeCashBg: Color(0xFF1B3824),
    badgeCashText: Color(0xFF68C983),
    badgeDeferredBg: Color(0xFF382610),
    badgeDeferredText: Color(0xFFEBA34A),
    badgeTypeBg: Color(0xFF1C2742),
    badgeTypeText: Color(0xFF8BA3EF),
    danger: Color(0xFFE25B54),
  );

  final Color sidebarBackground;
  final Color sidebarActive;
  final Color sidebarText;
  final Color sidebarMuted;
  final Color surfacePage;
  final Color surfaceCard;
  final Color surfaceTableHead;
  final Color borderDefault;
  final Color textPrimary;
  final Color textMuted;
  final Color textOnDark;
  final Color brandInboundGreen;
  final Color brandInboundButton;
  final Color brandOutboundBrown;
  final Color brandAmber;
  final Color badgeCashBg;
  final Color badgeCashText;
  final Color badgeDeferredBg;
  final Color badgeDeferredText;
  final Color badgeTypeBg;
  final Color badgeTypeText;
  final Color danger;

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  @override
  AppColors copyWith({
    Color? sidebarBackground,
    Color? sidebarActive,
    Color? sidebarText,
    Color? sidebarMuted,
    Color? surfacePage,
    Color? surfaceCard,
    Color? surfaceTableHead,
    Color? borderDefault,
    Color? textPrimary,
    Color? textMuted,
    Color? textOnDark,
    Color? brandInboundGreen,
    Color? brandInboundButton,
    Color? brandOutboundBrown,
    Color? brandAmber,
    Color? badgeCashBg,
    Color? badgeCashText,
    Color? badgeDeferredBg,
    Color? badgeDeferredText,
    Color? badgeTypeBg,
    Color? badgeTypeText,
    Color? danger,
  }) =>
      AppColors(
        sidebarBackground: sidebarBackground ?? this.sidebarBackground,
        sidebarActive: sidebarActive ?? this.sidebarActive,
        sidebarText: sidebarText ?? this.sidebarText,
        sidebarMuted: sidebarMuted ?? this.sidebarMuted,
        surfacePage: surfacePage ?? this.surfacePage,
        surfaceCard: surfaceCard ?? this.surfaceCard,
        surfaceTableHead: surfaceTableHead ?? this.surfaceTableHead,
        borderDefault: borderDefault ?? this.borderDefault,
        textPrimary: textPrimary ?? this.textPrimary,
        textMuted: textMuted ?? this.textMuted,
        textOnDark: textOnDark ?? this.textOnDark,
        brandInboundGreen: brandInboundGreen ?? this.brandInboundGreen,
        brandInboundButton: brandInboundButton ?? this.brandInboundButton,
        brandOutboundBrown: brandOutboundBrown ?? this.brandOutboundBrown,
        brandAmber: brandAmber ?? this.brandAmber,
        badgeCashBg: badgeCashBg ?? this.badgeCashBg,
        badgeCashText: badgeCashText ?? this.badgeCashText,
        badgeDeferredBg: badgeDeferredBg ?? this.badgeDeferredBg,
        badgeDeferredText: badgeDeferredText ?? this.badgeDeferredText,
        badgeTypeBg: badgeTypeBg ?? this.badgeTypeBg,
        badgeTypeText: badgeTypeText ?? this.badgeTypeText,
        danger: danger ?? this.danger,
      );

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      sidebarBackground:
          Color.lerp(sidebarBackground, other.sidebarBackground, t) ??
              sidebarBackground,
      sidebarActive:
          Color.lerp(sidebarActive, other.sidebarActive, t) ?? sidebarActive,
      sidebarText:
          Color.lerp(sidebarText, other.sidebarText, t) ?? sidebarText,
      sidebarMuted:
          Color.lerp(sidebarMuted, other.sidebarMuted, t) ?? sidebarMuted,
      surfacePage:
          Color.lerp(surfacePage, other.surfacePage, t) ?? surfacePage,
      surfaceCard:
          Color.lerp(surfaceCard, other.surfaceCard, t) ?? surfaceCard,
      surfaceTableHead:
          Color.lerp(surfaceTableHead, other.surfaceTableHead, t) ??
              surfaceTableHead,
      borderDefault:
          Color.lerp(borderDefault, other.borderDefault, t) ?? borderDefault,
      textPrimary:
          Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      textOnDark:
          Color.lerp(textOnDark, other.textOnDark, t) ?? textOnDark,
      brandInboundGreen:
          Color.lerp(brandInboundGreen, other.brandInboundGreen, t) ??
              brandInboundGreen,
      brandInboundButton:
          Color.lerp(brandInboundButton, other.brandInboundButton, t) ??
              brandInboundButton,
      brandOutboundBrown:
          Color.lerp(brandOutboundBrown, other.brandOutboundBrown, t) ??
              brandOutboundBrown,
      brandAmber:
          Color.lerp(brandAmber, other.brandAmber, t) ?? brandAmber,
      badgeCashBg:
          Color.lerp(badgeCashBg, other.badgeCashBg, t) ?? badgeCashBg,
      badgeCashText:
          Color.lerp(badgeCashText, other.badgeCashText, t) ?? badgeCashText,
      badgeDeferredBg:
          Color.lerp(badgeDeferredBg, other.badgeDeferredBg, t) ??
              badgeDeferredBg,
      badgeDeferredText:
          Color.lerp(badgeDeferredText, other.badgeDeferredText, t) ??
              badgeDeferredText,
      badgeTypeBg:
          Color.lerp(badgeTypeBg, other.badgeTypeBg, t) ?? badgeTypeBg,
      badgeTypeText:
          Color.lerp(badgeTypeText, other.badgeTypeText, t) ?? badgeTypeText,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
    );
  }
}

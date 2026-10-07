import 'package:flutter/material.dart';

/// Ana səhifə Figma layout ölçüləri.
abstract final class TarzHomeLayout {
  /// Figma `left: 25px`.
  static const double horizontalPadding = 25;

  /// Mağazalar scroll sahəsi — Figma 469×235.
  static const double storesSectionDesignWidth = 469;
  static const double storesSectionDesignHeight = 235;

  /// Mağaza kartı — Figma 184.27×110; sütun arası ~15px (235 − 2×110).
  static const double storeCardWidth = 184.27;
  static const double storeCardHeight = 110;
  static const double storeCardGap = 15;
  static const double storeCardBorderWidth = 1.5;
  static const double storeCardRadius = 16;
  static const Color storeCardBorderColor = Color(0xFFD9D9D9);
  static const Color storeCardBackground = Color(0xFFFFFFFF);
  static const Color storeCardLabelColor = Color(0xFF111111);

  static const double storesTitleSpacing = 12;

  static const double storeLogoMaxWidthFraction = 0.70;
  static const double storeLogoMaxHeightFraction = 0.50;

  /// Brend banner kartı (Figma Group_32 — 470×283).
  static const double brandFrameWidth = 470;
  static const double brandFrameHeight = 283;

  /// Ekran eninə görə Figma 469 content miqyası.
  static double storesContentScale(double viewportWidth) {
    final contentWidth = viewportWidth - horizontalPadding * 2;
    if (contentWidth <= 0 || storesSectionDesignWidth <= 0) return 1;
    return contentWidth / storesSectionDesignWidth;
  }

  static double scaledStoresGridHeight(double viewportWidth) =>
      storesSectionDesignHeight * storesContentScale(viewportWidth);

  static double scaledStoreCardWidth(double viewportWidth) =>
      storeCardWidth * storesContentScale(viewportWidth);

  static double scaledStoreCardHeight(double viewportWidth) =>
      storeCardHeight * storesContentScale(viewportWidth);

  static double scaledStoreCardGap(double viewportWidth) =>
      storeCardGap * storesContentScale(viewportWidth);

  /// Geriyə uyğunluq.
  static double get storesGridHeight => storesSectionDesignHeight;
}

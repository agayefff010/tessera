import 'package:flutter/material.dart';

/// Ana səhifə Figma layout ölçüləri.
abstract final class TarzHomeLayout {
  static const double horizontalPadding = 24.95;

  /// Mağazalar bölməsi — Figma referans çərçivəsi.
  static const double storesSectionDesignWidth = 789;
  static const double storesSectionDesignHeight = 235;

  /// Mağaza kartı.
  static const double storeCardWidth = 186;
  static const double storeCardHeight = 111;
  static const double storeCardGap = 12;
  static const double storeCardBorderWidth = 1.5;
  static const double storeCardRadius = 16;
  static const Color storeCardBorderColor = Color(0xFFD9D9D9);
  static const Color storeCardBackground = Color(0xFFFFFFFF);
  static const Color storeCardLabelColor = Color(0xFF111111);

  static const double storesTitleSpacing = 12;

  /// Logo məhdudiyyətləri (kart ölçüsünə nisbətən).
  static const double storeLogoMaxWidthFraction = 0.70;
  static const double storeLogoMaxHeightFraction = 0.50;

  /// Brend banner kartı (Figma Group_32 — 470×283).
  static const double brandFrameWidth = 470;
  static const double brandFrameHeight = 283;

  /// Mağazalar grid hündürlüyü: 2 sıra + aralıq.
  static double get storesGridHeight =>
      storeCardHeight * 2 + storeCardGap;
}

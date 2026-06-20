import 'package:flutter/material.dart';

import 'tarz_colors.dart';

/// Mətn stilləri — bir yerdən idarə olunur.
abstract final class TarzTextStyles {
  static const TextStyle logo = TextStyle(
    fontSize: 22,
    letterSpacing: 4,
    fontWeight: FontWeight.w300,
    color: TarzColors.ink,
  );

  /// Tessera söz işarəsi — sistem serif ilə (platformaya görə dəyişir).
  static const TextStyle tesseraWordmark = TextStyle(
    fontFamily: 'serif',
    fontSize: 20,
    letterSpacing: 2.4,
    fontWeight: FontWeight.w500,
    color: TarzColors.ink,
  );

  static const TextStyle titleLg = TextStyle(
    fontSize: 26,
    height: 1.15,
    fontWeight: FontWeight.w500,
    color: TarzColors.ink,
  );

  static const TextStyle titleMd = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: TarzColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.35,
    color: TarzColors.inkMuted,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: TarzColors.inkMuted,
  );

  static const TextStyle price = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: TarzColors.ink,
  );

  static const TextStyle promo = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.25,
  );

  /// Kataloq kateqoriya sətri — Inter Regular 32px, mərkəz.
  static const TextStyle catalogueCategory = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.0,
    letterSpacing: 0,
    color: TarzColors.ink,
  );
}

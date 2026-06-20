import 'package:flutter/material.dart';

/// Uşaq kataloqu üçün vizual blok məlumatı.
class TarzChildrenCatalogueBlock {
  const TarzChildrenCatalogueBlock({
    required this.title,
    required this.subcategories,
    required this.backgroundColor,
    required this.imageAsset,
    required this.imageOnLeft,
    this.fullWidthBanner = false,
  });

  final String title;
  final List<String> subcategories;
  final Color backgroundColor;
  final String imageAsset;
  final bool imageOnLeft;

  /// Figma-dan ixrac olunmuş tam enlikli banner (mətn şəkildə daxildir).
  final bool fullWidthBanner;
}

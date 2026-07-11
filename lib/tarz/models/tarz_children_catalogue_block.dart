import 'package:flutter/material.dart';

import 'plp_category_option.dart';

/// Uşaq kataloqu üçün vizual blok məlumatı.
class TarzChildrenCatalogueBlock {
  const TarzChildrenCatalogueBlock({
    required this.title,
    required this.subcategories,
    required this.backgroundColor,
    required this.imageAsset,
    required this.imageOnLeft,
    this.categoryId,
    this.fullWidthBanner = false,
  });

  final String title;
  final List<PlpCategoryOption> subcategories;
  final Color backgroundColor;
  final String imageAsset;
  final bool imageOnLeft;
  final String? categoryId;

  /// Figma-dan ixrac olunmuş tam enlikli banner (mətn şəkildə daxildir).
  final bool fullWidthBanner;
}

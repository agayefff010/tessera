import 'package:flutter/material.dart';

import '../../data/tarz_category_assets.dart';
import '../../theme/tarz_colors.dart';
import '../../utils/tarz_image_cache.dart';

class HomeCategoryItem {
  const HomeCategoryItem({
    required this.label,
    required this.leftColor,
    this.imageAsset,
    this.imageUrl,
    this.categoryId,
  });

  final String label;
  final Color leftColor;
  final String? imageAsset;
  final String? imageUrl;
  final String? categoryId;
}

/// «Kateqoriyalar» — 2×2 şəbəkə, qara xətlərlə (Figma).
class CategoryGridSection extends StatelessWidget {
  const CategoryGridSection({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  final List<HomeCategoryItem> categories;
  final ValueChanged<HomeCategoryItem>? onCategoryTap;

  static const double _divider = 12;
  static const Color _dividerColor = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] CategoryGridSection');
    final items = categories.take(4).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kateqoriyalar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: TarzColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, c) {
              final cellW = (c.maxWidth - _divider) / 2;
              final cellH = cellW * 0.72;

              return ColoredBox(
                color: _dividerColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var row = 0; row < 2; row++) ...[
                      if (row > 0) const SizedBox(height: _divider),
                      SizedBox(
                        height: cellH,
                        child: Row(
                          children: [
                            for (var col = 0; col < 2; col++) ...[
                              if (col > 0) const SizedBox(width: _divider),
                              SizedBox(
                                width: cellW,
                                height: cellH,
                                child: row * 2 + col < items.length
                                    ? _CategorySplitCard(
                                        item: items[row * 2 + col],
                                        onTap: () => onCategoryTap?.call(
                                          items[row * 2 + col],
                                        ),
                                      )
                                    : const ColoredBox(color: Colors.white),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static List<HomeCategoryItem> mockCategories() => const [
        HomeCategoryItem(
          label: 'Donlar',
          imageAsset: TarzCategoryAssets.donlar,
          leftColor: Color(0xFF5B7FA8),
        ),
        HomeCategoryItem(
          label: 'Ayaqqabılar',
          imageAsset: TarzCategoryAssets.ayaqqabilar,
          leftColor: Color(0xFF3D2A18),
        ),
        HomeCategoryItem(
          label: 'Toplar',
          imageAsset: TarzCategoryAssets.toplar,
          leftColor: Color(0xFF4A5C38),
        ),
        HomeCategoryItem(
          label: 'Çantalar',
          imageAsset: TarzCategoryAssets.cantalar,
          leftColor: Color(0xFFC4A574),
        ),
      ];
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.item});

  final HomeCategoryItem item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cacheW = TarzImageCache.px(context, constraints.maxWidth);
        final cacheH = TarzImageCache.px(context, constraints.maxHeight);

        final imageUrl = item.imageUrl;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return Image.network(
            imageUrl,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            cacheWidth: cacheW,
            cacheHeight: cacheH,
            errorBuilder: (_, __, ___) => _placeholder(),
          );
        }

        final imageAsset = item.imageAsset;
        if (imageAsset != null && imageAsset.isNotEmpty) {
          return Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            cacheWidth: cacheW,
            cacheHeight: cacheH,
            errorBuilder: (_, __, ___) => _placeholder(),
          );
        }

        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: const Color(0xFFF3F3F3),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: item.leftColor.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class _CategorySplitCard extends StatelessWidget {
  const _CategorySplitCard({required this.item, this.onTap});

  final HomeCategoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              flex: 52,
              child: ColoredBox(
                color: item.leftColor,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 8, 8),
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 48,
              child: _CategoryImage(item: item),
            ),
          ],
        ),
      ),
    );
  }
}

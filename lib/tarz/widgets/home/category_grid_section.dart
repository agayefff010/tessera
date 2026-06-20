import 'package:flutter/material.dart';

import '../../data/tarz_banner_assets.dart';
import '../../theme/tarz_colors.dart';

class HomeCategoryItem {
  const HomeCategoryItem({
    required this.label,
    required this.imageAsset,
    required this.leftColor,
  });

  final String label;
  final String imageAsset;
  final Color leftColor;
}

/// «Kateqoriyalar» — 2×2 şəbəkə (sol rəng + sağ şəkil, Figma).
class CategoryGridSection extends StatelessWidget {
  const CategoryGridSection({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  final List<HomeCategoryItem> categories;
  final ValueChanged<String>? onCategoryTap;

  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
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
              final cellW = (c.maxWidth - _gap) / 2;
              final cellH = cellW * 0.92;
              return Column(
                children: [
                  for (var row = 0; row < categories.length; row += 2) ...[
                    if (row > 0) const SizedBox(height: _gap),
                    Row(
                      children: [
                        for (var col = 0; col < 2; col++) ...[
                          if (col > 0) const SizedBox(width: _gap),
                          SizedBox(
                            width: cellW,
                            height: cellH,
                            child: row + col < categories.length
                                ? _CategorySplitCard(
                                    item: categories[row + col],
                                    onTap: () => onCategoryTap?.call(
                                      categories[row + col].label,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// TODO: API-dən kateqoriya siyahısı ilə əvəz et.
  static List<HomeCategoryItem> mockCategories() => const [
        HomeCategoryItem(
          label: 'Donlar',
          imageAsset: TarzBannerAssets.winter,
          leftColor: Color(0xFF5B7FA8),
        ),
        HomeCategoryItem(
          label: 'Ayaqqabılar',
          imageAsset: TarzBannerAssets.yakup,
          leftColor: Color(0xFF3D2A18),
        ),
        HomeCategoryItem(
          label: 'Toplar',
          imageAsset: TarzBannerAssets.tomy,
          leftColor: Color(0xFF4A5C38),
        ),
        HomeCategoryItem(
          label: 'Çantalar',
          imageAsset: TarzBannerAssets.aiTileSquare2,
          leftColor: Color(0xFFC4A574),
        ),
      ];
}

class _CategorySplitCard extends StatelessWidget {
  const _CategorySplitCard({required this.item, this.onTap});

  final HomeCategoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TarzColors.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: ColoredBox(
                color: item.leftColor,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Image.asset(
                item.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: item.leftColor.withValues(alpha: 0.25),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

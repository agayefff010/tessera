import 'package:flutter/material.dart';

import '../data/tarz_banner_assets.dart';
import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';
import '../theme/tarz_text_styles.dart';

class _CategoryTileData {
  const _CategoryTileData(this.label, this.leftColor, this.imageAsset);

  final String label;
  final Color leftColor;
  final String imageAsset;
}

/// Ana səhifə sonu — 2×2 «Kateqoriyalar» şəbəkəsi (sol rəng + sağ şəkil).
class TarzHomeCategoriesSection extends StatelessWidget {
  const TarzHomeCategoriesSection({super.key, this.onCategoryTap});

  final ValueChanged<String>? onCategoryTap;

  static const List<_CategoryTileData> _tiles = [
    _CategoryTileData('Donlar', Color(0xFF5B7FA8), TarzBannerAssets.winter),
    _CategoryTileData('Ayaqqabılar', Color(0xFF3D2A18), TarzBannerAssets.yakup),
    _CategoryTileData('Toplar', Color(0xFF4A5C38), TarzBannerAssets.tomy),
    _CategoryTileData('Çantalar', Color(0xFFC4A574), TarzBannerAssets.aiTileSquare2),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            TarzSpacing.md,
            TarzSpacing.xl,
            TarzSpacing.md,
            TarzSpacing.md,
          ),
          child: Text(
            'Kateqoriyalar',
            style: TarzTextStyles.titleMd.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
          child: LayoutBuilder(
            builder: (context, c) {
              final gap = 10.0;
              final cellW = (c.maxWidth - gap) / 2;
              final cellH = cellW * 0.92;
              return Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: cellW,
                        height: cellH,
                        child: _CategorySplitTile(
                          data: _tiles[0],
                          onTap: () => onCategoryTap?.call(_tiles[0].label),
                        ),
                      ),
                      SizedBox(width: gap),
                      SizedBox(
                        width: cellW,
                        height: cellH,
                        child: _CategorySplitTile(
                          data: _tiles[1],
                          onTap: () => onCategoryTap?.call(_tiles[1].label),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: gap),
                  Row(
                    children: [
                      SizedBox(
                        width: cellW,
                        height: cellH,
                        child: _CategorySplitTile(
                          data: _tiles[2],
                          onTap: () => onCategoryTap?.call(_tiles[2].label),
                        ),
                      ),
                      SizedBox(width: gap),
                      SizedBox(
                        width: cellW,
                        height: cellH,
                        child: _CategorySplitTile(
                          data: _tiles[3],
                          onTap: () => onCategoryTap?.call(_tiles[3].label),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: TarzSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.xxl),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: TarzColors.border),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.35,
                      child: ColoredBox(
                        color: TarzColors.ink.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: TarzSpacing.xl),
      ],
    );
  }
}

class _CategorySplitTile extends StatelessWidget {
  const _CategorySplitTile({required this.data, this.onTap});

  final _CategoryTileData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TarzColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: ColoredBox(
                color: data.leftColor,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(TarzSpacing.sm),
                    child: Text(
                      data.label,
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
                data.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFE8E8E6),
                  child: Icon(Icons.image_not_supported_outlined, color: Colors.black26),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

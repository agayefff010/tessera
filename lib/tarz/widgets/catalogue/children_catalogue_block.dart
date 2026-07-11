import 'package:flutter/material.dart';

import '../../models/plp_category_option.dart';
import '../../models/tarz_children_catalogue_block.dart';

/// Uşaq kataloqu vizual bloku — 50/50 mətn/şəkil, pastel fon.
class ChildrenCatalogueBlock extends StatelessWidget {
  const ChildrenCatalogueBlock({
    super.key,
    required this.data,
    required this.onBlockTap,
    this.onSubcategoryTap,
  });

  final TarzChildrenCatalogueBlock data;
  final VoidCallback onBlockTap;
  final ValueChanged<PlpCategoryOption>? onSubcategoryTap;

  static const double _blockHeight = 152;
  static const Color _titleColor = Color(0xFF111111);
  static const Color _subcategoryColor = Color(0xFF444444);

  @override
  Widget build(BuildContext context) {
    if (data.fullWidthBanner) {
      return Material(
        color: data.backgroundColor,
        child: InkWell(
          onTap: onBlockTap,
          child: SizedBox(
            height: _blockHeight,
            width: double.infinity,
            child: Image.asset(
              data.imageAsset,
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => ColoredBox(
                color: data.backgroundColor,
                child: const Center(
                  child: Icon(Icons.image_outlined, color: Color(0xFF999999)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final textSide = _TextSide(
      title: data.title,
      subcategories: data.subcategories,
      onSubcategoryTap: onSubcategoryTap,
    );
    final imageSide = _ImageSide(asset: data.imageAsset);

    return Material(
      color: data.backgroundColor,
      child: InkWell(
        onTap: onBlockTap,
        child: SizedBox(
          height: _blockHeight,
          width: double.infinity,
          child: Row(
            children: data.imageOnLeft
                ? [imageSide, textSide]
                : [textSide, imageSide],
          ),
        ),
      ),
    );
  }
}

class _TextSide extends StatelessWidget {
  const _TextSide({
    required this.title,
    required this.subcategories,
    this.onSubcategoryTap,
  });

  final String title;
  final List<PlpCategoryOption> subcategories;
  final ValueChanged<PlpCategoryOption>? onSubcategoryTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ChildrenCatalogueBlock._titleColor,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: subcategories.map((option) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => onSubcategoryTap?.call(option),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Text(
                            option.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: ChildrenCatalogueBlock._subcategoryColor,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSide extends StatelessWidget {
  const _ImageSide({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        height: ChildrenCatalogueBlock._blockHeight,
        errorBuilder: (_, __, ___) => ColoredBox(
          color: Colors.black.withValues(alpha: 0.06),
          child: const Center(
            child: Icon(Icons.image_outlined, color: Color(0xFF999999)),
          ),
        ),
      ),
    );
  }
}

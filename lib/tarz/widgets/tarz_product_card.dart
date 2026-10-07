import 'package:flutter/material.dart';

import '../models/tarz_product_preview.dart';
import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';
import '../theme/tarz_text_styles.dart';
import '../utils/tarz_image_cache.dart';

class TarzProductCard extends StatelessWidget {
  const TarzProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final TarzProductPreview product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TarzColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ProductImage(
                    imageUrl: product.imageUrl,
                    imageAsset: product.imageAsset,
                  ),
                  if (product.badgeLabel != null)
                    Positioned(
                      left: TarzSpacing.sm,
                      top: TarzSpacing.sm,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: TarzColors.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TarzSpacing.sm,
                            vertical: TarzSpacing.xxs,
                          ),
                          child: Text(
                            product.badgeLabel!,
                            style: TarzTextStyles.label.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TarzSpacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TarzTextStyles.body.copyWith(
                      color: TarzColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: TarzSpacing.xxs),
                  Text(
                    product.priceLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TarzTextStyles.price,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.imageUrl, this.imageAsset});

  final String? imageUrl;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cacheW = TarzImageCache.px(context, constraints.maxWidth);
        final cacheH = TarzImageCache.px(context, constraints.maxHeight);

        if (imageAsset != null && imageAsset!.isNotEmpty) {
          return Image.asset(
            imageAsset!,
            fit: BoxFit.cover,
            cacheWidth: cacheW,
            cacheHeight: cacheH,
            errorBuilder: (_, __, ___) => _fallback(),
          );
        }
        if (imageUrl == null || imageUrl!.isEmpty) {
          return _fallback();
        }
        return Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          cacheWidth: cacheW,
          cacheHeight: cacheH,
          errorBuilder: (_, __, ___) => _fallback(),
        );
      },
    );
  }

  Widget _fallback() {
    return const ColoredBox(
      color: Color(0xFFECEBE8),
      child: Center(
        child: Icon(Icons.checkroom_rounded, size: 40, color: Colors.black26),
      ),
    );
  }
}

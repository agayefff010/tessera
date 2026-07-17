import 'package:flutter/material.dart';

import '../../cart/tarz_price_utils.dart';
import '../../models/tarz_cart_item.dart';
import '../../theme/tarz_colors.dart';
import '../../utils/tarz_image_cache.dart';

/// Səbət məhsul sətri — Figma Cart layout.
class TarzCartItemTile extends StatelessWidget {
  const TarzCartItemTile({
    super.key,
    required this.item,
    this.onFavorite,
    this.onRemove,
  });

  final TarzCartItem item;
  final VoidCallback? onFavorite;
  final VoidCallback? onRemove;

  static const double _imageWidth = 96;
  static const double _imageHeight = 118;
  static const Color _discountRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? Image.network(
                    item.imageUrl!,
                    width: _imageWidth,
                    height: _imageHeight,
                    fit: BoxFit.cover,
                    cacheWidth: TarzImageCache.px(context, _imageWidth),
                    cacheHeight: TarzImageCache.px(context, _imageHeight),
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : Image.asset(
                    item.imageAsset,
                    width: _imageWidth,
                    height: _imageHeight,
                    fit: BoxFit.cover,
                    cacheWidth: TarzImageCache.px(context, _imageWidth),
                    cacheHeight: TarzImageCache.px(context, _imageHeight),
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: TarzColors.ink,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 10),
                _priceRow(),
                const SizedBox(height: 12),
                _actionRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        if (item.originalPriceLabel != null)
          Text(
            TarzPriceUtils.formatManatSpaced(
              item.originalPriceManat ?? item.priceManat,
            ),
            style: TextStyle(
              fontSize: 13,
              color: TarzColors.inkMuted.withValues(alpha: 0.85),
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          TarzPriceUtils.formatManatSpaced(item.priceManat),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: TarzColors.ink,
          ),
        ),
        if (item.badgeLabel != null)
          DecoratedBox(
            decoration: BoxDecoration(
              color: _discountRed,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Text(
                item.badgeLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _actionRow() {
    return Row(
      children: [
        _iconButton(
          icon: Icons.favorite_border_rounded,
          onTap: onFavorite,
        ),
        const SizedBox(width: 16),
        _iconButton(
          icon: Icons.delete_outline_rounded,
          onTap: onRemove,
        ),
      ],
    );
  }

  Widget _iconButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          icon,
          size: 22,
          color: const Color(0xFF6B6B6B),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return const SizedBox(
      width: _imageWidth,
      height: _imageHeight,
      child: ColoredBox(color: Color(0xFFF0F0F0)),
    );
  }
}

import 'package:flutter/material.dart';

import '../../cart/tarz_price_utils.dart';
import '../../models/tarz_cart_item.dart';
import '../../theme/tarz_colors.dart';

/// Səbət məhsul kartı — şəkil, atributlar, miqdar, əməliyyatlar.
class TarzCartItemTile extends StatelessWidget {
  const TarzCartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    this.onFavorite,
    this.onRemove,
  });

  final TarzCartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onFavorite;
  final VoidCallback? onRemove;

  static const double _imageWidth = 88;
  static const double _imageHeight = 104;
  static const Color _badgeBg = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.imageAsset,
                width: _imageWidth,
                height: _imageHeight,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: _imageWidth,
                  height: _imageHeight,
                  child: ColoredBox(color: Color(0xFFF0F0F0)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.brand.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: TarzColors.inkMuted.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: TarzColors.ink,
                      height: 1.25,
                    ),
                  ),
                  if (_attributesText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _attributesText!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: TarzColors.inkMuted.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _priceRow(),
                  const SizedBox(height: 10),
                  _quantityControl(),
                  const SizedBox(height: 8),
                  _actionRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? get _attributesText {
    final parts = <String>[];
    if (item.size != null) parts.add('Ölçü: ${item.size}');
    if (item.color != null) parts.add('Rəng: ${item.color}');
    if (item.vendor != null) parts.add('Satıcı: ${item.vendor}');
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  Widget _priceRow() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        if (item.originalPriceLabel != null)
          Text(
            TarzPriceUtils.formatManatSpaced(
              item.originalPriceManat ?? item.priceManat,
            ),
            style: TextStyle(
              fontSize: 12,
              color: TarzColors.inkMuted.withValues(alpha: 0.85),
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          TarzPriceUtils.formatManatSpaced(item.priceManat),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: TarzColors.ink,
          ),
        ),
        if (item.badgeLabel != null)
          DecoratedBox(
            decoration: BoxDecoration(
              color: _badgeBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              child: Text(
                item.badgeLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _quantityControl() {
    return Row(
      children: [
        _qtyButton(Icons.remove, onDecrement, enabled: item.quantity > 1),
        Container(
          width: 32,
          alignment: Alignment.center,
          child: Text(
            '${item.quantity}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TarzColors.ink,
            ),
          ),
        ),
        _qtyButton(Icons.add, onIncrement, enabled: true),
      ],
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap, {required bool enabled}) {
    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 16,
            color: enabled
                ? TarzColors.ink
                : TarzColors.inkMuted.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  Widget _actionRow() {
    return Wrap(
      spacing: 4,
      runSpacing: 0,
      children: [
        _actionChip(
          emoji: '❤️',
          label: 'Favorilərə',
          onTap: onFavorite,
        ),
        _actionChip(
          emoji: '🗑',
          label: 'Sil',
          onTap: onRemove,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _actionChip({
    required String emoji,
    required String label,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? const Color(0xFFC62828)
                    : TarzColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

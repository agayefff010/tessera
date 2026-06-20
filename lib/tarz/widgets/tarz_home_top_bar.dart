import 'package:flutter/material.dart';

import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';
import '../theme/tarz_text_styles.dart';
import 'tarz_cart_icon_button.dart';

class TarzHomeTopBar extends StatelessWidget {
  const TarzHomeTopBar({
    super.key,
    required this.onMenu,
    this.onSearch,
    required this.onWishlist,
    required this.onCart,
  });

  final VoidCallback onMenu;
  final VoidCallback? onSearch;
  final VoidCallback onWishlist;
  final VoidCallback onCart;

  static const List<Color> _brandMarks = [
    Color(0xFFE85D04),
    Color(0xFF2774AE),
    Color(0xFFE63946),
    Color(0xFFF4D35E),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TarzSpacing.xs,
        TarzSpacing.md,
        TarzSpacing.sm,
        TarzSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenu,
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menyu',
          ),
          if (onSearch != null)
            IconButton(
              onPressed: onSearch,
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Axtarış',
            ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _brandMarks.length; i++)
                        Padding(
                          padding: EdgeInsets.only(right: i == _brandMarks.length - 1 ? 8 : 3),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _brandMarks[i],
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                            child: const SizedBox(width: 7, height: 7),
                          ),
                        ),
                    ],
                  ),
                  const Text('TESSERA', style: TarzTextStyles.tesseraWordmark),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0EE),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onWishlist,
                  icon: const Icon(Icons.favorite_border_rounded),
                  tooltip: 'Seçilmişlər',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    foregroundColor: TarzColors.ink,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                TarzCartIconButton(onPressed: onCart),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

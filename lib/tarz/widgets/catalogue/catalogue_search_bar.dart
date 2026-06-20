import 'package:flutter/material.dart';

import '../tarz_cart_icon_button.dart';

/// Kataloq üst sətri — axtarış pill + səbət düyməsi.
class CatalogueSearchBar extends StatelessWidget {
  const CatalogueSearchBar({
    super.key,
    required this.onSearchTap,
    required this.onCartTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onCartTap;

  static const Color _fieldBg = Color(0xFFF3F3F3);
  static const double _size = 46;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: _fieldBg,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: onSearchTap,
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: _size,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(
                        Icons.search_rounded,
                        size: 22,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Məhsul və ya brend',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: _fieldBg,
            shape: const CircleBorder(),
            child: SizedBox(
              width: _size,
              height: _size,
              child: TarzCartIconButton(onPressed: onCartTap),
            ),
          ),
        ],
      ),
    );
  }
}

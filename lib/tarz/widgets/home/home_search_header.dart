import 'package:flutter/material.dart';

import '../../theme/tarz_colors.dart';
import '../tarz_cart_icon_button.dart';

/// Üst sətir: axtarış pill + bildiriş + səbət.
class HomeSearchHeader extends StatelessWidget {
  const HomeSearchHeader({
    super.key,
    required this.onSearchTap,
    required this.onNotificationTap,
    required this.onCartTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onCartTap;

  static const Color _fieldBg = Color(0xFFF2F2EF);
  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'HomeSearchHeader ${DateTime.now().millisecondsSinceEpoch}',
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                        color: TarzColors.inkMuted.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Məhsul və ya brend',
                        style: TextStyle(
                          fontSize: 14,
                          color: TarzColors.inkMuted.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _circleIcon(Icons.notifications_none_rounded, onNotificationTap),
          const SizedBox(width: 8),
          _circleCart(onCartTap),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return Material(
      color: _fieldBg,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: _size,
          height: _size,
          child: Center(
            child: Icon(
              icon,
              size: 22,
              color: TarzColors.ink.withValues(alpha: 0.75),
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleCart(VoidCallback onTap) {
    return Material(
      color: _fieldBg,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: _size,
        height: _size,
        child: TarzCartIconButton(onPressed: onTap),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../cart/tarz_cart_controller.dart';
import '../theme/tarz_colors.dart';

/// Çanta ikonu + səbət sayğacı (məs. kiçik «1»).
class TarzCartIconButton extends StatelessWidget {
  const TarzCartIconButton({
    super.key,
    required this.onPressed,
    this.iconSize = 22,
  });

  final VoidCallback onPressed;
  final double iconSize;

  static const double _tapSize = 48;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TarzCartController.instance,
      builder: (context, _) {
        final count = TarzCartController.instance.totalQuantity;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: _tapSize,
              height: _tapSize,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: iconSize,
                    color: TarzColors.ink.withValues(alpha: 0.75),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: const BoxDecoration(
                          color: TarzColors.ink,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

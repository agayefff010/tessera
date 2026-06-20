import 'package:flutter/material.dart';

import '../cart/tarz_cart_controller.dart';
import '../theme/tarz_colors.dart';

/// Çanta ikonu + səbət sayğacı (məs. kiçik «1»).
class TarzCartIconButton extends StatelessWidget {
  const TarzCartIconButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TarzCartController.instance,
      builder: (context, _) {
        final count = TarzCartController.instance.totalQuantity;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onPressed,
              icon: const Icon(Icons.shopping_bag_outlined),
              tooltip: 'Səbət',
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                foregroundColor: TarzColors.ink,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            if (count > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
        );
      },
    );
  }
}

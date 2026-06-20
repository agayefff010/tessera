import 'package:flutter/material.dart';

import '../../theme/tarz_colors.dart';

/// PLP başlığı — geri, kateqoriya adı, məhsul sayı, axtarış.
class PlpHeader extends StatelessWidget {
  const PlpHeader({
    super.key,
    required this.title,
    required this.productCountLabel,
    required this.onBack,
    required this.onSearch,
  });

  final String title;
  final String productCountLabel;
  final VoidCallback onBack;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              style: IconButton.styleFrom(foregroundColor: TarzColors.ink),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: TarzColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    productCountLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: TarzColors.inkMuted.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onSearch,
              icon: const Icon(Icons.search_rounded, size: 22),
              style: IconButton.styleFrom(foregroundColor: TarzColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

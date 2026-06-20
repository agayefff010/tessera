import 'package:flutter/material.dart';

import '../../theme/tarz_colors.dart';

/// PLP boş vəziyyət.
class PlpEmptyState extends StatelessWidget {
  const PlpEmptyState({
    super.key,
    required this.onResetFilters,
  });

  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: TarzColors.inkMuted.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Məhsul tapılmadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TarzColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Filtrləri dəyişdirin və ya sıfırlayın',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: TarzColors.inkMuted.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onResetFilters,
              style: OutlinedButton.styleFrom(
                foregroundColor: TarzColors.ink,
                side: const BorderSide(color: TarzColors.ink),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Filtrləri sıfırla',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

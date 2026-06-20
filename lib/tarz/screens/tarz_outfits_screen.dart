import 'package:flutter/material.dart';

import '../theme/tarz_breakpoints.dart';
import '../theme/tarz_colors.dart';

/// Kombinlərim səhifəsi — navbar asılma ikonu.
class TarzOutfitsScreen extends StatelessWidget {
  const TarzOutfitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = TarzBreakpoints.contentMaxWidth(constraints.maxWidth);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checkroom_outlined,
                          size: 56,
                          color: TarzColors.inkMuted.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Kombinlərim',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: TarzColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Yaratdığınız kombinlər burada görünəcək.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: TarzColors.inkMuted.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';

/// Tam enlikdə «Qadın / Kişi / Uşaq» tipli seqment nəzarəti.
class TarzGenderSegmentBar extends StatelessWidget {
  const TarzGenderSegmentBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFECECEA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List.generate(labels.length, (i) {
              final selected = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? TarzColors.ink : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : TarzColors.inkMuted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

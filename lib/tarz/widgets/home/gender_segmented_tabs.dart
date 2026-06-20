import 'package:flutter/material.dart';

import '../../theme/tarz_colors.dart';

/// Qadın / Kişi / Uşaq — seçili tab #FF315F.
class GenderSegmentedTabs extends StatelessWidget {
  const GenderSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const Color _track = Color(0xFFF2F2EF);
  static const Color _selected = Color(0xFFFF315F);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _track,
          borderRadius: BorderRadius.circular(999),
        ),
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: List.generate(labels.length, (i) {
                final sel = i == selectedIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSelected(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: sel ? _selected : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        gradient: sel
                            ? const LinearGradient(
                                colors: [Color(0xFFFF315F), Color(0xFFE91E63)],
                              )
                            : null,
                      ),
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? Colors.white : TarzColors.inkMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

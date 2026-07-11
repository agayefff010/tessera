import 'package:flutter/material.dart';

/// Qadın / Kişi / Uşaq — cinsə görə rəngli seqment nəzarəti.
class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const Color _track = Color(0xFFF3F3F3);
  static const Duration _duration = Duration(milliseconds: 250);

  static const Color womenColor = Color(0xFFFF315F);
  static const Color menColor = Color(0xFF123A8C);
  static const Color kidsColor = Color(0xFFFFC107);

  static Color colorForIndex(int index) {
    switch (index) {
      case 0:
        return womenColor;
      case 1:
        return menColor;
      case 2:
        return kidsColor;
      default:
        return womenColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = labels.length;
    final safeIndex = selectedIndex.clamp(0, count - 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          const padding = 4.0;
          final innerWidth = trackWidth - padding * 2;
          final segmentWidth = innerWidth / count;
          final pillLeft = padding + segmentWidth * safeIndex;

          return DecoratedBox(
            decoration: BoxDecoration(
              color: _track,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SizedBox(
              height: 46,
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: _duration,
                    curve: Curves.easeOutCubic,
                    left: pillLeft,
                    top: padding,
                    bottom: padding,
                    width: segmentWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorForIndex(safeIndex),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(padding),
                    child: Row(
                      children: List.generate(count, (i) {
                        final sel = i == safeIndex;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onSelected(i),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: _duration,
                                curve: Curves.easeOutCubic,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                  color: sel
                                      ? Colors.white
                                      : const Color(0xFF555555),
                                ),
                                child: Text(labels[i]),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

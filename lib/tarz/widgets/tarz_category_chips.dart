import 'package:flutter/material.dart';

import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';

class TarzCategoryChips extends StatelessWidget {
  const TarzCategoryChips({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: TarzSpacing.sm),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return ChoiceChip(
            label: Text(categories[index]),
            selected: selected,
            onSelected: (_) => onSelected(index),
            showCheckmark: false,
            selectedColor: TarzColors.ink,
            labelStyle: TextStyle(
              color: selected ? Colors.white : TarzColors.ink,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            side: const BorderSide(color: TarzColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: TarzSpacing.md),
          );
        },
      ),
    );
  }
}

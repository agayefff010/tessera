import 'package:flutter/material.dart';

import '../../theme/tarz_colors.dart';

enum PlpFilterAction { filters, sort, categories }

/// Yapışqan filtr/sırala/kateqoriya paneli.
class PlpFilterActionBar extends StatelessWidget {
  const PlpFilterActionBar({
    super.key,
    required this.selected,
    required this.onFilters,
    required this.onSort,
    required this.onCategories,
  });

  final PlpFilterAction? selected;
  final VoidCallback onFilters;
  final VoidCallback onSort;
  final VoidCallback onCategories;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.tune_rounded,
                label: 'Filtrlər',
                selected: selected == PlpFilterAction.filters,
                onTap: onFilters,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                icon: Icons.swap_vert_rounded,
                label: 'Sırala',
                selected: selected == PlpFilterAction.sort,
                onTap: onSort,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                icon: Icons.grid_view_rounded,
                label: 'Kateqoriyalar',
                selected: selected == PlpFilterAction.categories,
                onTap: onCategories,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const Duration _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeOutCubic,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? TarzColors.ink : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? TarzColors.ink : const Color(0xFFE5E5E5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : TarzColors.ink,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : TarzColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

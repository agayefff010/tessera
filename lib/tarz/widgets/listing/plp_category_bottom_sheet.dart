import 'package:flutter/material.dart';

import '../../models/plp_category_option.dart';
import '../../theme/tarz_colors.dart';

/// PLP kateqoriya seçici bottom sheet.
Future<PlpCategoryOption?> showPlpCategoryBottomSheet(
  BuildContext context, {
  required List<PlpCategoryOption> categories,
  PlpCategoryOption? selected,
}) {
  return showModalBottomSheet<PlpCategoryOption>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final maxH = MediaQuery.sizeOf(context).height * 0.55;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kateqoriyalar',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: TarzColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  itemBuilder: (context, i) {
                    final option = categories[i];
                    final isSelected = selected != null &&
                        (option.id == selected.id || option.name == selected.name);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        option.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? TarzColors.ink
                              : TarzColors.inkMuted,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_rounded, color: TarzColors.ink)
                          : null,
                      onTap: () => Navigator.of(context).pop(option),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

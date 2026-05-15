import 'package:flutter/material.dart';

import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';

/// Ana səhifə — alt xəttli mətn sahəsi + «Axtar» həb düyməsi.
class TarzHomeSearchBar extends StatelessWidget {
  const TarzHomeSearchBar({
    super.key,
    required this.controller,
    this.onSearch,
    this.hintText = 'Məhsul, brend və ya rəng',
  });

  final TextEditingController controller;
  final ValueChanged<String>? onSearch;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TarzSpacing.md,
        0,
        TarzSpacing.md,
        TarzSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSearch,
              cursorColor: TarzColors.ink,
              style: const TextStyle(
                fontSize: 15,
                color: TarzColors.ink,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: TarzColors.inkMuted.withValues(alpha: 0.75),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.only(
                  left: 0,
                  right: TarzSpacing.sm,
                  bottom: TarzSpacing.sm,
                  top: TarzSpacing.xs,
                ),
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: TarzColors.border.withValues(alpha: 0.95),
                    width: 1,
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: TarzColors.ink,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: TarzSpacing.md),
          FilledButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              onSearch?.call(controller.text.trim());
            },
            style: FilledButton.styleFrom(
              backgroundColor: TarzColors.ink,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: TarzSpacing.lg,
                vertical: TarzSpacing.md,
              ),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Axtar'),
          ),
        ],
      ),
    );
  }
}

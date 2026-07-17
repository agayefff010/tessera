import 'package:flutter/material.dart';

import '../theme/tarz_colors.dart';
import '../theme/tarz_spacing.dart';

/// Ana səhifə / axtarış — alt xəttli mətn sahəsi + «Axtar» həb düyməsi.
class TarzHomeSearchBar extends StatefulWidget {
  const TarzHomeSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.autofocus = false,
    this.onSearch,
    this.onChanged,
    this.hintText = 'Məhsul, brend və ya rəng',
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<String>? onSearch;
  final ValueChanged<String>? onChanged;
  final String hintText;

  @override
  State<TarzHomeSearchBar> createState() => _TarzHomeSearchBarState();
}

class _TarzHomeSearchBarState extends State<TarzHomeSearchBar> {
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
              controller: widget.controller,
              focusNode: widget.focusNode,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.search,
              onSubmitted: widget.onSearch,
              onChanged: widget.onChanged,
              cursorColor: TarzColors.ink,
              style: const TextStyle(
                fontSize: 15,
                color: TarzColors.ink,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
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
              widget.onSearch?.call(widget.controller.text.trim());
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

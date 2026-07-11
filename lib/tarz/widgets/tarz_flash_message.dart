import 'package:flutter/material.dart';

import '../theme/tarz_colors.dart';

/// Ekranın ortasında qısa müddət görünən kiçik mətn (fonsuz).
abstract final class TarzFlashMessage {
  static OverlayEntry? _current;

  static void show(
    BuildContext context,
    String message, {
    Duration visibleFor = const Duration(milliseconds: 900),
  }) {
    _current?.remove();
    _current = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FlashMessageBubble(
        message: message,
        visibleFor: visibleFor,
        onDismissed: () {
          if (entry.mounted) entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }
}

class _FlashMessageBubble extends StatefulWidget {
  const _FlashMessageBubble({
    required this.message,
    required this.visibleFor,
    required this.onDismissed,
  });

  final String message;
  final Duration visibleFor;
  final VoidCallback onDismissed;

  @override
  State<_FlashMessageBubble> createState() => _FlashMessageBubbleState();
}

class _FlashMessageBubbleState extends State<_FlashMessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
    Future<void>.delayed(widget.visibleFor, () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox.expand(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FadeTransition(
                opacity: _opacity,
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: TarzColors.ink.withValues(alpha: 0.72),
                    height: 1.2,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

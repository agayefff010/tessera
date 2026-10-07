import 'package:flutter/material.dart';

/// Klaviatura inset-i yalnız alt spacer-də dinlənilir — form sahələri
/// hər animasiya kadrında yenidən qurulmur.
class KeyboardAwareScrollView extends StatelessWidget {
  const KeyboardAwareScrollView({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.keyboardExtra = 16,
    this.physics,
    this.controller,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double keyboardExtra;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] KeyboardAwareScrollView');
    final base = padding.resolve(Directionality.of(context));

    return SingleChildScrollView(
      controller: controller,
      physics: physics ?? const ClampingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        base.left,
        base.top,
        base.right,
        base.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          _KeyboardInsetSpacer(extra: keyboardExtra),
        ],
      ),
    );
  }
}

class _KeyboardInsetSpacer extends StatelessWidget {
  const _KeyboardInsetSpacer({required this.extra});

  final double extra;

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] _KeyboardInsetSpacer');
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SizedBox(height: bottomInset + extra);
  }
}

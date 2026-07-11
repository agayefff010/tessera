import 'package:flutter/material.dart';

/// Klaviatura açılanda yalnız scroll sahəsi yenilənir — bütün səhifə yox.
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
    final base = padding.resolve(Directionality.of(context));
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      controller: controller,
      physics: physics,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        base.left,
        base.top,
        base.right,
        base.bottom + bottomInset + keyboardExtra,
      ),
      child: child,
    );
  }
}

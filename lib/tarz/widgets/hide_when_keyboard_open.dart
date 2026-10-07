import 'package:flutter/material.dart';

/// Klaviatura açıq olanda [child]-ı gizlədir.
/// Yalnız bu widget rebuild olur — parent/form toxunulmur.
///
/// Vacib: [Scaffold.resizeToAvoidBottomInset] `false` olmalıdır,
/// yoxsa Scaffold viewInsets-i udur və bu widget heç vaxt gizlənmir.
class HideWhenKeyboardOpen extends StatelessWidget {
  const HideWhenKeyboardOpen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] HideWhenKeyboardOpen');
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (keyboardOpen) return const SizedBox.shrink();
    return child;
  }
}

/// Yalnız hündürlüyü dəyişir — form sahələrini rebuild etmir.
class KeyboardBottomSpacer extends StatelessWidget {
  const KeyboardBottomSpacer({super.key, this.extra = 16});

  final double extra;

  @override
  Widget build(BuildContext context) {
    debugPrint('[rebuild] KeyboardBottomSpacer');
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return SizedBox(height: inset > 0 ? inset + extra : extra);
  }
}

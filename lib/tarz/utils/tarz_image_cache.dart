import 'package:flutter/widgets.dart';

/// Decode-size helpers so [Image.network] / [Image.asset] match on-screen pixels.
abstract final class TarzImageCache {
  static int px(BuildContext context, double logicalSize) {
    if (!logicalSize.isFinite || logicalSize <= 0) return 1;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return (logicalSize * dpr).round().clamp(1, 4096);
  }
}

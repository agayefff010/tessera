import 'dart:math' as math;

/// Ekran eninə görə layout qərarları.
abstract final class TarzBreakpoints {
  static const double compactMax = 600;
  static const double expandedMax = 900;

  static bool isCompact(double width) => width < compactMax;

  static double contentMaxWidth(double screenWidth) {
    if (screenWidth <= compactMax) return screenWidth;
    return math.min(screenWidth, 520);
  }

  static int productGridColumns(double width) {
    if (width >= expandedMax) return 3;
    return 2;
  }
}

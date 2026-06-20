/// Qiymət mətnlərini manat ədədi ilə işləmək.
abstract final class TarzPriceUtils {
  static double parseManat(String label) {
    final cleaned = label.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  static String formatManat(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()}₼';
    }
    return '${value.toStringAsFixed(2)}₼';
  }

  /// UI göstərimi: `90 ₼` (boşluqlu).
  static String formatManatSpaced(double value) {
    return formatManat(value).replaceAll('₼', ' ₼');
  }

  static String formatSignedManat(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${formatManat(value.abs()).replaceFirst('₼', '')}₼'.replaceAll('--', '-');
  }
}

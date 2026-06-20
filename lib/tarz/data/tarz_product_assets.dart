/// `assets/products/` altındakı məhsul şəkil yolları.
abstract final class TarzProductAssets {
  static const String nikeV5Rnr = 'assets/products/nike_v5_rnr.png';
  static const String greenCardigan = 'assets/products/green_cardigan.png';

  static const List<String> all = [nikeV5Rnr, greenCardigan];

  static String demoAt(int index) => all[index % all.length];
}
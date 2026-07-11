/// Cins tab indeksləri ↔ backend kateqoriya ID-ləri.
abstract final class TarzGenderConfig {
  static const List<String> genderIds = [
    '69a7390902527190857b0205', // Qadın
    '69a7390902527190857b01d8', // Kişi
    '69a7390902527190857b0240', // Uşaq
  ];

  static String idForIndex(int index) {
    if (index < 0 || index >= genderIds.length) {
      return genderIds.first;
    }
    return genderIds[index];
  }
}

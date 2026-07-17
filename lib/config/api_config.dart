/// Production API — yalnız HTTPS (Play Store / App Store).
abstract final class ApiConfig {
  static const String baseUrl =
      'https://tessera-backend-production.up.railway.app/api';

  static const String loginPath = '/auth/login';
  static const String registerPath = '/auth/register';
  static const String refreshPath = '/auth/refresh';
  static const String mePath = '/auth/me';
  static const String profilePath = '/auth/profile';
  static const String checkoutPath = '/checkout';
  static const String ordersPath = '/orders';
  static const String bannersPath = '/banners';
  static const String adminBannersPath = '/admin/banners';
  static const String advertisementsActivePath = '/advertisements/active';
  static const String vendorsSlugPath = '/vendors/slug';

  static const String adPlacementMainBanner = 'main_banner';
  static const String adPlacementSideTop = 'side_top';
  static const String adPlacementSideBottom = 'side_bottom';
}

import '../services/auth_service.dart';
import '../services/auth_storage.dart';
import '../tarz/cart/tarz_cart_controller.dart';
import '../tarz/data/category_repository.dart';
import '../tarz/data/home_repository.dart';
import '../tarz/orders/tarz_orders_controller.dart';
import '../tarz/wishlist/tarz_wishlist_controller.dart';

/// App startup preload — splash video müddətində paralel init.
class AppBootstrap {
  AppBootstrap._();

  static final AppBootstrap instance = AppBootstrap._();

  Future<void>? _startupFuture;
  HomeBootstrapSnapshot? _homeSnapshot;

  /// `main()`-dən çağır — video görünməzdən əvvəl init başlayır.
  void start() {
    _startupFuture ??= _runStartup();
  }

  /// Home açılanda gözləmək üçün — video bitibsə data hazır olana qədər.
  Future<void> get ready {
    start();
    return _startupFuture!;
  }

  HomeBootstrapSnapshot? get homeSnapshot => _homeSnapshot;

  void cacheHomeSnapshot(HomeBootstrapSnapshot snapshot) {
    _homeSnapshot = snapshot;
  }

  Future<void> _runStartup() async {
    await Future.wait([
      _warmAuth(),
      CategoryRepository.instance.warmCache(),
      TarzWishlistController.instance.ensureLoaded(),
      TarzCartController.instance.ensureLoaded(),
      TarzOrdersController.instance.ensureLoaded(),
      _preloadHome(),
    ]);
  }

  Future<void> _warmAuth() async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return;

    final auth = AuthService();
    try {
      await auth.fetchCurrentUser();
    } catch (_) {
      // Cached user / token refresh artıq AuthStorage-da idarə olunur.
    } finally {
      auth.dispose();
    }
  }

  Future<void> _preloadHome() async {
    final repo = HomeRepository();
    try {
      _homeSnapshot = await repo.loadBootstrapSnapshot();
    } catch (_) {
      _homeSnapshot = null;
    } finally {
      repo.dispose();
    }
  }
}

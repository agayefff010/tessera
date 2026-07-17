import '../../services/api_client.dart';
import '../../services/api_exception.dart';
import '../../services/auth_storage.dart';
import '../data/outfit_mapper.dart';
import '../data/product_mapper.dart';
import '../models/tarz_outfit.dart';
import '../models/tarz_product_preview.dart';

/// `POST /outfits` + `GET /outfits/me`.
class OutfitService {
  OutfitService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<TarzSavedOutfit>> fetchMyOutfits() async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) return const [];

    try {
      final body = await _client.get('/outfits/me', bearerToken: token);
      final list = OutfitMapper.savedListFromResponse(body);
      // Backend çox vaxt yalnız productId qaytarır — şəkil/ad üçün hydrate.
      return Future.wait(list.map(_hydrateOutfit));
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) return const [];
      rethrow;
    }
  }

  Future<TarzSavedOutfit?> saveOutfit(
    TarzGeneratedOutfit outfit, {
    String? name,
  }) async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Kombin saxlamaq üçün daxil olun');
    }

    final localItems = outfit.displayItems;
    if (localItems.isEmpty) {
      throw const ApiException('Saxlanılacaq kombin yoxdur');
    }

    final result = await _client.post(
      '/outfits',
      body: OutfitMapper.toSaveBody(outfit, name: name),
      bearerToken: token,
    );

    final data = result.data['data'] ?? result.data['outfit'] ?? result.data;
    if (data is Map<String, dynamic>) {
      final parsed = OutfitMapper.savedFromJson(data);
      final id = parsed?.id ??
          data['_id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // API populate etməyibsə lokal şəkilli snapshot saxla.
      final remoteItems = parsed?.items ?? const <TarzOutfitItem>[];
      final hasImages = remoteItems.any(
        (e) => (e.product.imageUrl ?? '').isNotEmpty,
      );

      return TarzSavedOutfit(
        id: id,
        name: parsed?.name ?? name ?? outfit.suggestedName,
        items: hasImages ? remoteItems : localItems,
        createdAt: parsed?.createdAt ?? DateTime.now(),
        aiImageUrl: parsed?.aiImageUrl,
        aiImageStatus: parsed?.aiImageStatus,
        aiModel: parsed?.aiModel,
        aiProvider: parsed?.aiProvider,
      );
    }

    return TarzSavedOutfit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name ?? outfit.suggestedName,
      items: localItems,
      createdAt: DateTime.now(),
    );
  }

  Future<void> deleteOutfit(String outfitId) async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Kombin silmək üçün daxil olun');
    }

    await _client.delete('/outfits/$outfitId', bearerToken: token);
  }

  Future<TarzSavedOutfit> generateAiImage(TarzSavedOutfit outfit) async {
    final token = await AuthStorage.instance.getToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('AI obraz yaratmaq üçün daxil olun');
    }

    final result = await _client.post(
      '/outfits/${outfit.id}/generate-ai-image',
      body: const {},
      bearerToken: token,
    );

    final data = result.data['outfit'] ?? result.data['data'] ?? result.data;
    if (data is Map<String, dynamic>) {
      final parsed = OutfitMapper.savedFromJson(data);
      if (parsed != null) {
        final hydrated = await _hydrateOutfit(parsed);
        // Backend məhsulları natamam qaytarsa, mövcud kart məhsullarını saxla.
        return hydrated.copyWith(
          items: hydrated.items.isNotEmpty ? hydrated.items : outfit.items,
        );
      }
      return outfit.copyWith(
        aiImageUrl: data['aiImageUrl']?.toString(),
        aiImageStatus: data['aiImageStatus']?.toString(),
        aiModel: data['aiModel']?.toString(),
        aiProvider: data['aiProvider']?.toString(),
      );
    }

    return outfit;
  }

  Future<TarzSavedOutfit> _hydrateOutfit(TarzSavedOutfit outfit) async {
    if (outfit.items.isEmpty) return outfit;

    final needsHydration = outfit.items.any(_needsProductHydration);
    if (!needsHydration) return outfit;

    final hydrated = await Future.wait(
      outfit.items.map((item) async {
        if (!_needsProductHydration(item)) return item;
        final product = await _fetchProductPreview(item.product.id);
        if (product == null) return item;
        return TarzOutfitItem(role: item.role, product: product);
      }),
    );

    return TarzSavedOutfit(
      id: outfit.id,
      name: outfit.name,
      items: hydrated,
      createdAt: outfit.createdAt,
      aiImageUrl: outfit.aiImageUrl,
      aiImageStatus: outfit.aiImageStatus,
      aiModel: outfit.aiModel,
      aiProvider: outfit.aiProvider,
    );
  }

  bool _needsProductHydration(TarzOutfitItem item) {
    final p = item.product;
    if (p.id.isEmpty) return false;
    final noImage = p.imageUrl == null || p.imageUrl!.isEmpty;
    final placeholderTitle =
        p.title.isEmpty || p.title == 'Məhsul' || p.title == 'Məhsul ';
    return noImage || placeholderTitle;
  }

  Future<TarzProductPreview?> _fetchProductPreview(String id) async {
    try {
      final body = await _client.get('/products/$id');
      final raw = body['data'] ?? body['product'] ?? body;
      if (raw is! Map<String, dynamic>) return null;
      final preview = ProductMapper.fromJson(raw);
      return preview.id.isEmpty ? null : preview;
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.dispose();
}

import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../models/plp_category_option.dart';
import '../models/tarz_children_catalogue_block.dart';
import '../models/tarz_product_preview.dart';
import '../widgets/home/category_grid_section.dart';
import 'tarz_catalogue_assets.dart';
import 'tarz_gender_config.dart';

/// Kateqoriya ağacı — kataloq və PLP üçün.
class CategoryRepository {
  CategoryRepository({ApiClient? client})
      : _client = client ?? ApiClient(),
        _ownsClient = client == null,
        _isShared = false;

  CategoryRepository._shared()
      : _client = ApiClient(),
        _ownsClient = true,
        _isShared = true;

  /// App-wide shared instance — one `/categories` tree cache for all screens.
  static final CategoryRepository instance = CategoryRepository._shared();

  final ApiClient _client;
  final bool _ownsClient;
  final bool _isShared;

  /// Shared across all repository instances (including [instance]).
  static List<Map<String, dynamic>>? _sharedCache;
  static Future<List<Map<String, dynamic>>>? _sharedLoad;

  Future<List<PlpCategoryOption>> fetchCatalogueCategories(int genderIndex) async {
    final genderId = TarzGenderConfig.idForIndex(genderIndex);
    final genderNode = await _findGenderNode(genderId);
    if (genderNode == null) return _fallbackCatalogue();

    final children = genderNode['children'];
    if (children is! List) return _fallbackCatalogue();

    final options = <PlpCategoryOption>[];
    for (final child in children) {
      if (child is! Map<String, dynamic>) continue;
      final option = _optionFromNode(child);
      if (option == null || _isBrandsNode(child)) continue;
      options.add(option);
    }

    options.addAll(const [
      PlpCategoryOption(id: PlpSpecialCategory.discounts, name: 'Endirimlər'),
      PlpCategoryOption(id: PlpSpecialCategory.brands, name: 'Brendlər'),
    ]);

    return options.isEmpty ? _fallbackCatalogue() : options;
  }

  /// Uşaq kataloqu — yalnız Körpə / Oğlan / Qız (sıra: 1→2→3).
  static const int kidsMaxVisibleSubcategories = 5;

  Future<List<TarzChildrenCatalogueBlock>> fetchKidsCatalogueBlocks() async {
    final genderId = TarzGenderConfig.idForIndex(2);
    final genderNode = await _findGenderNode(genderId);
    if (genderNode == null) return const [];

    final children = genderNode['children'];
    if (children is! List) return const [];

    TarzChildrenCatalogueBlock? korpe;
    TarzChildrenCatalogueBlock? oglan;
    TarzChildrenCatalogueBlock? qiz;

    for (final child in children) {
      if (child is! Map<String, dynamic>) continue;
      if (_isBrandsNode(child)) continue;

      final id = child['_id']?.toString();
      final name = child['name']?.toString() ?? '';
      final slug = child['slug']?.toString() ?? '';
      if (id == null || id.isEmpty || name.isEmpty) continue;

      final kind = _kidsBlockKind(slug: slug, name: name);
      if (kind == null) continue;

      final visual = _kidsBlockVisual(kind);
      final block = TarzChildrenCatalogueBlock(
        categoryId: id,
        title: name,
        subcategories: _childrenAsOptions(child)
            .take(kidsMaxVisibleSubcategories)
            .toList(),
        backgroundColor: visual.backgroundColor,
        imageAsset: visual.imageAsset,
        imageOnLeft: visual.imageOnLeft,
        fullWidthBanner: false,
      );

      switch (kind) {
        case _KidsBlockKind.korpe:
          korpe ??= block;
        case _KidsBlockKind.oglan:
          oglan ??= block;
        case _KidsBlockKind.qiz:
          qiz ??= block;
      }
    }

    return [
      if (korpe != null) korpe,
      if (oglan != null) oglan,
      if (qiz != null) qiz,
    ];
  }

  /// Yalnız kök Körpə / Oğlan / Qız slotları (Geyim, Ayaqqabı və s. deyil).
  _KidsBlockKind? _kidsBlockKind({required String slug, required String name}) {
    final s = slug.toLowerCase();
    final n = name.toLowerCase();
    // Oğlan / qız / körpə — slug əvvəl (encoding-dən asılı deyil).
    if (s.contains('oglan') || n.contains('oğlan') || n.contains('oglan')) {
      return _KidsBlockKind.oglan;
    }
    if (s.contains('qiz') || n.contains('qız') || n.contains('qiz')) {
      return _KidsBlockKind.qiz;
    }
    if (s.contains('korpe') || n.contains('körpə') || n.contains('korpe')) {
      return _KidsBlockKind.korpe;
    }
    return null;
  }

  ({
    Color backgroundColor,
    String imageAsset,
    bool imageOnLeft,
  }) _kidsBlockVisual(_KidsBlockKind kind) {
    switch (kind) {
      case _KidsBlockKind.oglan:
        return (
          backgroundColor: const Color(0xFFE8F5E9),
          imageAsset: TarzCatalogueAssets.childrenOglanlar,
          imageOnLeft: true,
        );
      case _KidsBlockKind.qiz:
        return (
          backgroundColor: const Color(0xFFE3F2FD),
          imageAsset: TarzCatalogueAssets.childrenQizlar,
          imageOnLeft: false,
        );
      case _KidsBlockKind.korpe:
        return (
          backgroundColor: const Color(0xFFFFF3E0),
          imageAsset: TarzCatalogueAssets.childrenKorpeler,
          imageOnLeft: true,
        );
    }
  }

  Future<List<PlpCategoryOption>> fetchSubcategories(String parentCategoryId) async {
    final node = await _findNodeById(parentCategoryId);
    if (node == null) return const [];
    return _childrenAsOptions(node);
  }

  /// Kateqoriya + bütün alt kateqoriya ID-ləri (məhsul filtri üçün).
  Future<Set<String>> collectCategoryScope(String categoryId) async {
    if (categoryId == PlpSpecialCategory.discounts ||
        categoryId == PlpSpecialCategory.brands) {
      return {};
    }

    final node = await _findNodeById(categoryId);
    if (node == null) return {categoryId};

    final ids = <String>{categoryId};
    _collectDescendantIds(node, ids);
    return ids;
  }

  Future<PlpCategoryOption?> findById(String categoryId) async {
    final node = await _findNodeById(categoryId);
    if (node == null) return null;
    return _optionFromNode(node);
  }

  /// Ana səhifə 2×2 kateqoriya şəbəkəsi — API ID-ləri ilə.
  Future<List<HomeCategoryItem>> fetchHomeGridCategories({
    int genderIndex = 0,
  }) async {
    final mock = CategoryGridSection.mockCategories();
    final apiBySlot = List<String?>.filled(4, null);

    for (final gi in [genderIndex, 0, 1, 2]) {
      await _fillHomeCategorySlots(gi, apiBySlot);
    }

    return [
      for (var i = 0; i < mock.length; i++)
        HomeCategoryItem(
          label: mock[i].label,
          leftColor: mock[i].leftColor,
          imageAsset: mock[i].imageAsset,
          imageUrl: mock[i].imageUrl,
          categoryId: apiBySlot[i],
        ),
    ];
  }

  /// Outfit role (`shoes`, `bag`, …) → gender altında kateqoriya ID.
  Future<String?> findCategoryIdForOutfitRole(
    String role, {
    String? genderId,
    int genderIndex = 0,
  }) async {
    final preferredGender = genderId ?? TarzGenderConfig.idForIndex(genderIndex);
    final genderOrder = <String>[
      preferredGender,
      ...TarzGenderConfig.genderIds.where((id) => id != preferredGender),
    ];

    for (final gid in genderOrder) {
      final genderNode = await _findGenderNode(gid);
      if (genderNode == null) continue;

      Map<String, dynamic>? best;
      var bestScore = -1;

      void consider(Map<String, dynamic> node) {
        if (_isBrandsNode(node)) return;
        final score = _outfitRoleMatchScore(role, node);
        if (score > bestScore) {
          bestScore = score;
          best = node;
        }
      }

      final children = genderNode['children'];
      if (children is List) {
        for (final child in children) {
          if (child is! Map<String, dynamic>) continue;
          consider(child);
          // Alt kateqoriyalara da bax (məs. Geyim → Jaketlər).
          final nested = child['children'];
          if (nested is List) {
            for (final n in nested) {
              if (n is Map<String, dynamic>) consider(n);
            }
          }
        }
      }

      final matched = best;
      if (matched != null && bestScore > 0) {
        return matched['_id']?.toString();
      }
    }
    return null;
  }

  /// Yüksək skor = daha dəqiq uyğunluq.
  int _outfitRoleMatchScore(String role, Map<String, dynamic> node) {
    final slug = node['slug']?.toString().toLowerCase() ?? '';
    final name = node['name']?.toString().toLowerCase() ?? '';
    final hay = '$slug $name';

    switch (role) {
      case 'shoes':
        if (hay.contains('ziyafet') || hay.contains('gelinlik')) return 0;
        if (slug.contains('ayaqqabi') || name.contains('ayaqqabi')) return 3;
        if (hay.contains('ayaq') || hay.contains('shoe')) return 1;
        return 0;
      case 'bag':
        if (hay.contains('ziyafet')) return 0;
        if (slug.contains('cantalar') || name.contains('çanta')) return 3;
        if (hay.contains('cant') || hay.contains('bag')) return 1;
        return 0;
      case 'outerwear':
      case 'jacket':
        if (hay.contains('aktiv')) return 0;
        if (hay.contains('jaket') ||
            hay.contains('ceket') ||
            hay.contains('palto') ||
            hay.contains('outer')) {
          return 4;
        }
        if (slug.endsWith('-geyim') || slug == 'geyim' || name == 'geyim') {
          return 2;
        }
        return 0;
      case 'tops':
      case 'top':
        if (hay.contains('aktiv')) return 0;
        if (hay.contains('kofta') ||
            hay.contains('bluz') ||
            hay.contains('top') ||
            hay.contains('köynək') ||
            hay.contains('koynək')) {
          return 4;
        }
        if (slug.endsWith('-geyim') || slug == 'geyim' || name == 'geyim') {
          return 2;
        }
        return 0;
      case 'full-body':
      case 'dress':
        if (hay.contains('aktiv')) return 0;
        if (hay.contains('don') || hay.contains('dress') || hay.contains('tulum')) {
          return 4;
        }
        if (slug.endsWith('-geyim') || slug == 'geyim' || name == 'geyim') {
          return 2;
        }
        return 0;
      case 'bottoms':
      case 'pants':
        if (hay.contains('aktiv')) return 0;
        if (hay.contains('şalvar') ||
            hay.contains('salvar') ||
            hay.contains('pantolon') ||
            hay.contains('jeans') ||
            hay.contains('ətək') ||
            hay.contains('etek')) {
          return 4;
        }
        if (slug.endsWith('-geyim') || slug == 'geyim' || name == 'geyim') {
          return 2;
        }
        return 0;
      default:
        if (slug.endsWith('-geyim') || slug == 'geyim') return 1;
        return 0;
    }
  }

  /// Donlar / Toplar və s. üçün API kateqoriya ID-si.
  Future<String?> findCategoryIdForHomeLabel(
    String label, {
    int genderIndex = 0,
  }) async {
    for (final gi in [genderIndex, 0, 1, 2]) {
      final genderNode = await _findGenderNode(TarzGenderConfig.idForIndex(gi));
      if (genderNode == null) continue;

      final children = genderNode['children'];
      if (children is! List) continue;

      for (final child in children) {
        if (child is! Map<String, dynamic>) continue;
        if (_isBrandsNode(child)) continue;
        if (_matchesHomeLabel(label, child)) {
          return child['_id']?.toString();
        }
      }
    }
    return null;
  }

  Future<void> _fillHomeCategorySlots(
    int genderIndex,
    List<String?> apiBySlot,
  ) async {
    final genderNode =
        await _findGenderNode(TarzGenderConfig.idForIndex(genderIndex));
    if (genderNode == null) return;

    final children = genderNode['children'];
    if (children is! List) return;

    for (final child in children) {
      if (child is! Map<String, dynamic>) continue;
      final id = child['_id']?.toString();
      if (id == null || id.isEmpty || _isBrandsNode(child)) continue;

      final slot = _homeCategorySlot(child);
      if (slot == null || apiBySlot[slot] != null) continue;
      apiBySlot[slot] = id;
    }
  }

  int? _homeCategorySlot(Map<String, dynamic> node) {
    final slug = node['slug']?.toString().toLowerCase() ?? '';
    final name = node['name']?.toString().toLowerCase() ?? '';
    final hay = '$slug $name';

    if (hay.contains('don') || hay.contains('dress')) return 0;
    if (hay.contains('ayaq') || hay.contains('shoe')) return 1;
    if (hay.contains('top') ||
        hay.contains('köyn') ||
        hay.contains('koyn') ||
        hay.contains('bluz')) {
      return 2;
    }
    if (hay.contains('çant') || hay.contains('cant') || hay.contains('bag')) {
      return 3;
    }
    return null;
  }

  bool _matchesHomeLabel(String label, Map<String, dynamic> node) {
    final slot = _homeCategorySlot(node);
    if (slot == null) return false;

    const labelBySlot = ['Donlar', 'Ayaqqabılar', 'Toplar', 'Çantalar'];
    if (slot < labelBySlot.length && labelBySlot[slot] == label) return true;

    final slug = node['slug']?.toString().toLowerCase() ?? '';
    final name = node['name']?.toString().toLowerCase() ?? '';
    final hay = '$slug $name';
    final needle = label.toLowerCase();
    return hay.contains(needle) || needle.contains(name);
  }

  Future<Map<String, dynamic>?> _findGenderNode(String genderId) async {
    final tree = await _loadTree();
    for (final node in tree) {
      if (node['_id']?.toString() == genderId) return node;
    }
    return null;
  }

  Future<Map<String, dynamic>?> _findNodeById(String id) async {
    final tree = await _loadTree();
    return _searchNode(tree, id);
  }

  Map<String, dynamic>? _searchNode(List<Map<String, dynamic>> nodes, String id) {
    for (final node in nodes) {
      if (node['_id']?.toString() == id) return node;
      final children = node['children'];
      if (children is List) {
        final childMaps = children.whereType<Map<String, dynamic>>().toList();
        final found = _searchNode(childMaps, id);
        if (found != null) return found;
      }
    }
    return null;
  }

  void _collectDescendantIds(Map<String, dynamic> node, Set<String> ids) {
    final children = node['children'];
    if (children is! List) return;
    for (final child in children) {
      if (child is! Map<String, dynamic>) continue;
      final id = child['_id']?.toString();
      if (id == null || id.isEmpty) continue;
      ids.add(id);
      _collectDescendantIds(child, ids);
    }
  }

  List<PlpCategoryOption> _childrenAsOptions(Map<String, dynamic> node) {
    final children = node['children'];
    if (children is! List) return const [];

    return children
        .whereType<Map<String, dynamic>>()
        .map(_optionFromNode)
        .whereType<PlpCategoryOption>()
        .where((o) => !_isBrandsName(o.name))
        .toList();
  }

  PlpCategoryOption? _optionFromNode(Map<String, dynamic> node) {
    final id = node['_id']?.toString();
    final name = node['name']?.toString() ?? '';
    if (id == null || id.isEmpty || name.isEmpty) return null;
    return PlpCategoryOption(id: id, name: name);
  }

  bool _isBrandsNode(Map<String, dynamic> node) {
    final slug = node['slug']?.toString().toLowerCase() ?? '';
    final name = node['name']?.toString().toLowerCase() ?? '';
    return slug.contains('brend') || name.contains('brend');
  }

  bool _isBrandsName(String name) =>
      name.toLowerCase().contains('brend');

  /// Startup — kateqoriya ağacını əvvəlcədən cache-ə yükləyir.
  Future<void> warmCache() async {
    try {
      await _loadTree();
    } catch (_) {
      // Home fallback-ləri ilə davam edir.
    }
  }

  Future<List<Map<String, dynamic>>> _loadTree() async {
    if (_sharedCache != null) return _sharedCache!;
    _sharedLoad ??= _fetchTree();
    try {
      return await _sharedLoad!;
    } catch (_) {
      _sharedLoad = null;
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTree() async {
    final body = await _client.get('/categories');
    final raw = body['data'] ?? body['categories'] ?? body;
    if (raw is! List) {
      _sharedCache = const [];
      return _sharedCache!;
    }
    _sharedCache = raw.whereType<Map<String, dynamic>>().toList();
    return _sharedCache!;
  }

  List<PlpCategoryOption> _fallbackCatalogue() => const [
        PlpCategoryOption(id: 'geyim', name: 'Geyim'),
        PlpCategoryOption(id: 'ayaqqabi', name: 'Ayaqqabı'),
        PlpCategoryOption(id: 'cantalar', name: 'Çantalar'),
        PlpCategoryOption(id: PlpSpecialCategory.discounts, name: 'Endirimlər'),
        PlpCategoryOption(id: PlpSpecialCategory.brands, name: 'Brendlər'),
      ];

  void dispose() {
    if (_isShared) return;
    if (_ownsClient) _client.dispose();
  }
}

enum _KidsBlockKind { korpe, oglan, qiz }

/// Məhsulun kateqoriya / cins filtri.
abstract final class ProductCategoryFilter {
  static bool matchesScope(TarzProductPreview product, Set<String> scope) {
    if (scope.isEmpty) return true;
    final categoryId = product.categoryId;
    final subcategoryId = product.subcategoryId;
    if (categoryId != null && scope.contains(categoryId)) return true;
    if (subcategoryId != null && scope.contains(subcategoryId)) return true;
    return false;
  }

  static bool matchesGender(TarzProductPreview product, String genderId) {
    final productGender = product.genderId;
    if (productGender == null || productGender.isEmpty) return true;
    return productGender == genderId;
  }
}

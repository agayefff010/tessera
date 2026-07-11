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
  CategoryRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;
  List<Map<String, dynamic>>? _cache;

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

  /// Uşaq kataloqu blokları — API ağacından.
  Future<List<TarzChildrenCatalogueBlock>> fetchKidsCatalogueBlocks() async {
    const presets = [
      (
        backgroundColor: Color(0xFFE8F5E9),
        imageAsset: TarzCatalogueAssets.childrenOglanlar,
        imageOnLeft: true,
        fullWidthBanner: false,
      ),
      (
        backgroundColor: Color(0xFFE3F2FD),
        imageAsset: TarzCatalogueAssets.childrenQizlar,
        imageOnLeft: false,
        fullWidthBanner: false,
      ),
      (
        backgroundColor: Color(0xFFFFF3E0),
        imageAsset: TarzCatalogueAssets.childrenKorpeler,
        imageOnLeft: true,
        fullWidthBanner: false,
      ),
    ];

    final genderId = TarzGenderConfig.idForIndex(2);
    final genderNode = await _findGenderNode(genderId);
    if (genderNode == null) return const [];

    final children = genderNode['children'];
    if (children is! List) return const [];

    final blocks = <TarzChildrenCatalogueBlock>[];
    var visualIndex = 0;
    for (final child in children) {
      if (child is! Map<String, dynamic>) continue;
      if (_isBrandsNode(child)) continue;

      final id = child['_id']?.toString();
      final name = child['name']?.toString() ?? '';
      if (id == null || id.isEmpty || name.isEmpty) continue;

      final subs = _childrenAsOptions(child);
      final preset = presets[visualIndex % presets.length];
      blocks.add(
        TarzChildrenCatalogueBlock(
          categoryId: id,
          title: name,
          subcategories: subs,
          backgroundColor: preset.backgroundColor,
          imageAsset: preset.imageAsset,
          imageOnLeft: preset.imageOnLeft,
          fullWidthBanner: preset.fullWidthBanner,
        ),
      );
      visualIndex++;
    }

    if (blocks.length > 3) {
      return blocks.sublist(blocks.length - 3);
    }
    return blocks;
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

  Future<List<Map<String, dynamic>>> _loadTree() async {
    if (_cache != null) return _cache!;
    final body = await _client.get('/categories');
    final raw = body['data'] ?? body['categories'] ?? body;
    if (raw is! List) {
      _cache = const [];
      return _cache!;
    }
    _cache = raw.whereType<Map<String, dynamic>>().toList();
    return _cache!;
  }

  List<PlpCategoryOption> _fallbackCatalogue() => const [
        PlpCategoryOption(id: 'geyim', name: 'Geyim'),
        PlpCategoryOption(id: 'ayaqqabi', name: 'Ayaqqabı'),
        PlpCategoryOption(id: 'cantalar', name: 'Çantalar'),
        PlpCategoryOption(id: PlpSpecialCategory.discounts, name: 'Endirimlər'),
        PlpCategoryOption(id: PlpSpecialCategory.brands, name: 'Brendlər'),
      ];

  void dispose() => _client.dispose();
}

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

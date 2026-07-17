import 'package:flutter/foundation.dart';

import '../data/outfit_service.dart';
import '../models/tarz_outfit.dart';

/// Kombinlərim — `GET /outfits/me` + `POST /outfits`.
class TarzOutfitsController extends ChangeNotifier {
  TarzOutfitsController._();

  static final TarzOutfitsController instance = TarzOutfitsController._();

  final OutfitService _service = OutfitService();

  final List<TarzSavedOutfit> _outfits = [];
  bool _initialized = false;
  bool _loading = false;
  bool _saving = false;

  List<TarzSavedOutfit> get outfits => List.unmodifiable(_outfits);
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  bool get isEmpty => _outfits.isEmpty;

  Future<void> ensureLoaded() async {
    if (_initialized) return;
    await reload();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    try {
      final remote = await _service.fetchMyOutfits();
      _outfits
        ..clear()
        ..addAll(remote);
      _initialized = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<TarzSavedOutfit> saveGenerated(
    TarzGeneratedOutfit outfit, {
    String? name,
  }) async {
    _saving = true;
    notifyListeners();
    try {
      final saved = await _service.saveOutfit(outfit, name: name);
      if (saved != null) {
        _outfits.removeWhere((o) => o.id == saved.id);
        _outfits.insert(0, saved);
        notifyListeners();
        return saved;
      }
      await reload();
      if (_outfits.isNotEmpty) return _outfits.first;
      throw StateError('Kombin saxlanılmadı');
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> deleteOutfit(TarzSavedOutfit outfit) async {
    await _service.deleteOutfit(outfit.id);
    _outfits.removeWhere((o) => o.id == outfit.id);
    notifyListeners();
  }

  Future<TarzSavedOutfit> generateAiImage(TarzSavedOutfit outfit) async {
    final updated = await _service.generateAiImage(outfit);
    final index = _outfits.indexWhere((o) => o.id == outfit.id);
    if (index >= 0) {
      _outfits[index] = updated;
    } else {
      _outfits.insert(0, updated);
    }
    notifyListeners();
    return updated;
  }
}

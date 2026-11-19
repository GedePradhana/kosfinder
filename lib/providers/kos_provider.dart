import 'package:flutter/foundation.dart';
import '../models/kos_model.dart';
import '../repositories/kos_repository.dart';

enum KosState { initial, loading, loaded, error }

class KosProvider extends ChangeNotifier {
  final KosRepository repository;

  KosProvider({required this.repository});

  KosState _state = KosState.initial;
  List<KosModel> _rawKosList = [];
  String? _errorMessage;
  String _searchQuery = '';
  int? _minPrice;
  int? _maxPrice;

  KosState get state => _state;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int? get minPrice => _minPrice;
  int? get maxPrice => _maxPrice;

  bool get isLoading => _state == KosState.loading;
  bool get hasError => _state == KosState.error;
  bool get isSearching => _searchQuery.trim().isNotEmpty;
  bool get isFilteredByPrice => _minPrice != null || _maxPrice != null;

  /// Daftar kos yang sudah melalui filter harga (jika aktif)
  List<KosModel> get kosList {
    if (!isFilteredByPrice) {
      return List.unmodifiable(_rawKosList);
    }

    final filtered = _rawKosList.where((kos) {
      if (_minPrice != null && kos.pricePerMonth < _minPrice!) {
        return false;
      }
      if (_maxPrice != null && kos.pricePerMonth > _maxPrice!) {
        return false;
      }
      return true;
    }).toList();

    return List.unmodifiable(filtered);
  }

  bool get isEmpty => _state == KosState.loaded && kosList.isEmpty;

  /// Memuat daftar kos publik dengan dukungan pencarian
  Future<void> fetchPublicKos({String? searchQuery}) async {
    _state = KosState.loading;
    _errorMessage = null;
    if (searchQuery != null) {
      _searchQuery = searchQuery;
    }
    notifyListeners();

    try {
      final result = await repository.getPublicKosList(
        searchQuery: _searchQuery,
      );
      _rawKosList = result;
      _state = KosState.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat data kos. Silakan periksa koneksi internet Anda.';
      _state = KosState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Memperbarui kata kunci pencarian dan memuat ulang data
  Future<void> search(String query) async {
    _searchQuery = query;
    await fetchPublicKos(searchQuery: query);
  }

  /// Menghapus kata kunci pencarian dan memuat ulang seluruh daftar
  Future<void> clearSearch() async {
    _searchQuery = '';
    await fetchPublicKos(searchQuery: '');
  }

  /// Menerapkan filter harga (US04-AC1 & US04-AC2)
  void setPriceFilter({int? minPrice, int? maxPrice}) {
    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      throw ArgumentError('Harga minimum tidak boleh lebih besar dari harga maksimum');
    }
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    notifyListeners();
  }

  /// Menghapus filter harga
  void clearPriceFilter() {
    _minPrice = null;
    _maxPrice = null;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import '../models/kos_model.dart';
import '../repositories/kos_repository.dart';

enum KosState { initial, loading, loaded, error }

class KosProvider extends ChangeNotifier {
  final KosRepository repository;

  KosProvider({required this.repository});

  KosState _state = KosState.initial;
  List<KosModel> _kosList = [];
  String? _errorMessage;
  String _searchQuery = '';

  KosState get state => _state;
  List<KosModel> get kosList => List.unmodifiable(_kosList);
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  bool get isLoading => _state == KosState.loading;
  bool get isEmpty => _state == KosState.loaded && _kosList.isEmpty;
  bool get hasError => _state == KosState.error;
  bool get isSearching => _searchQuery.trim().isNotEmpty;

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
      _kosList = result;
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
}

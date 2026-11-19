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

  KosState get state => _state;
  List<KosModel> get kosList => List.unmodifiable(_kosList);
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == KosState.loading;
  bool get isEmpty => _state == KosState.loaded && _kosList.isEmpty;
  bool get hasError => _state == KosState.error;

  /// Memuat daftar kos publik urut terbaru
  Future<void> fetchPublicKos() async {
    _state = KosState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.getPublicKosList();
      _kosList = result;
      _state = KosState.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat data kos. Silakan periksa koneksi internet Anda.';
      _state = KosState.error;
    } finally {
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import '../models/kos_model.dart';
import '../repositories/owner_kos_repository.dart';

enum OwnerKosState { initial, loading, loaded, error }

class OwnerKosProvider extends ChangeNotifier {
  final OwnerKosRepository repository;

  OwnerKosProvider({required this.repository});

  OwnerKosState _state = OwnerKosState.initial;
  List<KosModel> _myKosList = [];
  String? _errorMessage;

  OwnerKosState get state => _state;
  List<KosModel> get myKosList => List.unmodifiable(_myKosList);
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == OwnerKosState.loading;
  bool get isEmpty => _state == OwnerKosState.loaded && _myKosList.isEmpty;
  bool get hasError => _state == OwnerKosState.error;

  /// Memuat daftar kos milik pemilik yang login
  Future<void> fetchMyKos() async {
    _state = OwnerKosState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.getMyKosList();
      _myKosList = result;
      _state = OwnerKosState.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat daftar kos Anda. Silakan coba lagi.';
      _state = OwnerKosState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Menambahkan kos baru (US06-AC1)
  Future<bool> addKos(KosModel kos) async {
    _state = OwnerKosState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final newKos = await repository.insertKos(kos);
      _myKosList.insert(0, newKos);
      _state = OwnerKosState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan data kos baru.';
      _state = OwnerKosState.error;
      notifyListeners();
      return false;
    }
  }

  /// Mengubah data kos milik sendiri (US07-AC1)
  Future<bool> editKos(KosModel kos) async {
    _state = OwnerKosState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedKos = await repository.updateKos(kos);
      if (updatedKos != null) {
        final index = _myKosList.indexWhere((item) => item.id == kos.id);
        if (index != -1) {
          _myKosList[index] = updatedKos;
        }
        _state = OwnerKosState.loaded;
        notifyListeners();
        return true;
      } else {
        // RLS Supabase: data tidak berubah karena bukan pemilik data
        _errorMessage = 'Perubahan ditolak. Anda hanya dapat mengubah kos milik Anda.';
        _state = OwnerKosState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Gagal memperbarui data kos.';
      _state = OwnerKosState.error;
      notifyListeners();
      return false;
    }
  }

  /// Menghapus data kos milik sendiri (US07-AC1, US07-AC2)
  Future<bool> removeKos(String kosId) async {
    _state = OwnerKosState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await repository.deleteKos(kosId);
      if (success) {
        _myKosList.removeWhere((item) => item.id == kosId);
        _state = OwnerKosState.loaded;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Penghapusan ditolak. Anda hanya dapat menghapus kos milik Anda.';
        _state = OwnerKosState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Gagal menghapus data kos.';
      _state = OwnerKosState.error;
      notifyListeners();
      return false;
    }
  }

  /// Mengubah status ketersediaan (US08-AC1, US08-AC2)
  Future<bool> toggleAvailability(String kosId, bool currentStatus) async {
    final newStatus = !currentStatus;
    _errorMessage = null;

    try {
      final updated = await repository.updateAvailability(kosId, newStatus);
      if (updated != null) {
        final index = _myKosList.indexWhere((item) => item.id == kosId);
        if (index != -1) {
          _myKosList[index] = updated;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      // US08-AC2: Saat koneksi putus, tampil pesan error & status tidak berubah
      _errorMessage = 'Gagal mengubah status ketersediaan. Periksa koneksi internet Anda.';
      notifyListeners();
      return false;
    }
  }
}

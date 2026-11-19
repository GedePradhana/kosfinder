import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AuthProvider({required this.repository}) {
    _checkInitialAuth();
  }

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AuthStatus.authenticating;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;

  void _checkInitialAuth() {
    _user = repository.currentUser;
    _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  /// Registrasi akun pemilik baru (US05-AC1, US05-AC2)
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.signUp(email: email, password: password);
      _user = response.user ?? repository.currentUser;
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
      return _status == AuthStatus.authenticated;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan jaringan atau server saat pendaftaran.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Login pemilik kos (US05-AC3, US05-AC4)
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await repository.signIn(email: email, password: password);
      _user = response.user ?? repository.currentUser;
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
      return _status == AuthStatus.authenticated;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan jaringan saat proses login.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Logout pemilik kos
  Future<void> logout() async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (_) {
      _user = null;
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  /// Reset pesan error
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    }
  }
}

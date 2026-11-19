import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kos_model.dart';

class OwnerKosRepository {
  final SupabaseClient? client;

  OwnerKosRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  String get _currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw StateError('Pengguna belum terautentikasi');
    }
    return user.id;
  }

  /// Mengambil daftar kos yang HANYA dimiliki oleh pemilik yang sedang login
  Future<List<KosModel>> getMyKosList() async {
    final response = await _supabase
        .from('kos')
        .select()
        .eq('owner_id', _currentUserId)
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;
    return data
        .map((item) => KosModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Menambahkan kos baru milik pemilik yang sedang login (US06-AC1)
  Future<KosModel> insertKos(KosModel kos) async {
    final userId = _currentUserId;
    final kosMap = kos.toJson(includeId: false);
    // Pastikan owner_id selalu terisi dengan auth.uid()
    kosMap['owner_id'] = userId;

    final response = await _supabase
        .from('kos')
        .insert(kosMap)
        .select()
        .single();

    return KosModel.fromJson(response);
  }

  /// Mengubah data kos milik pemilik yang sedang login (US07-AC1)
  /// Terlindungi oleh RLS: data tidak berubah jika bukan pemilik data
  Future<KosModel?> updateKos(KosModel kos) async {
    final userId = _currentUserId;
    final kosMap = kos.toJson(includeId: false);
    kosMap['owner_id'] = userId;

    final response = await _supabase
        .from('kos')
        .update(kosMap)
        .eq('id', kos.id)
        .eq('owner_id', userId)
        .select()
        .maybeSingle();

    if (response == null) return null;
    return KosModel.fromJson(response);
  }

  /// Menghapus data kos milik pemilik yang sedang login (US07-AC1, US07-AC2)
  Future<bool> deleteKos(String kosId) async {
    final userId = _currentUserId;

    final response = await _supabase
        .from('kos')
        .delete()
        .eq('id', kosId)
        .eq('owner_id', userId)
        .select();

    final data = response as List<dynamic>;
    return data.isNotEmpty;
  }

  /// Mengubah status ketersediaan kos (Tersedia / Penuh) (US08-AC1, US08-AC2)
  Future<KosModel?> updateAvailability(String kosId, bool isAvailable) async {
    final userId = _currentUserId;

    final response = await _supabase
        .from('kos')
        .update({'is_available': isAvailable})
        .eq('id', kosId)
        .eq('owner_id', userId)
        .select()
        .maybeSingle();

    if (response == null) return null;
    return KosModel.fromJson(response);
  }
}

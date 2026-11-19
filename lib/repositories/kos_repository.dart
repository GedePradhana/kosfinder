import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kos_model.dart';

class KosRepository {
  final SupabaseClient? client;

  KosRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  /// Mengambil seluruh daftar kos publik, diurutkan dari yang terbaru (created_at DESC).
  Future<List<KosModel>> getPublicKosList() async {
    final response = await _supabase
        .from('kos')
        .select()
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;
    return data
        .map((item) => KosModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Mengambil detail satu kos berdasarkan ID
  Future<KosModel?> getKosDetail(String id) async {
    final response = await _supabase
        .from('kos')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return KosModel.fromJson(response);
  }
}

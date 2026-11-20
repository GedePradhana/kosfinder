import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kos_model.dart';

class KosRepository {
  final SupabaseClient? client;

  KosRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  /// Mengambil seluruh daftar kos publik, diurutkan dari yang terbaru (created_at DESC).
  /// Sesuai NFR Privasi PRD: hanya memuat kolom yang dibutuhkan daftar publik,
  /// nomor WhatsApp (whatsapp_number) TIDAK dimuat pada daftar publik.
  /// Dapat memfilter berdasarkan kata kunci pencarian (nama atau alamat).
  Future<List<KosModel>> getPublicKosList({String? searchQuery}) async {
    // Hanya memilih kolom yang dibutuhkan daftar publik (eksklusif tanpa whatsapp_number)
    const publicColumns = 'id,owner_id,name,address,price_per_month,type,facilities,description,available_rooms,is_available,created_at,updated_at';
    var query = _supabase.from('kos').select(publicColumns);

    final trimmed = searchQuery?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      // Pencarian case-insensitive pada kolom name ATAU address
      query = query.or('name.ilike.%$trimmed%,address.ilike.%$trimmed%');
    }

    final response = await query.order('created_at', ascending: false);

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

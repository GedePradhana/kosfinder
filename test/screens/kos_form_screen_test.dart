import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/repositories/owner_kos_repository.dart';
import 'package:kosfinder/screens/owner/kos_form_screen.dart';
import 'package:provider/provider.dart';

// ─── Fake Repository ──────────────────────────────────────────────────────────

class FakeOwnerKosRepository extends OwnerKosRepository {
  bool addKosSuccess = true;
  bool updateKosSuccess = true;
  KosModel? lastAddedKos;
  KosModel? lastUpdatedKos;

  @override
  Future<List<KosModel>> getMyKosList() async => [];

  @override
  Future<KosModel> insertKos(KosModel kos) async {
    if (!addKosSuccess) throw Exception('Gagal menambahkan kos');
    lastAddedKos = kos;
    return kos.copyWith(id: 'new-kos-id-123');
  }

  @override
  Future<KosModel?> updateKos(KosModel kos) async {
    if (!updateKosSuccess) return null; // simulasi RLS menolak
    lastUpdatedKos = kos;
    return kos;
  }

  @override
  Future<bool> deleteKos(String id) async => true;

  @override
  Future<KosModel?> updateAvailability(String kosId, bool isAvailable) async => null;
}

// ─── Helper ───────────────────────────────────────────────────────────────────

Widget createTestWidget({
  required OwnerKosProvider provider,
  KosModel? initialKos,
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<OwnerKosProvider>.value(
      value: provider,
      child: KosFormScreen(initialKos: initialKos),
    ),
  );
}

// Data contoh untuk mode Edit
final KosModel sampleKos = KosModel(
  id: 'kos-edit-001',
  ownerId: 'owner-abc',
  name: 'Kos Anggrek Lama',
  address: 'Jl. Lama No. 7, Denpasar',
  pricePerMonth: 500000,
  type: 'putri',
  facilities: const ['AC', 'WiFi'],
  description: 'Deskripsi lama kos.',
  availableRooms: 2,
  whatsappNumber: '081111111111',
  isAvailable: true,
);

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('KosFormScreen Tests', () {
    late FakeOwnerKosRepository fakeRepository;
    late OwnerKosProvider ownerKosProvider;

    setUp(() {
      fakeRepository = FakeOwnerKosRepository();
      ownerKosProvider = OwnerKosProvider(repository: fakeRepository);
    });

    // ── T12: Mode Tambah ──────────────────────────────────────────────────

    testWidgets('Menampilkan judul dan elemen form mode tambah', (tester) async {
      await tester.pumpWidget(createTestWidget(provider: ownerKosProvider));

      expect(find.text('Tambah Kos Baru'), findsOneWidget);
      expect(find.text('Simpan Kos'), findsOneWidget);
      expect(find.text('Nama Kos *'), findsOneWidget);
      expect(find.text('Alamat Lengkap *'), findsOneWidget);
      expect(find.text('Harga per Bulan (Rp) *'), findsOneWidget);
      expect(find.text('Jenis Kos *'), findsOneWidget);
      expect(find.text('Fasilitas Kos (Pilihan Checklist) *'), findsOneWidget);
      expect(find.text('Jumlah Kamar Tersedia *'), findsOneWidget);
      expect(find.text('Nomor WhatsApp Pemilik *'), findsOneWidget);
      expect(find.text('Deskripsi Kos *'), findsOneWidget);
    });

    testWidgets('US06-AC2: Menampilkan pesan error validasi saat form disubmit dalam keadaan kosong', (tester) async {
      await tester.pumpWidget(createTestWidget(provider: ownerKosProvider));

      final simpanButton = find.text('Simpan Kos');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();

      expect(find.text('Nama kos wajib diisi'), findsOneWidget);
      expect(find.text('Alamat lengkap wajib diisi'), findsOneWidget);
      expect(find.text('Harga per bulan wajib diisi'), findsOneWidget);
      expect(find.text('Pilih minimal satu fasilitas kos'), findsOneWidget);
      expect(find.text('Jumlah kamar tersedia wajib diisi'), findsOneWidget);
      expect(find.text('Nomor WhatsApp wajib diisi'), findsOneWidget);
      expect(find.text('Deskripsi kos wajib diisi'), findsOneWidget);

      expect(fakeRepository.lastAddedKos, isNull);
    });

    testWidgets('US06-AC2: Nomor WhatsApp hanya menerima angka dan minimal 9 digit', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(provider: ownerKosProvider));

      await tester.enterText(find.widgetWithText(TextFormField, 'Nama Kos *'), 'Kos Angka');
      await tester.enterText(find.widgetWithText(TextFormField, 'Alamat Lengkap *'), 'Jl. Angka No. 1');
      await tester.enterText(find.widgetWithText(TextFormField, 'Harga per Bulan (Rp) *'), '500000');

      final acCheckbox = find.widgetWithText(CheckboxListTile, 'AC');
      await tester.ensureVisible(acCheckbox);
      await tester.tap(acCheckbox);

      final roomsField = find.widgetWithText(TextFormField, 'Jumlah Kamar Tersedia *');
      await tester.ensureVisible(roomsField);
      await tester.enterText(roomsField, '1');

      final descField = find.widgetWithText(TextFormField, 'Deskripsi Kos *');
      await tester.ensureVisible(descField);
      await tester.enterText(descField, 'Deskripsi kos.');

      final waField = find.widgetWithText(TextFormField, 'Nomor WhatsApp Pemilik *');
      await tester.ensureVisible(waField);

      // Coba masukkan kurang dari 9 digit
      await tester.enterText(waField, '08123');
      final simpanButton = find.text('Simpan Kos');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();

      expect(find.text('Nomor WhatsApp minimal 9 digit'), findsOneWidget);

      // Verifikasi input formatter menolak karakter non-digit (misal saat paste atau ketik teks)
      await tester.enterText(waField, '081234abc5678');
      // Karena FilteringTextInputFormatter.digitsOnly, teks 'abc' tereliminasi
      expect((tester.widget(waField) as TextFormField).controller?.text, '0812345678');

      // Submit kembali setelah format valid
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();
      expect(fakeRepository.lastAddedKos?.whatsappNumber, '0812345678');
    });

    testWidgets('US06-AC1: Berhasil menyimpan data kos baru saat semua 8 field wajib terisi', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(provider: ownerKosProvider));

      await tester.enterText(find.widgetWithText(TextFormField, 'Nama Kos *'), 'Kos Melati Nyaman');
      await tester.enterText(find.widgetWithText(TextFormField, 'Alamat Lengkap *'), 'Jl. Mawar No. 15, Singaraja');
      await tester.enterText(find.widgetWithText(TextFormField, 'Harga per Bulan (Rp) *'), '750000');

      final acCheckbox = find.widgetWithText(CheckboxListTile, 'AC');
      await tester.ensureVisible(acCheckbox);
      await tester.tap(acCheckbox);

      final wifiCheckbox = find.widgetWithText(CheckboxListTile, 'WiFi');
      await tester.ensureVisible(wifiCheckbox);
      await tester.tap(wifiCheckbox);

      final roomsField = find.widgetWithText(TextFormField, 'Jumlah Kamar Tersedia *');
      await tester.ensureVisible(roomsField);
      await tester.enterText(roomsField, '4');

      final waField = find.widgetWithText(TextFormField, 'Nomor WhatsApp Pemilik *');
      await tester.ensureVisible(waField);
      await tester.enterText(waField, '081234567890');

      final descField = find.widgetWithText(TextFormField, 'Deskripsi Kos *');
      await tester.ensureVisible(descField);
      await tester.enterText(descField, 'Kos nyaman, bersih, dekat kampus.');

      final simpanButton = find.text('Simpan Kos');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pump();

      expect(find.text('Kos berhasil ditambahkan!'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(fakeRepository.lastAddedKos, isNotNull);
      expect(fakeRepository.lastAddedKos!.name, 'Kos Melati Nyaman');
      expect(fakeRepository.lastAddedKos!.address, 'Jl. Mawar No. 15, Singaraja');
      expect(fakeRepository.lastAddedKos!.pricePerMonth, 750000);
      expect(fakeRepository.lastAddedKos!.facilities, containsAll(['AC', 'WiFi']));
      expect(fakeRepository.lastAddedKos!.availableRooms, 4);
      expect(fakeRepository.lastAddedKos!.whatsappNumber, '081234567890');
      expect(fakeRepository.lastAddedKos!.description, 'Kos nyaman, bersih, dekat kampus.');
    });

    // ── T13: Mode Edit ────────────────────────────────────────────────────

    testWidgets('T13 / US07-AC1: Mode Edit menampilkan judul "Ubah Data Kos" dan field ter-prefill', (tester) async {
      await tester.pumpWidget(createTestWidget(
        provider: ownerKosProvider,
        initialKos: sampleKos,
      ));

      expect(find.text('Ubah Data Kos'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
      // Nilai lama harus sudah terisi
      expect(find.text('Kos Anggrek Lama'), findsOneWidget);
      expect(find.text('Jl. Lama No. 7, Denpasar'), findsOneWidget);
      expect(find.text('500000'), findsOneWidget);
      expect(find.text('081111111111'), findsOneWidget);
      expect(find.text('Deskripsi lama kos.'), findsOneWidget);
    });

    testWidgets('T13 / US07-AC1: Mode Edit berhasil menyimpan perubahan via provider.editKos', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(
        provider: ownerKosProvider,
        initialKos: sampleKos,
      ));

      // Ubah nama kos
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Kos *'),
        'Kos Anggrek Baru',
      );

      final simpanButton = find.text('Simpan Perubahan');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pump();

      // SnackBar sukses
      expect(find.text('Kos berhasil diperbarui!'), findsOneWidget);
      await tester.pumpAndSettle();

      // Verifikasi repository dipanggil dengan data yang benar
      expect(fakeRepository.lastUpdatedKos, isNotNull);
      expect(fakeRepository.lastUpdatedKos!.name, 'Kos Anggrek Baru');
      expect(fakeRepository.lastUpdatedKos!.id, 'kos-edit-001');
    });

    testWidgets('T13 / US07-AC1: RLS menolak update (bukan pemilik) menampilkan SnackBar error', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      fakeRepository.updateKosSuccess = false;

      await tester.pumpWidget(createTestWidget(
        provider: ownerKosProvider,
        initialKos: sampleKos,
      ));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Kos *'),
        'Kos Palsu',
      );

      final simpanButton = find.text('Simpan Perubahan');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();

      // SnackBar error harus muncul — pesan dari provider saat RLS tolak
      expect(find.textContaining('Perubahan ditolak'), findsAtLeast(1));
      // Data tidak disimpan ke repository
      expect(fakeRepository.lastUpdatedKos, isNull);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/repositories/owner_kos_repository.dart';
import 'package:kosfinder/screens/owner/kos_form_screen.dart';
import 'package:provider/provider.dart';

class FakeOwnerKosRepository extends OwnerKosRepository {
  bool addKosSuccess = true;
  KosModel? lastAddedKos;

  @override
  Future<List<KosModel>> getMyKosList() async {
    return [];
  }

  @override
  Future<KosModel> insertKos(KosModel kos) async {
    if (!addKosSuccess) {
      throw Exception('Gagal menambahkan kos');
    }
    lastAddedKos = kos;
    return kos.copyWith(id: 'new-kos-id-123');
  }

  @override
  Future<KosModel?> updateKos(KosModel kos) async {
    return kos;
  }

  @override
  Future<bool> deleteKos(String id) async {
    return true;
  }

  @override
  Future<KosModel?> updateAvailability(String kosId, bool isAvailable) async {
    return null;
  }
}

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

void main() {
  group('KosFormScreen Tests', () {
    late FakeOwnerKosRepository fakeRepository;
    late OwnerKosProvider ownerKosProvider;

    setUp(() {
      fakeRepository = FakeOwnerKosRepository();
      ownerKosProvider = OwnerKosProvider(repository: fakeRepository);
    });

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

      // Scroll ke tombol simpan dan klik
      final simpanButton = find.text('Simpan Kos');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();

      // Cek validasi muncul
      expect(find.text('Nama kos wajib diisi'), findsOneWidget);
      expect(find.text('Alamat lengkap wajib diisi'), findsOneWidget);
      expect(find.text('Harga per bulan wajib diisi'), findsOneWidget);
      expect(find.text('Pilih minimal satu fasilitas kos'), findsOneWidget);
      expect(find.text('Jumlah kamar tersedia wajib diisi'), findsOneWidget);
      expect(find.text('Nomor WhatsApp wajib diisi'), findsOneWidget);
      expect(find.text('Deskripsi kos wajib diisi'), findsOneWidget);

      // Pastikan repository tidak dipanggil
      expect(fakeRepository.lastAddedKos, isNull);
    });

    testWidgets('US06-AC1: Berhasil menyimpan data kos baru saat semua 8 field wajib terisi dengan benar', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(provider: ownerKosProvider));

      // Isi Nama Kos
      final nameField = find.widgetWithText(TextFormField, 'Nama Kos *');
      await tester.enterText(nameField, 'Kos Melati Nyaman');

      // Isi Alamat Lengkap
      final addressField = find.widgetWithText(TextFormField, 'Alamat Lengkap *');
      await tester.enterText(addressField, 'Jl. Mawar No. 15, Singaraja');

      // Isi Harga per Bulan
      final priceField = find.widgetWithText(TextFormField, 'Harga per Bulan (Rp) *');
      await tester.enterText(priceField, '750000');

      // Pilih Fasilitas: AC & WiFi
      final acCheckbox = find.widgetWithText(CheckboxListTile, 'AC');
      await tester.ensureVisible(acCheckbox);
      await tester.tap(acCheckbox);

      final wifiCheckbox = find.widgetWithText(CheckboxListTile, 'WiFi');
      await tester.ensureVisible(wifiCheckbox);
      await tester.tap(wifiCheckbox);

      // Isi Jumlah Kamar Tersedia
      final roomsField = find.widgetWithText(TextFormField, 'Jumlah Kamar Tersedia *');
      await tester.ensureVisible(roomsField);
      await tester.enterText(roomsField, '4');

      // Isi Nomor WhatsApp
      final waField = find.widgetWithText(TextFormField, 'Nomor WhatsApp Pemilik *');
      await tester.ensureVisible(waField);
      await tester.enterText(waField, '081234567890');

      // Isi Deskripsi
      final descField = find.widgetWithText(TextFormField, 'Deskripsi Kos *');
      await tester.ensureVisible(descField);
      await tester.enterText(descField, 'Kos nyaman, bersih, dekat kampus.');

      // Tap Simpan
      final simpanButton = find.text('Simpan Kos');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pump(); // trigger frame awal untuk SnackBar

      // Menampilkan SnackBar sukses
      expect(find.text('Kos berhasil ditambahkan!'), findsOneWidget);

      await tester.pumpAndSettle();

      // Verifikasi lastAddedKos
      expect(fakeRepository.lastAddedKos, isNotNull);
      expect(fakeRepository.lastAddedKos!.name, 'Kos Melati Nyaman');
      expect(fakeRepository.lastAddedKos!.address, 'Jl. Mawar No. 15, Singaraja');
      expect(fakeRepository.lastAddedKos!.pricePerMonth, 750000);
      expect(fakeRepository.lastAddedKos!.facilities, containsAll(['AC', 'WiFi']));
      expect(fakeRepository.lastAddedKos!.availableRooms, 4);
      expect(fakeRepository.lastAddedKos!.whatsappNumber, '081234567890');
      expect(fakeRepository.lastAddedKos!.description, 'Kos nyaman, bersih, dekat kampus.');
    });
  });
}

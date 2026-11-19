import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';

void main() {
  group('KosModel Unit Tests', () {
    test('fromJson harus mem-parse Map dengan benar', () {
      final json = <String, dynamic>{
        'id': 'kos-123',
        'owner_id': 'owner-456',
        'name': 'Kos Mawar Bahagia',
        'address': 'Jl. Melati No. 10, Singaraja',
        'price_per_month': 850000,
        'type': 'campur',
        'facilities': ['WiFi', 'AC', 'kamar mandi dalam'],
        'description': 'Kos nyaman dan strategis dekat kampus.',
        'available_rooms': 3,
        'whatsapp_number': '081234567890',
        'is_available': true,
        'created_at': '2026-11-19T10:00:00.000Z',
        'updated_at': '2026-11-19T10:00:00.000Z',
      };

      final model = KosModel.fromJson(json);

      expect(model.id, 'kos-123');
      expect(model.ownerId, 'owner-456');
      expect(model.name, 'Kos Mawar Bahagia');
      expect(model.address, 'Jl. Melati No. 10, Singaraja');
      expect(model.pricePerMonth, 850000);
      expect(model.type, 'campur');
      expect(model.facilities, containsAll(['WiFi', 'AC', 'kamar mandi dalam']));
      expect(model.availableRooms, 3);
      expect(model.whatsappNumber, '081234567890');
      expect(model.isAvailable, true);
      expect(model.createdAt, isNotNull);
    });

    test('toJson harus menghasilkan Map dengan struktur yang sesuai skema database', () {
      const model = KosModel(
        id: 'kos-1',
        ownerId: 'owner-1',
        name: 'Kos Melati',
        address: 'Jl. Ahmad Yani',
        pricePerMonth: 600000,
        type: 'putri',
        facilities: ['WiFi', 'parkir'],
        description: 'Dekat jalan raya',
        availableRooms: 1,
        whatsappNumber: '08987654321',
        isAvailable: false,
      );

      final map = model.toJson();

      expect(map['id'], 'kos-1');
      expect(map['owner_id'], 'owner-1');
      expect(map['name'], 'Kos Melati');
      expect(map['price_per_month'], 600000);
      expect(map['is_available'], false);
    });

    test('fromJson menangani data kosong/null dengan fallback nilai default yang aman', () {
      final json = <String, dynamic>{};
      final model = KosModel.fromJson(json);

      expect(model.id, '');
      expect(model.ownerId, '');
      expect(model.pricePerMonth, 0);
      expect(model.type, 'campur');
      expect(model.facilities, isEmpty);
      expect(model.isAvailable, true);
    });
  });
}

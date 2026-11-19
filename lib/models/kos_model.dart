class KosModel {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final int pricePerMonth;
  final String type; // 'putra', 'putri', 'campur'
  final List<String> facilities;
  final String description;
  final int availableRooms;
  final String whatsappNumber;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const KosModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.pricePerMonth,
    required this.type,
    required this.facilities,
    required this.description,
    required this.availableRooms,
    required this.whatsappNumber,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  factory KosModel.fromJson(Map<String, dynamic> json) {
    return KosModel(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      pricePerMonth: (json['price_per_month'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'campur',
      facilities: (json['facilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
      description: json['description'] as String? ?? '',
      availableRooms: (json['available_rooms'] as num?)?.toInt() ?? 0,
      whatsappNumber: json['whatsapp_number'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final map = <String, dynamic>{
      'owner_id': ownerId,
      'name': name,
      'address': address,
      'price_per_month': pricePerMonth,
      'type': type,
      'facilities': facilities,
      'description': description,
      'available_rooms': availableRooms,
      'whatsapp_number': whatsappNumber,
      'is_available': isAvailable,
    };
    if (includeId && id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  KosModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? address,
    int? pricePerMonth,
    String? type,
    List<String>? facilities,
    String? description,
    int? availableRooms,
    String? whatsappNumber,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KosModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      address: address ?? this.address,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      type: type ?? this.type,
      facilities: facilities ?? this.facilities,
      description: description ?? this.description,
      availableRooms: availableRooms ?? this.availableRooms,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

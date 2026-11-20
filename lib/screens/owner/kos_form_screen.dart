import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/kos_model.dart';
import '../../providers/owner_kos_provider.dart';

class KosFormScreen extends StatefulWidget {
  final KosModel? initialKos;

  const KosFormScreen({super.key, this.initialKos});

  bool get isEditMode => initialKos != null;

  @override
  State<KosFormScreen> createState() => _KosFormScreenState();
}

class _KosFormScreenState extends State<KosFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _availableRoomsController;
  late TextEditingController _whatsappController;

  String _selectedType = 'campur';
  final List<String> _selectedFacilities = [];

  // Daftar fasilitas tetap sesuai PRD
  static const List<String> availableFacilities = [
    'AC',
    'WiFi',
    'kamar mandi dalam',
    'parkir',
    'dapur bersama',
  ];

  String? _facilityValidationError;

  @override
  void initState() {
    super.initState();
    final kos = widget.initialKos;
    _nameController = TextEditingController(text: kos?.name ?? '');
    _addressController = TextEditingController(text: kos?.address ?? '');
    _priceController = TextEditingController(
      text: kos != null ? kos.pricePerMonth.toString() : '',
    );
    _descriptionController = TextEditingController(text: kos?.description ?? '');
    _availableRoomsController = TextEditingController(
      text: kos != null ? kos.availableRooms.toString() : '',
    );
    _whatsappController = TextEditingController(text: kos?.whatsappNumber ?? '');

    if (kos != null) {
      _selectedType = kos.type;
      _selectedFacilities.addAll(kos.facilities);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _availableRoomsController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    // Validasi checklist fasilitas (field wajib ke-4)
    setState(() {
      if (_selectedFacilities.isEmpty) {
        _facilityValidationError = 'Pilih minimal satu fasilitas kos';
      } else {
        _facilityValidationError = null;
      }
    });

    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid || _facilityValidationError != null) {
      // US06-AC2: Ada field wajib kosong -> data tidak disimpan
      return;
    }

    final provider = context.read<OwnerKosProvider>();
    final newKos = KosModel(
      id: widget.initialKos?.id ?? '',
      ownerId: widget.initialKos?.ownerId ?? '',
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      pricePerMonth: int.parse(_priceController.text.trim()),
      type: _selectedType,
      facilities: List.unmodifiable(_selectedFacilities),
      description: _descriptionController.text.trim(),
      availableRooms: int.parse(_availableRoomsController.text.trim()),
      whatsappNumber: _whatsappController.text.trim(),
      isAvailable: widget.initialKos?.isAvailable ?? true,
    );

    final bool success;
    if (widget.isEditMode) {
      success = await provider.editKos(newKos);
    } else {
      success = await provider.addKos(newKos);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode ? 'Kos berhasil diperbarui!' : 'Kos berhasil ditambahkan!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal menyimpan kos.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OwnerKosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Ubah Data Kos' : 'Tambah Kos Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Nama Kos
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Kos *',
                  hintText: 'Contoh: Kos Mawar Indah',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama kos wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. Alamat Lengkap
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap *',
                  hintText: 'Nama jalan, kelurahan, kecamatan, kota',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Alamat lengkap wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. Harga Sewa per Bulan
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga per Bulan (Rp) *',
                  prefixText: 'Rp ',
                  hintText: '850000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Harga per bulan wajib diisi';
                  }
                  final parsed = int.tryParse(val.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Harga harus berupa angka valid (>= 0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 4. Jenis Kos (Radio / Dropdown)
              const Text(
                'Jenis Kos *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'putra', label: Text('Putra')),
                  ButtonSegment(value: 'putri', label: Text('Putri')),
                  ButtonSegment(value: 'campur', label: Text('Campur')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 20),

              // 5. Fasilitas (Checklist Pilihan Tetap)
              const Text(
                'Fasilitas Kos (Pilihan Checklist) *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Card(
                elevation: 0,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: _facilityValidationError != null ? Colors.red : Colors.grey.shade300,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: availableFacilities.map((f) {
                      final isSelected = _selectedFacilities.contains(f);
                      return CheckboxListTile(
                        dense: true,
                        title: Text(f),
                        value: isSelected,
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedFacilities.add(f);
                              _facilityValidationError = null;
                            } else {
                              _selectedFacilities.remove(f);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (_facilityValidationError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _facilityValidationError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),

              // 6. Jumlah Kamar Tersedia
              TextFormField(
                controller: _availableRoomsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah Kamar Tersedia *',
                  hintText: 'Contoh: 3',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Jumlah kamar tersedia wajib diisi';
                  }
                  final parsed = int.tryParse(val.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Jumlah kamar harus angka valid (>= 0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 7. Nomor WhatsApp Pemilik
              TextFormField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: 'Nomor WhatsApp Pemilik *',
                  hintText: 'Contoh: 081234567890',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nomor WhatsApp wajib diisi';
                  }
                  final trimmed = val.trim();
                  if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
                    return 'Nomor WhatsApp hanya boleh berupa angka';
                  }
                  if (trimmed.length < 9) {
                    return 'Nomor WhatsApp minimal 9 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 8. Deskripsi Kos
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Kos *',
                  hintText: 'Jelaskan peraturan kos, keunggulan, atau lingkungan sekitar...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Deskripsi kos wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Tombol Simpan
              ElevatedButton.icon(
                onPressed: provider.isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: provider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  widget.isEditMode ? 'Simpan Perubahan' : 'Simpan Kos',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

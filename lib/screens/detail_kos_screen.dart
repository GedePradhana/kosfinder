import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/kos_model.dart';
import '../repositories/kos_repository.dart';

class DetailKosScreen extends StatefulWidget {
  final String kosId;
  final KosModel? initialKos;
  final KosRepository? repository;

  const DetailKosScreen({
    super.key,
    required this.kosId,
    this.initialKos,
    this.repository,
  });

  @override
  State<DetailKosScreen> createState() => _DetailKosScreenState();
}

class _DetailKosScreenState extends State<DetailKosScreen> {
  late KosRepository _repository;
  KosModel? _kos;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? KosRepository();
    if (widget.initialKos != null) {
      _kos = widget.initialKos;
    } else {
      _fetchDetail();
    }
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _repository.getKosDetail(widget.kosId);
      if (result == null) {
        setState(() {
          _errorMessage = 'Data kos tidak ditemukan.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _kos = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat detail kos. Silakan periksa koneksi internet Anda.';
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return '${formatter.format(amount)} / bulan';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _launchWhatsApp(String phone) async {
    // Normalisasi nomor telepon: jika berawalan 08xxx ubah ke format 628xxx
    var cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedPhone.startsWith('0')) {
      cleanedPhone = '62${cleanedPhone.substring(1)}';
    }

    final kosName = _kos?.name ?? 'Kos';
    final message = Uri.encodeComponent('Halo, saya tertarik dengan $kosName di KosFinder. Apakah masih tersedia?');
    final uri = Uri.parse('https://wa.me/$cleanedPhone?text=$message');

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi WhatsApp.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka tautan WhatsApp.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_kos?.name ?? 'Detail Kos'),
      ),
      body: _buildBody(),
      bottomNavigationBar: _kos != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    // 1. Loading State
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error State (US02-AC2)
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchDetail,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_kos == null) {
      return const SizedBox.shrink();
    }

    final kos = _kos!;
    final statusText = kos.isAvailable ? 'Tersedia' : 'Penuh';
    final statusColor = kos.isAvailable ? Colors.green.shade700 : Colors.red.shade700;

    // 3. Success State: Menampilkan 9 informasi lengkap (US02-AC1)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Nama Kos & Status Ketersediaan (Info 1 & Info 9)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  kos.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kos.isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Harga per bulan (Info 3)
          Text(
            _formatCurrency(kos.pricePerMonth),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // 3. Jenis Kos (Info 4) & Kamar Tersedia (Info 7)
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.person_outline,
                  label: 'Tipe Kos',
                  value: 'Kos ${_capitalize(kos.type)}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.meeting_room_outlined,
                  label: 'Kamar Kosong',
                  value: '${kos.availableRooms} Kamar',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Alamat Lengkap (Info 2)
          const Text(
            'Alamat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 20, color: Colors.blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  kos.address,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 5. Fasilitas (Info 5: AC, WiFi, kamar mandi dalam, parkir, dapur bersama)
          const Text(
            'Fasilitas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (kos.facilities.isEmpty)
            const Text(
              'Tidak ada fasilitas khusus yang terdaftar.',
              style: TextStyle(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kos.facilities.map((f) {
                return Chip(
                  avatar: Icon(_getFacilityIcon(f), size: 18, color: Colors.blue.shade700),
                  label: Text(f),
                  backgroundColor: Colors.blue.shade50,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          const SizedBox(height: 20),

          // 6. Deskripsi (Info 6)
          const Text(
            'Deskripsi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            kos.description.isNotEmpty ? kos.description : 'Tidak ada deskripsi tambahan.',
            style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // 7. Kontak WhatsApp Pemilik (Info 8)
          const Text(
            'Kontak Pemilik',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 20, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                kos.whatsappNumber,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 28, color: Colors.blue),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  IconData _getFacilityIcon(String facility) {
    final lower = facility.toLowerCase();
    if (lower.contains('wifi')) return Icons.wifi;
    if (lower.contains('ac')) return Icons.ac_unit;
    if (lower.contains('mandi')) return Icons.bathtub_outlined;
    if (lower.contains('parkir')) return Icons.local_parking;
    if (lower.contains('dapur')) return Icons.kitchen_outlined;
    return Icons.check_circle_outline;
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () => _launchWhatsApp(_kos!.whatsappNumber),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text(
            'Hubungi via WhatsApp',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

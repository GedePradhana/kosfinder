import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kos_provider.dart';
import '../widgets/kos_card.dart';
import 'about_screen.dart';
import 'detail_kos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KosProvider>().fetchPublicKos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KosFinder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang Aplikasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<KosProvider>(
        builder: (context, provider, child) {
          // 1. Kondisi Loading (Indikator Loading)
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 2. Kondisi Error (Koneksi Mati/Gagal & Tombol Coba Lagi)
          if (provider.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage ?? 'Gagal memuat data kos',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.fetchPublicKos();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Kondisi Data Kosong
          if (provider.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchPublicKos(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_work_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada kos yang terdaftar',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // 4. Kondisi Sukses: Daftar Kos
          return RefreshIndicator(
            onRefresh: () => provider.fetchPublicKos(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: provider.kosList.length,
              itemBuilder: (context, index) {
                final kos = provider.kosList[index];
                return KosCard(
                  kos: kos,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailKosScreen(
                          kosId: kos.id,
                          initialKos: kos,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

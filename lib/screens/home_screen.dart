import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/kos_provider.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/kos_card.dart';
import 'about_screen.dart';
import 'detail_kos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KosProvider>().fetchPublicKos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    context.read<KosProvider>().search(value);
  }

  void _onClearSearch() {
    _searchController.clear();
    context.read<KosProvider>().clearSearch();
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  void _showFilterDialog(BuildContext context, KosProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => FilterDialog(
        initialMinPrice: provider.minPrice,
        initialMaxPrice: provider.maxPrice,
        onApply: (min, max) {
          provider.setPriceFilter(minPrice: min, maxPrice: max);
        },
        onReset: () {
          provider.clearPriceFilter();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kosProvider = context.watch<KosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KosFinder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Tombol Filter Harga
          IconButton(
            icon: Badge(
              isLabelVisible: kosProvider.isFilteredByPrice,
              child: Icon(
                kosProvider.isFilteredByPrice ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: kosProvider.isFilteredByPrice ? Colors.blue : null,
              ),
            ),
            tooltip: 'Filter Harga',
            onPressed: () => _showFilterDialog(context, kosProvider),
          ),
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
      body: Column(
        children: [
          // Bar Pencarian Teks Bebas (US03-AC1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _onSearchSubmitted,
              decoration: InputDecoration(
                hintText: 'Cari nama kos atau area (contoh: Tembalang)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _onClearSearch,
                        tooltip: 'Hapus pencarian',
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
          ),

          // Chip Indikator Filter Harga Aktif (Bisa di-clear langsung)
          if (kosProvider.isFilteredByPrice)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune, size: 16, color: Colors.blue.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _buildFilterDescription(kosProvider),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: () => kosProvider.clearPriceFilter(),
                            child: const Icon(Icons.close, size: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Konten Utama Daftar Kos
          Expanded(
            child: Consumer<KosProvider>(
              builder: (context, provider, child) {
                // 1. Kondisi Loading
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // 2. Kondisi Error
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
                  final String emptyMessage;
                  if (provider.isFilteredByPrice && provider.isSearching) {
                    emptyMessage = 'Kos tidak ditemukan dengan filter dan kata kunci tersebut';
                  } else if (provider.isFilteredByPrice) {
                    emptyMessage = 'Tidak ada kos dalam rentang harga ini';
                  } else if (provider.isSearching) {
                    emptyMessage = 'Kos tidak ditemukan';
                  } else {
                    emptyMessage = 'Belum ada kos yang terdaftar';
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.fetchPublicKos(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                (provider.isSearching || provider.isFilteredByPrice)
                                    ? Icons.search_off_rounded
                                    : Icons.home_work_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                emptyMessage,
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              if (provider.isFilteredByPrice) ...[
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: () => provider.clearPriceFilter(),
                                  icon: const Icon(Icons.filter_alt_off),
                                  label: const Text('Hapus filter harga'),
                                ),
                              ],
                              if (provider.isSearching) ...[
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: _onClearSearch,
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Tampilkan semua kos'),
                                ),
                              ],
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
          ),
        ],
      ),
    );
  }

  String _buildFilterDescription(KosProvider provider) {
    if (provider.minPrice != null && provider.maxPrice != null) {
      return '${_formatCurrency(provider.minPrice!)} – ${_formatCurrency(provider.maxPrice!)}';
    } else if (provider.minPrice != null) {
      return 'Min ${_formatCurrency(provider.minPrice!)}';
    } else if (provider.maxPrice != null) {
      return 'Maks ${_formatCurrency(provider.maxPrice!)}';
    }
    return 'Filter Harga';
  }
}

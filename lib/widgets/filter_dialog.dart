import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final int? initialMinPrice;
  final int? initialMaxPrice;
  final void Function(int? minPrice, int? maxPrice) onApply;
  final VoidCallback onReset;

  const FilterDialog({
    super.key,
    this.initialMinPrice,
    this.initialMaxPrice,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(
      text: widget.initialMinPrice != null ? widget.initialMinPrice.toString() : '',
    );
    _maxPriceController = TextEditingController(
      text: widget.initialMaxPrice != null ? widget.initialMaxPrice.toString() : '',
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _handleApply() {
    setState(() {
      _validationError = null;
    });

    final minText = _minPriceController.text.trim();
    final maxText = _maxPriceController.text.trim();

    final min = minText.isNotEmpty ? int.tryParse(minText) : null;
    final max = maxText.isNotEmpty ? int.tryParse(maxText) : null;

    // Validasi format angka
    if (minText.isNotEmpty && min == null) {
      setState(() {
        _validationError = 'Harga minimum harus berupa angka valid';
      });
      return;
    }
    if (maxText.isNotEmpty && max == null) {
      setState(() {
        _validationError = 'Harga maksimum harus berupa angka valid';
      });
      return;
    }

    // US04-AC2: Validasi min > max
    if (min != null && max != null && min > max) {
      setState(() {
        _validationError = 'Harga minimum tidak boleh lebih besar dari harga maksimum';
      });
      return;
    }

    widget.onApply(min, max);
    Navigator.pop(context);
  }

  void _handleReset() {
    widget.onReset();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.tune, color: Colors.blue),
          SizedBox(width: 8),
          Text('Filter Harga', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tentukan rentang harga per bulan (Rp):',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Input Harga Minimum
            TextField(
              controller: _minPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga Minimum',
                prefixText: 'Rp ',
                hintText: '500000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),

            // Input Harga Maksimum
            TextField(
              controller: _maxPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga Maksimum',
                prefixText: 'Rp ',
                hintText: '1000000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),

            // Pesan Error Validasi (US04-AC2)
            if (_validationError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 16, color: Colors.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _handleReset,
          child: const Text('Reset', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _handleApply,
          child: const Text('Terapkan'),
        ),
      ],
    );
  }
}

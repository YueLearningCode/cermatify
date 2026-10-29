import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../services/play_billing_service.dart';
import '../../routes/app_pages.dart';

class PlayCheckoutPanel extends StatefulWidget {
  const PlayCheckoutPanel({super.key, required this.selection});

  final Map<String, dynamic> selection;

  @override
  State<PlayCheckoutPanel> createState() => _PlayCheckoutPanelState();
}

class _PlayCheckoutPanelState extends State<PlayCheckoutPanel> {
  late final PlayBillingService _billing = Get.find<PlayBillingService>();
  ProductDetails? _product;
  bool _loading = true;
  bool _failed = false;
  String _packageId = 'basic';
  Map<String, dynamic> get _selection => {
    ...widget.selection,
    if (widget.selection['serviceId'] != 'kuesioner') 'packageId': _packageId,
  };
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final id = await _billing.prepareProduct(_selection);
      final response = await InAppPurchase.instance.queryProductDetails({id});
      if (response.error != null || response.productDetails.length != 1) {
        throw StateError('Unavailable');
      }
      if (mounted && generation == _loadGeneration) {
        setState(() => _product = response.productDetails.single);
      }
    } catch (_) {
      if (mounted && generation == _loadGeneration) {
        setState(() => _failed = true);
      }
    } finally {
      if (mounted && generation == _loadGeneration) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Pembayaran melalui Google Play',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      const SizedBox(height: 12),
      if (widget.selection['serviceId'] != 'kuesioner') ...[
        DropdownButtonFormField<String>(
          initialValue: _packageId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Paket pendampingan'),
          items: const [
            DropdownMenuItem(
              value: 'basic',
              child: Text('Awal — 1 sesi 60 menit'),
            ),
            DropdownMenuItem(
              value: 'intensive',
              child: Text('Intensif — 4 sesi 60 menit'),
            ),
          ],
          onChanged: (value) {
            if (value == null || _billing.busy.value) return;
            setState(() => _packageId = value);
            _load();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            _packageId == 'basic'
                ? '3 topik chat selama 3 hari, review maksimal 5 halaman. Masa layanan 14 hari.'
                : '12 topik chat, 4 review maksimal 10 halaman. Masa layanan 30 hari.',
          ),
        ),
      ],
      if (_loading)
        const Center(child: CircularProgressIndicator())
      else if (_failed) ...[
        const Text(
          'Layanan ini belum tersedia untuk dibeli melalui Google Play. Silakan coba lagi nanti.',
        ),
        TextButton(onPressed: _load, child: const Text('Coba lagi')),
      ] else ...[
        Text(_product!.title),
        Text(_product!.description),
        const SizedBox(height: 12),
        Text(
          _product!.price,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Pembelian satu kali untuk satu pesanan. Harga akhir ditampilkan oleh Google Play sebelum Anda menyetujui pembayaran.',
        ),
        const SizedBox(height: 12),
        Obx(
          () => FilledButton(
            onPressed: _billing.busy.value
                ? null
                : () => _billing.buy(_selection),
            child: Text(
              _billing.busy.value ? 'Memproses...' : 'Bayar dengan Google Play',
            ),
          ),
        ),
      ],
      Obx(
        () => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(_billing.message.value),
        ),
      ),
      TextButton(
        onPressed: _billing.recover,
        child: const Text('Periksa pembelian'),
      ),
      TextButton(
        onPressed: () => Get.toNamed(Routes.ORDER_HISTORY),
        child: const Text('Lihat riwayat pesanan'),
      ),
    ],
  );
}

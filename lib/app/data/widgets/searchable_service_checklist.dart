import 'package:flutter/material.dart';

class SearchableServiceChecklist extends StatefulWidget {
  const SearchableServiceChecklist({
    super.key,
    required this.services,
    required this.selectedIds,
    required this.onToggle,
    this.isLoading = false,
    this.errorMessage = '',
    this.onRetry,
    this.helperText =
        'Pilih dari daftar atau ketik nama layanan untuk mempersempit pilihan.',
  });
  final List<Map<String, String>> services;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback? onRetry;
  final String helperText;

  @override
  State<SearchableServiceChecklist> createState() =>
      _SearchableServiceChecklistState();
}

class _SearchableServiceChecklistState
    extends State<SearchableServiceChecklist> {
  String _query = '';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.services
        .where((item) => (item['name'] ?? '').toLowerCase().contains(_query))
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _search,
          decoration: InputDecoration(
            labelText: 'Cari layanan atau cabang',
            hintText: 'Lihat daftar atau cari nama layanan',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _search.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Tampilkan semua layanan',
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      _search.clear();
                      _query = '';
                    }),
                  ),
          ),
          onChanged: (value) =>
              setState(() => _query = value.trim().toLowerCase()),
        ),
        const SizedBox(height: 8),
        Text(widget.helperText, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text('${widget.selectedIds.length} layanan dipilih'),
        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (widget.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.errorMessage),
                if (widget.onRetry != null)
                  TextButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Muat ulang layanan'),
                  ),
              ],
            ),
          )
        else if (widget.services.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Belum ada layanan tersedia untuk bidang ini.'),
          )
        else if (results.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Tidak ada layanan yang cocok.'),
          )
        else ...[
          const SizedBox(height: 10),
          Text(
            _query.isEmpty
                ? 'Layanan tersedia (${results.length})'
                : 'Hasil pencarian (${results.length})',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                final id = item['id'] ?? '';
                return CheckboxListTile(
                  value: widget.selectedIds.contains(id),
                  title: Text(item['name'] ?? ''),
                  subtitle: item['type'] == 'complink'
                      ? const Text('Cermat Competition')
                      : item['type'] == 'paperlink'
                      ? const Text('Cermat Paper')
                      : null,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: id.isEmpty ? null : (_) => widget.onToggle(id),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

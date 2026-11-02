import 'package:flutter/material.dart';
import '../../../data/services/moderation_service.dart';

class ChatSafetyControls extends StatelessWidget {
  const ChatSafetyControls({
    super.key,
    required this.blocked,
    required this.onBlock,
    required this.onReport,
  });
  final bool blocked;
  final VoidCallback onBlock;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    children: [
      TextButton.icon(
        onPressed: onReport,
        icon: const Icon(Icons.flag_outlined),
        label: const Text('Laporkan pengguna'),
      ),
      TextButton.icon(
        onPressed: onBlock,
        icon: const Icon(Icons.block),
        label: Text(blocked ? 'Buka blokir' : 'Blokir pengguna'),
      ),
    ],
  );
}

class ChatReportDialog extends StatefulWidget {
  const ChatReportDialog({super.key, required this.submit});
  final Future<void> Function(String reason, String details) submit;
  @override
  State<ChatReportDialog> createState() => _ChatReportDialogState();
}

class _ChatReportDialogState extends State<ChatReportDialog> {
  final _details = TextEditingController();
  String _reason = ModerationService.reasons.first;
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.submit(_reason, _details.text);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Laporan belum terkirim. Periksa koneksi dan coba lagi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: const Text('Laporkan ke Cermatify'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin akan meninjau laporan dan percakapan terkait. Jangan cantumkan password, OTP, atau informasi rekening.',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _reason,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Alasan'),
                items: ModerationService.reasons
                    .map(
                      (reason) => DropdownMenuItem(
                        value: reason,
                        child: Text(reason, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: _busy
                    ? null
                    : (value) => setState(() => _reason = value!),
              ),
              TextField(
                controller: _details,
                enabled: !_busy,
                maxLength: 2000,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)',
                ),
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _busy ? null : _send,
          child: Text(_busy ? 'Mengirim...' : 'Kirim laporan'),
        ),
      ],
    ),
  );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../data/widgets/responsive_content.dart';
import '../../../data/services/public_profile_service.dart';

class AdminModerationView extends StatefulWidget {
  const AdminModerationView({super.key});
  @override
  State<AdminModerationView> createState() => _AdminModerationViewState();
}

class _AdminModerationViewState extends State<AdminModerationView> {
  final _db = FirebaseFirestore.instance;
  int _limit = 50;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _reports;
  @override
  void initState() {
    super.initState();
    _watch();
  }

  void _watch() {
    _reports = _db
        .collection('moderationReports')
        .orderBy('createdAt', descending: true)
        .limit(_limit)
        .snapshots();
  }

  Future<void> _review(
    QueryDocumentSnapshot<Map<String, dynamic>> report,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ReviewDialog(db: _db, report: report),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Laporan pengguna')),
    body: ResponsiveContent(
      maxWidth: 960,
      child: StreamBuilder(
        stream: _reports,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Laporan belum dapat dimuat.'),
                  TextButton(
                    onPressed: () => setState(_watch),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final reports = snapshot.data!.docs;
          if (reports.isEmpty) {
            return const Center(child: Text('Belum ada laporan pengguna.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Tinjau bukti sebelum mengambil tindakan. Pembatasan akun tidak otomatis menyelesaikan pesanan, refund, atau pencairan.',
              ),
              const SizedBox(height: 12),
              for (final report in reports)
                ModerationReportCard(
                  id: report.id,
                  data: report.data(),
                  onReview: () => _review(report),
                ),
              if (reports.length == _limit)
                TextButton(
                  onPressed: () => setState(() {
                    _limit += 50;
                    _watch();
                  }),
                  child: const Text('Muat laporan lebih lama'),
                ),
            ],
          );
        },
      ),
    ),
  );
}

class ModerationReportCard extends StatelessWidget {
  const ModerationReportCard({
    super.key,
    required this.id,
    required this.data,
    required this.onReview,
  });
  final String id;
  final Map<String, dynamic> data;
  final VoidCallback onReview;
  static const statuses = {
    'open': 'Baru',
    'reviewing': 'Ditinjau',
    'resolved': 'Ditindaklanjuti',
    'dismissed': 'Tidak ditemukan pelanggaran',
  };
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${data['reason']} • ${statuses[data['status']] ?? data['status']}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SelectableText(
            'Laporan: $id\nPelapor: ${data['reporterId']}\nDilaporkan: ${data['targetId']}',
          ),
          const SizedBox(height: 8),
          Text(data['details'] as String? ?? ''),
          if (data['notes'] != null) Text('Catatan admin: ${data['notes']}'),
          TextButton.icon(
            onPressed: onReview,
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Tinjau bukti dan tindakan'),
          ),
        ],
      ),
    ),
  );
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog({required this.db, required this.report});
  final FirebaseFirestore db;
  final QueryDocumentSnapshot<Map<String, dynamic>> report;
  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _notes = TextEditingController();
  late final Future<List<String>> _evidence;
  String _status = 'reviewing';
  bool _suspend = false;
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _notes.text = widget.report.data()['notes'] as String? ?? '';
    _evidence = _loadEvidence();
  }

  Future<List<String>> _loadEvidence() async {
    final report = widget.report.data();
    final messages = widget.db
        .collection('chatRooms')
        .doc(report['roomId'] as String)
        .collection('messages');
    final messageId = report['messageId'] as String? ?? '';
    if (messageId.isNotEmpty) {
      final message = await messages.doc(messageId).get();
      return [
        message.exists
            ? '${message.data()!['senderId']}: ${message.data()!['message']}'
            : 'Pesan sudah tidak tersedia.',
      ];
    }
    final recent = await messages
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
    return recent.docs.reversed
        .map((doc) => '${doc.data()['senderId']}: ${doc.data()['message']}')
        .toList();
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    if (_notes.text.trim().isEmpty) {
      setState(() => _error = 'Isi hasil peninjauan terlebih dahulu.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await widget.db.runTransaction((transaction) async {
        final latest = await transaction.get(widget.report.reference);
        final target = widget.db
            .collection('users')
            .doc(latest.data()!['targetId'] as String);
        if (_suspend) {
          final user = await transaction.get(target);
          if (!user.exists ||
              user.data()?['role'] == 'admin' ||
              target.id == uid) {
            throw StateError('Akun ini tidak dapat dibatasi melalui laporan.');
          }
          transaction.update(target, {
            'status': 'inactive',
            'accountStatus': 'disabled',
            'updatedAt': FieldValue.serverTimestamp(),
          });
          PublicProfileService.setInTransaction(
            widget.db,
            transaction,
            target.id,
            {
              ...user.data()!,
              'status': 'inactive',
              'accountStatus': 'disabled',
            },
          );
        }
        transaction.update(widget.report.reference, {
          'status': _status,
          'notes': _notes.text.trim(),
          'reviewedBy': uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error =
              'Tindakan belum tersimpan. Periksa akses admin dan status akun, lalu coba lagi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: const Text('Tinjau laporan'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pesan dilaporkan / 20 pesan terakhir (teks asli):'),
              FutureBuilder(
                future: _evidence,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                      'Bukti gagal dimuat. Tutup dan buka kembali untuk mencoba lagi.',
                    );
                  }
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  return SelectableText(
                    snapshot.data!.isEmpty
                        ? 'Belum ada pesan.'
                        : snapshot.data!.join('\n\n'),
                  );
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Hasil peninjauan',
                ),
                items: ModerationReportCard.statuses.entries
                    .where((entry) => entry.key != 'open')
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _busy
                    ? null
                    : (value) => setState(() => _status = value!),
              ),
              TextField(
                controller: _notes,
                enabled: !_busy,
                maxLength: 2000,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Catatan tindakan (wajib)',
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _suspend,
                onChanged: _busy
                    ? null
                    : (value) => setState(() => _suspend = value!),
                title: const Text('Nonaktifkan akun yang dilaporkan'),
                subtitle: const Text(
                  'Menghentikan akses akun dan pesan baru. Tinjau kewajiban pesanan serta dana secara terpisah.',
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
          onPressed: _busy ? null : _save,
          child: Text(_busy ? 'Menyimpan...' : 'Simpan tindakan'),
        ),
      ],
    ),
  );
}

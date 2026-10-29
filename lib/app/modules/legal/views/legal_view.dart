import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes/app_pages.dart';

/// Works without login and reads bundled documents, including when offline.
class LegalView extends StatefulWidget {
  const LegalView({super.key, required this.document});

  final String document;

  @override
  State<LegalView> createState() => _LegalViewState();
}

class _LegalViewState extends State<LegalView> {
  late final Future<Map<String, dynamic>> _document = _load();
  static const _email = 'cermatifycompany@gmail.com';

  Future<Map<String, dynamic>> _load() async =>
      jsonDecode(
            await rootBundle.loadString('assets/legal/${widget.document}.json'),
          )
          as Map<String, dynamic>;

  Future<void> _requestDeletion() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      query:
          'subject=${Uri.encodeComponent('Permintaan penghapusan akun Cermatify')}'
          '&body=${Uri.encodeComponent('Saya meminta penghapusan akun Cermatify beserta data terkait.\n\nEmail akun: \n')}',
    );
    try {
      if (await launchUrl(uri)) return;
    } catch (_) {
      // Keep the address and instructions available without an email app.
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Aplikasi email tidak dapat dibuka. Salin alamat bantuan dan kirim permintaan dari email Anda.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privasi dan akun')),
    body: FutureBuilder<Map<String, dynamic>>(
      future: _document,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: SelectableText(
              'Dokumen tidak dapat dibuka. Hubungi cermatifycompany@gmail.com.',
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final document = snapshot.data!;
        return SelectionArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document['title'] as String,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Diperbarui ${document['updated']}'),
                    const SizedBox(height: 24),
                    for (final section in document['sections'] as List) ...[
                      Text(
                        section['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        section['body'] as String,
                        style: const TextStyle(height: 1.6),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (widget.document == 'delete-account') ...[
                      FilledButton.icon(
                        onPressed: _requestDeletion,
                        icon: const Icon(Icons.mail_outline),
                        label: const Text('Kirim permintaan melalui email'),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            const ClipboardData(text: _email),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Alamat email disalin.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Salin alamat bantuan'),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const PrivacyAccountLinks(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class PrivacyAccountLinks extends StatelessWidget {
  const PrivacyAccountLinks({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      TextButton(
        onPressed: () => Get.toNamed(Routes.PRIVACY),
        child: const Text('Kebijakan privasi'),
      ),
      TextButton(
        onPressed: () => Get.toNamed(Routes.TERMS),
        child: const Text('Syarat dan ketentuan'),
      ),
      TextButton.icon(
        onPressed: () => Get.toNamed(Routes.DELETE_ACCOUNT),
        icon: const Icon(Icons.person_remove_outlined),
        label: const Text('Hapus akun dan data'),
      ),
    ],
  );
}

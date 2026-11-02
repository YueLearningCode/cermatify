import 'package:flutter/material.dart';

String? validateQuestionnaireLink(String? input) {
  final value = input?.trim() ?? '';
  final uri = Uri.tryParse(value);
  if (value.isEmpty) return 'Masukkan tautan kuesioner.';
  if (value.length > 2048 ||
      RegExp(r'\s').hasMatch(value) ||
      uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    return 'Gunakan tautan HTTPS yang valid tanpa username atau password.';
  }
  return null;
}

/// Collect the survey URL before mounting checkout, which requests a quote.
class QuestionnaireLinkStep extends StatefulWidget {
  const QuestionnaireLinkStep({
    super.key,
    required this.initialLink,
    required this.onContinue,
  });

  final String initialLink;
  final ValueChanged<String> onContinue;

  @override
  State<QuestionnaireLinkStep> createState() => _QuestionnaireLinkStepState();
}

class _QuestionnaireLinkStepState extends State<QuestionnaireLinkStep> {
  final _formKey = GlobalKey<FormState>();
  late final _link = TextEditingController(text: widget.initialLink);

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tautan kuesioner', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const Text(
          'Masukkan tautan formulir penelitian yang ingin diajukan. Pastikan formulir dapat dibuka oleh calon responden.',
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _link,
          keyboardType: TextInputType.url,
          autocorrect: false,
          maxLength: 2048,
          decoration: const InputDecoration(
            labelText: 'Tautan HTTPS',
            hintText: 'https://…',
            errorMaxLines: 3,
            border: OutlineInputBorder(),
          ),
          validator: validateQuestionnaireLink,
        ),
        const SizedBox(height: 12),
        const Text(
          'Pengajuan akan ditinjau. Pembayaran layanan tidak menjamin jumlah responden dan tidak langsung mengaktifkan reward.',
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onContinue(_link.text.trim());
            }
          },
          child: const Text('Lanjut ke pembayaran'),
        ),
      ],
    ),
  );
}

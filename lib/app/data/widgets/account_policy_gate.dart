import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/account_policy.dart';
import '../services/session_state.dart';
import '../../routes/app_pages.dart';

class AccountPolicyGate extends StatefulWidget {
  const AccountPolicyGate({super.key, required this.child});
  final Widget child;
  @override
  State<AccountPolicyGate> createState() => _AccountPolicyGateState();
}

class _AccountPolicyGateState extends State<AccountPolicyGate> {
  late final _user = FirebaseAuth.instance.currentUser;
  late final _profile = _user == null
      ? null
      : FirebaseFirestore.instance.collection('users').doc(_user.uid);
  late Stream<DocumentSnapshot<Map<String, dynamic>>>? _stream = _profile
      ?.snapshots();

  Future<void> _leave() async {
    await FirebaseAuth.instance.signOut();
    await SessionState.clear();
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: _stream,
    builder: (context, snapshot) {
      if (_user == null ||
          snapshot.hasError ||
          (snapshot.hasData && !snapshot.data!.exists)) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Data akun belum dapat dimuat.'),
                TextButton(
                  onPressed: () =>
                      setState(() => _stream = _profile?.snapshots()),
                  child: const Text('Coba lagi'),
                ),
                TextButton(
                  onPressed: _leave,
                  child: const Text('Kembali ke login'),
                ),
              ],
            ),
          ),
        );
      }
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final profile = snapshot.data!.data();
      if (!AccountPolicy.canUseAccount(profile)) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Akses akun belum tersedia. Hubungi cermatifycompany@gmail.com untuk peninjauan akun atau penyelesaian pesanan.',
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.DELETE_ACCOUNT),
                    child: const Text('Privasi dan penghapusan akun'),
                  ),
                  TextButton(onPressed: _leave, child: const Text('Keluar')),
                ],
              ),
            ),
          ),
        );
      }
      if (AccountPolicy.hasConsent(profile)) return widget.child;
      return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 520,
              child: PolicyConsentForm(
                accept: () => _profile!.update({
                  'adultConfirmed': true,
                  'termsVersion': AccountPolicy.version,
                  'termsAcceptedAt': FieldValue.serverTimestamp(),
                }),
                leave: _leave,
                openTerms: () => Get.toNamed(Routes.TERMS),
                openPrivacy: () => Get.toNamed(Routes.PRIVACY),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class PolicyConsentForm extends StatefulWidget {
  const PolicyConsentForm({
    super.key,
    required this.accept,
    required this.leave,
    required this.openTerms,
    required this.openPrivacy,
  });
  final Future<void> Function() accept;
  final VoidCallback leave, openTerms, openPrivacy;
  @override
  State<PolicyConsentForm> createState() => _PolicyConsentFormState();
}

class _PolicyConsentFormState extends State<PolicyConsentForm> {
  bool _adult = false, _agreed = false, _busy = false;
  String? _error;
  Future<void> _submit() async {
    if (!_adult || !_agreed || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.accept();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Persetujuan belum tersimpan. Silakan coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Sebelum menggunakan Cermatify',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 16),
      const Text(
        'Layanan ditujukan untuk pengguna berusia 18 tahun ke atas. Gunakan chat dan layanan dengan menghormati pengguna lain. Jika belum memenuhi batas usia, keluar dan hubungi bantuan untuk urusan akun yang sudah ada.',
      ),
      CheckboxListTile(
        value: _adult,
        onChanged: _busy ? null : (value) => setState(() => _adult = value!),
        title: const Text('Saya sudah berusia 18 tahun atau lebih.'),
      ),
      Wrap(
        alignment: WrapAlignment.center,
        children: [
          TextButton(
            onPressed: widget.openTerms,
            child: const Text('Baca syarat layanan'),
          ),
          TextButton(
            onPressed: widget.openPrivacy,
            child: const Text('Baca kebijakan privasi'),
          ),
        ],
      ),
      CheckboxListTile(
        value: _agreed,
        onChanged: _busy ? null : (value) => setState(() => _agreed = value!),
        title: const Text(
          'Saya menyetujui syarat layanan dan telah membaca kebijakan privasi.',
        ),
      ),
      if (_error != null)
        Text(
          _error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      FilledButton(
        onPressed: !_adult || !_agreed || _busy ? null : _submit,
        child: Text(_busy ? 'Menyimpan...' : 'Setuju dan lanjutkan'),
      ),
      TextButton(
        onPressed: _busy ? null : widget.leave,
        child: const Text('Keluar'),
      ),
    ],
  );
}

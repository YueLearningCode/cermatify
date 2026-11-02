import 'package:cermatify/app/data/services/public_profile_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'public projection never exports private fields or arbitrary future fields',
    () {
      final result = publicProfileData('mentor', {
        'nama': 'Mentor',
        'role': 'mentor',
        'status': 'active',
        'kampus': 'Campus',
        'jurusan': 'Biology',
        'verificationStatus': 'verified',
        'layanan': ['Paper'],
        'email': 'private@example.com',
        'noTelp': '08123',
        'saldo': 10000,
        'playAvailable': 20000,
        'nomorRekening': '12345',
        'adultConfirmed': true,
        'termsVersion': '2026-11-01',
        'newPrivateField': 'secret',
      });
      expect(result['kampus'], 'Campus');
      expect(result['layanan'], ['Paper']);
      expect(result['verificationStatus'], 'verified');
      for (final key in [
        'email',
        'noTelp',
        'saldo',
        'playAvailable',
        'nomorRekening',
        'adultConfirmed',
        'termsVersion',
        'newPrivateField',
      ]) {
        expect(result.containsKey(key), isFalse, reason: key);
      }
    },
  );

  test(
    'customer projection only exposes identity for chat, not academic demographics',
    () {
      final profile = publicProfileData('customer', {
        'role': 'customer',
        'nama': 'Customer',
        'kampus': 'Private campus',
        'jurusan': 'Private major',
        'linkedin': 'https://example.com',
        'saldo': 9000,
      });
      expect(profile['nama'], 'Customer');
      expect(profile['kampus'], '');
      expect(profile['jurusan'], '');
      expect(profile['linkedin'], '');
      expect(profile['status'], 'inactive');
    },
  );

  test(
    'legacy names and null values remain compatible with projection rules',
    () {
      expect(
        publicProfileData('legacy', {'namaLengkap': 'Legacy'})['nama'],
        'Legacy',
      );
      expect(publicProfileData('legacy', {'nama': null})['nama'], isNull);
      expect(publicProfileData('legacy', {})['nama'], 'Pengguna Cermatify');
    },
  );
}

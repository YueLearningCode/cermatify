import 'package:cloud_firestore/cloud_firestore.dart';

/// Deliberate allowlist: never copy email, phone, balances, consent or bank data.
Map<String, dynamic> publicProfileData(
  String uid,
  Map<String, dynamic> source,
) {
  dynamic value(String key, dynamic fallback) =>
      source.containsKey(key) ? source[key] : fallback;
  final mentor = source['role'] == 'mentor';
  return {
    'id': uid,
    'nama': value('nama', value('namaLengkap', 'Pengguna Cermatify')),
    'image': value('image', ''),
    'role': value('role', 'customer'),
    'status': value('status', 'inactive'),
    'accountStatus': value('accountStatus', 'active'),
    'verificationStatus': mentor ? value('verificationStatus', 'pending') : '',
    'kampus': mentor ? value('kampus', '') : '',
    'jurusan': mentor ? value('jurusan', '') : '',
    'layanan': mentor ? value('layanan', <String>[]) : <String>[],
    'linkedin': mentor ? value('linkedin', '') : '',
    'bio': mentor ? value('bio', '') : '',
    'rating': mentor ? value('rating', 0) : 0,
    'totalSessions': mentor ? value('totalSessions', 0) : 0,
  };
}

abstract final class PublicProfileService {
  static void setInTransaction(
    FirebaseFirestore db,
    Transaction transaction,
    String uid,
    Map<String, dynamic> profile,
  ) {
    transaction.set(
      db.collection('publicProfiles').doc(uid),
      publicProfileData(uid, profile),
    );
  }

  static Future<void> update(
    FirebaseFirestore db,
    String uid,
    Map<String, dynamic> changes,
  ) => db.runTransaction((transaction) async {
    final reference = db.collection('users').doc(uid);
    final existing = await transaction.get(reference);
    if (!existing.exists) throw StateError('Profil tidak ditemukan.');
    transaction.update(reference, changes);
    setInTransaction(db, transaction, uid, {...existing.data()!, ...changes});
  });

  static Future<void> create(
    FirebaseFirestore db,
    String uid,
    Map<String, dynamic> profile,
  ) async {
    final batch = db.batch();
    batch.set(db.collection('users').doc(uid), profile);
    batch.set(
      db.collection('publicProfiles').doc(uid),
      publicProfileData(uid, profile),
    );
    await batch.commit();
  }
}

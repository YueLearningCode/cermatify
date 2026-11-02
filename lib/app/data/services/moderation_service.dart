import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModerationService {
  ModerationService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  static const reasons = [
    'Pelecehan atau ancaman',
    'Penipuan',
    'Spam',
    'Konten tidak pantas',
    'Lainnya',
  ];

  String get _uid {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) throw StateError('Login diperlukan.');
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> _block(String targetId) =>
      _db.doc('userBlocks/$_uid/blocked/$targetId');

  Stream<bool> watchBlocked(String targetId) =>
      _block(targetId).snapshots().map((snapshot) => snapshot.exists);

  Future<void> setBlocked(String targetId, bool blocked) async {
    if (targetId.isEmpty || targetId == _uid || targetId.contains('/')) {
      throw ArgumentError('Pengguna tidak valid.');
    }
    final reference = _block(targetId);
    await _db.runTransaction((transaction) async {
      final existing = await transaction.get(reference);
      if (blocked && !existing.exists) {
        transaction.set(reference, {'createdAt': FieldValue.serverTimestamp()});
      } else if (!blocked && existing.exists) {
        transaction.delete(reference);
      }
    });
  }

  String newReportId() => _db.collection('moderationReports').doc().id;

  Future<void> report({
    required String id,
    required String targetId,
    required String roomId,
    required String reason,
    required String details,
    String messageId = '',
  }) async {
    if (!reasons.contains(reason) || details.trim().length > 2000) {
      throw ArgumentError('Isi laporan tidak valid.');
    }
    final uid = _uid;
    final reference = _db.collection('moderationReports').doc(id);
    try {
      await reference.set({
        'reporterId': uid,
        'targetId': targetId,
        'roomId': roomId,
        'messageId': messageId,
        'reason': reason,
        'details': details.trim(),
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // The server may have accepted a previous attempt before a timeout.
      // Reuse the dialog's report ID; do not create duplicate reports on retry.
      final existing = (await reference.get(
        const GetOptions(source: Source.server),
      )).data();
      if (existing?['reporterId'] != uid ||
          existing?['targetId'] != targetId ||
          existing?['roomId'] != roomId ||
          existing?['messageId'] != messageId) {
        rethrow;
      }
    }
  }
}

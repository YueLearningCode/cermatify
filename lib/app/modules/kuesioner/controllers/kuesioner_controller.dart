import 'package:get/get.dart';
import 'package:cermatify/app/data/models/kuesioner_model.dart';
import 'package:cermatify/app/data/dummy_kuesioner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KuesionerController extends GetxController {
  final kuesionerList = <Kuesioner>[].obs;
  final hasRespondenData = false.obs;
  final respondenData = <String, dynamic>{}.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Tabs and additional lists
  final selectedTab = 0.obs; // 0=rekomendasi, 1=dibuatSaya, 2=sayaIkuti
  final createdByMeList = <Kuesioner>[].obs;
  final signedByMeList = <Kuesioner>[].obs;

  Future<void> _ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  @override
  void onInit() {
    super.onInit();
    _ensureSignedIn();
    loadKuesioner();
    _loadResponden();
    _loadCreatedByMe();
    _loadSignedByMe();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void loadKuesioner() {
    // Fetch from Firestore and filter by responden attributes if available
    _loadKuesionerFiltered();
  }

  Future<void> _loadResponden() async {
    try {
      final String uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        hasRespondenData.value = false;
        respondenData.clear();
        return;
      }
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      final Map<String, dynamic>? responden = (data?['responden'] as Map<String, dynamic>?);
      if (responden != null && responden.isNotEmpty) {
        respondenData.assignAll(responden);
        hasRespondenData.value = true;
      } else {
        hasRespondenData.value = false;
        respondenData.clear();
      }
    } catch (_) {
      hasRespondenData.value = false;
      respondenData.clear();
    }
  }

  Future<void> _loadKuesionerFiltered() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('kuesioners')
          .orderBy('createdAt', descending: true)
          .get();
      final List<Kuesioner> all = snapshot.docs.map((doc) {
        final data = doc.data();
        final DateTime created = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return Kuesioner(id: doc.id, createdAt: created, answers: const []);
      }).toList();

      if (!hasRespondenData.value || respondenData.isEmpty) {
        kuesionerList.value = all;
        return;
      }

      bool match(dynamic target, String? userVal) {
        if (userVal == null || userVal.isEmpty) return true;
        if (target == null) return true; // no targeting = open to all
        if (target is String) return target == userVal;
        if (target is List) return target.map((e) => e?.toString()).contains(userVal);
        return true;
      }

      final String? usia = respondenData['rentangUsia'] as String?;
      final String? kelamin = respondenData['jenisKelamin'] as String?;
      final String? penghasilan = respondenData['tingkatPenghasilan'] as String?;
      final String? pendidikan = respondenData['pendidikanTerakhir'] as String?;

      final filtered = snapshot.docs
          .where((doc) {
            final data = doc.data();
            return match(data['rentangUsia'], usia) &&
                match(data['jenisKelamin'], kelamin) &&
                match(data['tingkatPenghasilan'], penghasilan) &&
                match(data['pendidikanTerakhir'], pendidikan);
          })
          .map((doc) {
            final data = doc.data();
            final DateTime created =
                (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            return Kuesioner(id: doc.id, createdAt: created, answers: const []);
          })
          .toList();

      kuesionerList.value = filtered;
    } catch (_) {
      // fallback to dummy if collection doesn't exist
      kuesionerList.value = dummyKuesioner;
    }
  }

  Future<void> _loadCreatedByMe() async {
    try {
      await _ensureSignedIn();
      final String uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        createdByMeList.clear();
        return;
      }
      final snapshot = await _firestore.collection('kuesioners').where('createdBy', isEqualTo: uid).get();
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        final DateTime created = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return Kuesioner(id: doc.id, createdAt: created, answers: const []);
      }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      createdByMeList.value = items;
    } catch (_) {
      createdByMeList.clear();
    }
  }

  Future<void> _loadSignedByMe() async {
    try {
      await _ensureSignedIn();
      final String uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        signedByMeList.clear();
        return;
      }
      final snapshot = await _firestore.collection('kuesioners').where('signedBy', arrayContains: uid).get();
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        final DateTime created = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return Kuesioner(id: doc.id, createdAt: created, answers: const []);
      }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      signedByMeList.value = items;
    } catch (_) {
      signedByMeList.clear();
    }
  }
}

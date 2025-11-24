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
    loadCreatedByMe();
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

  Future<void> reloadRespondenData() async {
    await _loadResponden();
    loadKuesioner();
  }

  Future<void> refreshAll() async {
    await _loadResponden();
    loadKuesioner();
    await loadCreatedByMe();
    await _loadSignedByMe();
  }

  Future<void> _loadResponden() async {
    try {
      final String uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        hasRespondenData.value = false;
        respondenData.clear();
        return;
      }
      // Load from data_diri collection instead of users.responden
      final doc = await _firestore.collection('data_diri').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        respondenData.assignAll({
          'rentangUsia': data['rentangUsia'],
          'jenisKelamin': data['jenisKelamin'],
          'tingkatPenghasilan': data['tingkatPenghasilan'],
          'pendidikanTerakhir': data['pendidikanTerakhir'],
        });
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
      if (!hasRespondenData.value || respondenData.isEmpty) {
        // If user hasn't set data tambahan, don't show any recommended kuesioners
        // because filtering is based on demographic data
        kuesionerList.value = [];
        return;
      }

      // Only fetch approved kuesioners
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('kuesioners')
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .get();

      // Normalize income values for matching
      String? normalizeIncome(String? value) {
        if (value == null || value.isEmpty) return null;
        // Map different income formats to a common format
        if (value.contains('< Rp 2.000.000') || value.contains('Rp 0 - Rp 2.000.000')) {
          return 'Rp 0 - Rp 2.000.000';
        }
        if (value.contains('Rp 2.000.000 - Rp 5.000.000')) {
          return 'Rp 2.000.000 - Rp 5.000.000';
        }
        if (value.contains('Rp 5.000.000 - Rp 10.000.000')) {
          return 'Rp 5.000.000 - Rp 10.000.000';
        }
        if (value.contains('Rp 10.000.000 - Rp 20.000.000')) {
          return 'Rp 10.000.000 - Rp 20.000.000';
        }
        if (value.contains('> Rp 20.000.000') || value.contains('Rp 20.000.001')) {
          return '> Rp 20.000.000';
        }
        return value; // Return as-is if no match
      }

      bool match(dynamic target, String? userVal) {
        if (userVal == null || userVal.isEmpty) return true;
        if (target == null) return true; // no targeting = open to all

        // Special handling for income to normalize different formats
        if (target is String && target.contains('Rp') && userVal.contains('Rp')) {
          final normalizedTarget = normalizeIncome(target);
          final normalizedUser = normalizeIncome(userVal);
          return normalizedTarget == normalizedUser;
        }

        if (target is String) return target == userVal;
        if (target is List) return target.map((e) => e?.toString()).contains(userVal);
        return true;
      }

      final String? usia = respondenData['rentangUsia'] as String?;
      final String? kelamin = respondenData['jenisKelamin'] as String?;
      final String? penghasilan = respondenData['tingkatPenghasilan'] as String?;
      final String? pendidikan = respondenData['pendidikanTerakhir'] as String?;

      // Get current user ID to filter out kuesioners they've already signed up for
      final String currentUid = _auth.currentUser?.uid ?? '';

      final filtered = snapshot.docs
          .where((doc) {
            final data = doc.data();

            // Check if user is already a respondent
            final List<dynamic> signedBy = (data['signedBy'] as List<dynamic>?) ?? [];
            final bool alreadyRespondent =
                currentUid.isNotEmpty && signedBy.map((e) => e.toString()).contains(currentUid);

            // Exclude kuesioners where user is already a respondent from recommendations
            if (alreadyRespondent) {
              return false;
            }

            // Check if user is the creator
            final String userId = data['userId'] as String? ?? '';
            final bool isCreator = currentUid.isNotEmpty && currentUid == userId;

            // Exclude kuesioners created by the user from recommendations
            if (isCreator) {
              return false;
            }

            // Match demographic criteria
            final bool usiaMatch = match(data['rentangUsia'], usia);
            final bool kelaminMatch = match(data['jenisKelamin'], kelamin);
            final bool penghasilanMatch = match(data['tingkatPenghasilan'], penghasilan);
            final bool pendidikanMatch = match(data['pendidikanTerakhir'], pendidikan);

            final bool allMatch = usiaMatch && kelaminMatch && penghasilanMatch && pendidikanMatch;

            // Debug logging (can be removed in production)
            if (!allMatch) {
              print('Kuesioner ${doc.id} filtered out:');
              print('  Usia: ${data['rentangUsia']} vs $usia -> $usiaMatch');
              print('  Kelamin: ${data['jenisKelamin']} vs $kelamin -> $kelaminMatch');
              print('  Penghasilan: ${data['tingkatPenghasilan']} vs $penghasilan -> $penghasilanMatch');
              print('  Pendidikan: ${data['pendidikanTerakhir']} vs $pendidikan -> $pendidikanMatch');
            }

            return allMatch;
          })
          .map((doc) {
            return Kuesioner.fromJson(doc.data(), doc.id);
          })
          .toList();

      // Sort by newest (most recent first)
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      kuesionerList.value = filtered;
    } catch (_) {
      // fallback to dummy if collection doesn't exist
      kuesionerList.value = dummyKuesioner;
    }
  }

  Future<void> loadCreatedByMe() async {
    try {
      await _ensureSignedIn();
      final String uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        createdByMeList.clear();
        return;
      }
      final snapshot = await _firestore.collection('kuesioners').where('userId', isEqualTo: uid).get();
      final items = snapshot.docs.map((doc) {
        return Kuesioner.fromJson(doc.data(), doc.id);
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
        return Kuesioner.fromJson(doc.data(), doc.id);
      }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      signedByMeList.value = items;
    } catch (_) {
      signedByMeList.clear();
    }
  }
}

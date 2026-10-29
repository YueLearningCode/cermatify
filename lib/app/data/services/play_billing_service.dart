import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

bool get usesGooglePlayBilling =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Google is the payment authority. Only a verified backend creates paid orders.
/// The stream remains alive across checkout navigation and account sessions.
class PlayBillingService extends GetxService {
  final message = ''.obs;
  final busy = false.obs;
  final lastVerifiedOrderId = ''.obs;
  final _store = InAppPurchase.instance;
  final _functions = FirebaseFunctions.instanceFor(region: 'asia-southeast2');
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  StreamSubscription<User?>? _authSubscription;
  final _processing = <String>{};

  @override
  void onInit() {
    super.onInit();
    if (!usesGooglePlayBilling) return;
    _subscription = _store.purchaseStream.listen(
      (purchases) async {
        for (final purchase in purchases) {
          await _handle(purchase);
        }
      },
      onError: (_) {
        busy.value = false;
        message.value =
            'Pembayaran belum dapat diperiksa. Coba periksa pembelian lagi.';
      },
    );
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      lastVerifiedOrderId.value = '';
      message.value = '';
      if (user != null && !user.isAnonymous) unawaited(recover());
    });
  }

  Future<String> prepareProduct(Map<String, dynamic> selection) async {
    if (!await _store.isAvailable()) {
      throw StateError('Google Play belum tersedia pada perangkat ini.');
    }
    final result = await _functions
        .httpsCallable('preparePlayPurchase')
        .call({...selection, 'quoteOnly': true});
    final data = Map<String, dynamic>.from(result.data as Map);
    return data['productId'] as String;
  }

  Future<void> buy(Map<String, dynamic> selection) async {
    if (busy.value) return;
    busy.value = true;
    message.value = '';
    lastVerifiedOrderId.value = '';
    try {
      if (!await _store.isAvailable()) {
        throw StateError('Google Play tidak tersedia.');
      }
      final result = await _functions
          .httpsCallable('preparePlayPurchase')
          .call(selection);
      final data = Map<String, dynamic>.from(result.data as Map);
      final response = await _store.queryProductDetails({
        data['productId'] as String,
      });
      if (response.error != null || response.productDetails.length != 1) {
        throw StateError('Produk belum tersedia di Google Play.');
      }
      final started = await _store.buyConsumable(
        purchaseParam: GooglePlayPurchaseParam(
          productDetails: response.productDetails.single,
          applicationUserName: data['accountId'] as String,
          obfuscatedProfileId: data['intentId'] as String,
        ),
        autoConsume: false,
      );
      if (!started) throw StateError('Pembayaran belum dimulai.');
      message.value =
          'Selesaikan pembayaran di Google Play. Pesanan diproses setelah terverifikasi.';
    } catch (_) {
      busy.value = false;
      message.value =
          'Pembayaran belum dapat dimulai. Silakan coba lagi atau hubungi bantuan. Jangan melakukan pembayaran ulang jika sebelumnya sudah ditagih.';
    }
  }

  Future<void> recover() async {
    try {
      if (await _store.isAvailable()) await _store.restorePurchases();
    } catch (_) {
      message.value =
          'Pembelian belum dapat diperiksa. Periksa koneksi dan coba lagi.';
    }
  }

  Future<void> _handle(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.pending) {
      message.value =
          'Pembayaran menunggu penyelesaian. Pesanan belum diaktifkan.';
      busy.value = false;
      return;
    }
    if (purchase.status == PurchaseStatus.canceled ||
        purchase.status == PurchaseStatus.error) {
      busy.value = false;
      message.value =
          'Pembayaran dibatalkan atau belum berhasil. Periksa riwayat Google Play sebelum mencoba lagi.';
      return;
    }
    if (purchase.status != PurchaseStatus.purchased &&
        purchase.status != PurchaseStatus.restored) {
      return;
    }
    final token = purchase.verificationData.serverVerificationData;
    if (FirebaseAuth.instance.currentUser == null || !_processing.add(token)) {
      return;
    }
    try {
      final result = await _functions.httpsCallable('verifyPlayPurchase').call({
        'productId': purchase.productID,
        'purchaseToken': token,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      if (data['verified'] != true) throw StateError('Belum terverifikasi');
      // The backend has atomically persisted the entitlement and consumed it.
      // Do not client-consume or acknowledge an unverified purchase.
      lastVerifiedOrderId.value = data['orderId'] as String;
      message.value =
          'Pembayaran terverifikasi. Pesanan tersedia di riwayat pesanan.';
    } catch (_) {
      message.value =
          'Pembayaran belum dapat diverifikasi. Jangan bayar ulang; gunakan Periksa pembelian atau hubungi bantuan.';
    } finally {
      _processing.remove(token);
      busy.value = false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }
}

import 'dart:io';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';

class OrderController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Konfigurasi Cloudinary untuk upload gambar
  final cloudinary = Cloudinary.signedConfig(
    apiKey: '885241489685565',
    apiSecret: 'Eo2Man-3sLzp9sCyYwslSXZFFtQ',
    cloudName: 'dvxsmpz3m',
  );

  final isLoading = false.obs;
  final paymentProofImage = Rxn<File>();
  final paymentProofUrl = ''.obs;

  // Create order with payment proof
  // Returns orderId as String if successful, empty string if failed
  Future<String> createOrder({
    required String mentorId,
    required String layananId,
    required int price,
    String? layananType,
  }) async {
    try {
      if (paymentProofImage.value == null) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Please upload payment proof',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return '';
      }

      isLoading.value = true;

      final User? user = _auth.currentUser;
      if (user == null) {
        CustomSnackbar.show(
          title: 'Error',
          message: 'User tidak ditemukan',
          backgroundColor: AppColors.redColor,
          isNav: false,
        );
        return '';
      }

      // Upload payment proof image to Cloudinary
      final File imageFile = paymentProofImage.value!;
      if (!imageFile.existsSync()) {
        throw Exception('File does not exist');
      }

      final cloudinaryResponse = await cloudinary.upload(
        fileBytes: imageFile.readAsBytesSync(),
        fileName: 'payment_proof_${user.uid}_${DateTime.now().millisecondsSinceEpoch}',
        resourceType: CloudinaryResourceType.image,
      );

      final String? secureUrl = cloudinaryResponse.secureUrl;
      if (secureUrl == null) {
        throw Exception('Failed to get image URL from Cloudinary');
      }

      // Get layanan type from layananId if not provided
      String? finalLayananType = layananType;
      if (finalLayananType == null || finalLayananType.isEmpty) {
        try {
          final layananDoc = await _firestore.collection('layanan').doc(layananId).get();
          if (layananDoc.exists) {
            final layananData = layananDoc.data();
            finalLayananType = layananData?['type']?.toString();
          }
        } catch (e) {
          print('Error fetching layanan type: $e');
        }
      }

      // Create order document in Firestore
      final orderData = {
        'userId': user.uid,
        'mentorId': mentorId,
        'layananId': layananId,
        'layananType': finalLayananType, // Store layanan type (paperlink/complink)
        'price': price,
        'paymentProofUrl': secureUrl,
        'status': 'waiting verification', // waiting verification, progress, rejected, completed
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final DocumentReference orderRef = await _firestore.collection('orders').add(orderData);

      // Return orderId for chat room creation
      return orderRef.id;
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to create order: ${e.toString()}',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
      return '';
    } finally {
      isLoading.value = false;
    }
  }

  // Pick payment proof image
  Future<void> pickPaymentProofImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile != null) {
        paymentProofImage.value = File(pickedFile.path);
        paymentProofUrl.value = ''; // Clear previous URL if any
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to pick image: ${e.toString()}',
        backgroundColor: AppColors.redColor,
        isNav: false,
      );
    }
  }

  // Remove payment proof image
  void removePaymentProofImage() {
    paymentProofImage.value = null;
    paymentProofUrl.value = '';
  }

  @override
  void onClose() {
    paymentProofImage.value = null;
    super.onClose();
  }
}

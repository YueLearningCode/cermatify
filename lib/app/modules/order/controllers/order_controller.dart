import 'package:cermatify/app/data/services/app_logger.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cermatify/app/data/models/selected_image_data.dart';
import 'package:cermatify/app/data/services/media_upload_service.dart';
import 'package:cermatify/app/data/widgets/custom_snackbar.dart';
import 'package:cermatify/app/data/theme/app_colors.dart';

class OrderController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final MediaUploadService _mediaUploadService = MediaUploadService();

  final isLoading = false.obs;
  final paymentProofImage = Rxn<SelectedImageData>();
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
      final image = paymentProofImage.value!;

      final secureUrl = await _mediaUploadService.uploadImage(
        bytes: image.bytes,
        filename: 'payment_proof_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.${image.extension}',
      );

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
          AppLogger.info('Error fetching layanan type: $e');
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
        paymentProofImage.value = await SelectedImageData.fromXFile(pickedFile);
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

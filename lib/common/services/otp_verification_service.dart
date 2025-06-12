import 'package:cloud_firestore/cloud_firestore.dart';

class OTPVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> verifyOtp({
    required String userId,
    required String enteredOtp,
  }) async {
    final userDoc = await _firestore.collection('User').doc(userId).get();

    if (!userDoc.exists) throw Exception("Tài khoản không tồn tại");

    final data = userDoc.data()!;
    final storedOtp = data['otp'];
    final createdAt = (data['otp_created_at'] as Timestamp).toDate();
    final now = DateTime.now();

    if (now.difference(createdAt).inMinutes > 5) {
      throw Exception("Mã OTP đã hết hạn");
    }

    if (enteredOtp == storedOtp) {
      await _firestore.collection('User').doc(userId).update({
        'status': true,
        'otp': FieldValue.delete(),
        'otp_created_at': FieldValue.delete(),
      });
      return true;
    } else {
      return false;
    }
  }
}
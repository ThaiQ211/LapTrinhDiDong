import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _firebaseWebApiKey =
      'AIzaSyAYrsNelma32WkMd4hRcnBx2tcPvIYJyjw';

  String _generateOtp() {
    final rng = Random();
    return (100000 + rng.nextInt(900000)).toString();
  }

  String _generateCompanyCode({int length = 6}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand =
        DateTime.now().millisecondsSinceEpoch
            .toString()
            .split('')
            .reversed
            .toList();
    return List.generate(length, (index) {
      final i =
          DateTime.now().millisecondsSinceEpoch +
          index +
          rand[index % rand.length].codeUnitAt(0);
      return chars[i % chars.length];
    }).join();
  }

  Future<UserCredential> registerUser({
    required String email,
    required String password,
    required String fullname,
    required String phone,
    required String address,
    required String username,
  }) async {
    try {
      final otp = _generateOtp();
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userId = userCredential.user?.uid;

      await _firestore.collection('User').doc(userId).set({
        'id': userId,
        'email': email,
        'role': 'employee',
        'pin': null,
        'status': false,
        'otp': otp,
        'otp_created_at': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('UserInfo').add({
        'userId': userId,
        'fullname': fullname,
        'phone': phone,
        'address': address,
        'username': username,
        'companyId': [],
      });

      await _sendOtpToEmail(email, otp);
      print("✅ Đăng ký user thành công, đã gửi OTP đến $email");
      return userCredential;
    } catch (e) {
      throw Exception("Đăng ký thất bại: $e");
    }
  }

  Future<UserCredential> registerBusinessUser({
    required String email,
    required String password,
    required String fullname,
    required String phone,
    required String address,
    required String username,
    required String companyName,
    required String companyLocation,
    required String companySector,
  }) async {
    try {
      final otp = _generateOtp();
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userId = userCredential.user?.uid;

      await _firestore.collection('User').doc(userId).set({
        'id': userId,
        'email': email,
        'role': 'manager',
        'pin': null,
        'status': false,
        'otp': otp,
        'otp_created_at': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
      });

      String code = '';
      bool isUnique = false;

      while (!isUnique) {
        code = _generateCompanyCode();
        final existing =
            await _firestore
                .collection('Company')
                .where('code', isEqualTo: code)
                .limit(1)
                .get();
        if (existing.docs.isEmpty) isUnique = true;
      }

      final companyRef = _firestore.collection('Company').doc();
      await companyRef.set({
        'id': companyRef.id,
        'name': companyName,
        'ownerId': userId,
        'location': companyLocation,
        'sector': companySector,
        'status': false,
        'code': code,
      });

      await _firestore.collection('UserInfo').add({
        'userId': userId,
        'fullname': fullname,
        'phone': phone,
        'address': address,
        'username': username,
        'companyId': [companyRef.id],
      });

      await _sendOtpToEmail(email, otp);
      print("✅ Đăng ký doanh nghiệp thành công, đã gửi OTP đến $email");
      return userCredential;
    } catch (e) {
      throw Exception("Đăng ký doanh nghiệp thất bại: $e");
    }
  }

  Future<void> _sendOtpToEmail(String email, String otp) async {
    final smtpServer = gmail(
      'emangafromnowhere@gmail.com',
      'mepw svle wbqs qyei',
    );

    final message =
        Message()
          ..from = Address('emangafromnowhere@gmail.com', 'Nexore App')
          ..recipients.add(email)
          ..subject = 'Mã OTP xác thực tài khoản'
          ..text =
              'Xin chào,\n\nMã OTP xác thực tài khoản của bạn là: $otp\n'
              'Vui lòng sử dụng mã này trong vòng 5 phút.\n\n'
              'Trân trọng,\nĐội ngũ Nexore';

    try {
      final sendReport = await send(message, smtpServer);
      print('📧 Gửi OTP thành công: ' + sendReport.toString());
    } catch (e) {
      print('❌ Gửi OTP thất bại: $e');
      throw Exception("Không thể gửi email xác thực: $e");
    }
  }

  Future<User?> login_temp(String email, String password) async {
    try {
      final dynamic result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      dynamic possibleUser;
      if (result is UserCredential) {
        possibleUser = result;
      } else if (result is List) {
        for (final item in result) {
          if (item is UserCredential) {
            possibleUser = item;
            break;
          } else if (item is Map && item.containsKey('user')) {
            possibleUser = item['user'];
            break;
          }
        }
      } else {
        possibleUser = null;
      }

      // Ép kiểu an toàn từ result
      final user =
          possibleUser is UserCredential
              ? possibleUser.user
              : possibleUser is User
              ? possibleUser
              : null;

      if (user == null) {
        throw Exception('Không thể xác định người dùng sau khi đăng nhập.');
      }

      final userDoc = await _firestore.collection('User').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final role = userData['role'];

        if (['superadmin', 'manager', 'leader', 'employee'].contains(role)) {
          return user;
        } else {
          throw Exception('Tài khoản không có vai trò hợp lệ.');
        }
      } else {
        throw Exception('Tài khoản không tồn tại trong hệ thống.');
      }
    } catch (e, stack) {
      print("❌ Login exception: $e");
      print("📌 Stacktrace: $stack");
      throw Exception('Đăng nhập thất bại from service: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> login(
    String emailInput,
    String password,
  ) async {
    try {
      final uri = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_firebaseWebApiKey',
      );

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailInput,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final Map<String, dynamic> body = json.decode(res.body);

      if (body['error'] != null) {
        print('❌ Lỗi Firebase REST: ${body['error']}');
        throw Exception(body['error']['message']);
      }

      final String uid = body['localId'];
      final String email = body['email'];

      print('✅ Đăng nhập Firebase thành công');
      print('   🔹 UID: $uid');
      print('   🔹 Email: $email');

      final userSnap =
          await FirebaseFirestore.instance.collection('User').doc(uid).get();

      if (!userSnap.exists) {
        print('❌ Không tìm thấy user trong Firestore (User/$uid)');
        throw Exception('Tài khoản không tồn tại trong hệ thống.');
      }

      final userData = userSnap.data()!;
      final String role = userData['role'];

      print('👤 Dữ liệu từ Firestore:');
      print('   🔹 Role: $role');
      print('   🔹 Full userData: $userData');

      if (!['superadmin', 'manager', 'leader', 'employee'].contains(role)) {
        throw Exception('Tài khoản không có vai trò hợp lệ.');
      }

      return {'uid': uid, 'email': email, 'role': role};
    } catch (e) {
      print('❌ Lỗi AuthService.login: $e');
      throw Exception('Đăng nhập thất bại từ REST API: $e');
    }
  }
}

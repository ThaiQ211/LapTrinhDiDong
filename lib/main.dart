import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 Thêm dòng này
import 'package:new_task_management/app/auth/login.dart';
import 'package:new_task_management/app/auth/otp_verification.dart';
import 'package:new_task_management/app/super/home_super.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print("🔵 Firebase đã được khởi tạo");

  // ✅ Tắt cache Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );
  print("⚙️ Firestore persistence đã bị tắt (chạy online hoàn toàn)");

  // ✅ Sign out current user (nếu tồn tại)
  try {
    await FirebaseAuth.instance.signOut();
    print("🚫 Đã signOut currentUser (xóa session login cũ nếu có)");
  } catch (e) {
    print("⚠️ Lỗi khi signOut: $e");
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    print("❌ Bắt được lỗi toàn cục:");
    print(details.exception);
    print(details.stack);
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/superadmin': (context) => HomeSuperAdmin(),
        '/verify-otp': (context) => OTPVerificationScreen(
          userId: '',
          email: '',
        ),
      },
    );
  }
}
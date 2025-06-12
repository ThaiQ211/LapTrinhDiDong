import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_task_management/app/auth/otp_verification.dart';
import 'package:new_task_management/app/auth/widget/register_form.dart';
import 'package:new_task_management/app/auth/business_register.dart';
import '../../common/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullnameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final usernameController = TextEditingController();

  Future<void> register(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final fullname = fullnameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final username = usernameController.text.trim();

    if (email.isNotEmpty &&
        password.isNotEmpty &&
        password == confirmPassword &&
        fullname.isNotEmpty &&
        phone.isNotEmpty &&
        address.isNotEmpty &&
        username.isNotEmpty) {
      try {
        final userCredential = await AuthService().registerUser(
          email: email,
          password: password,
          fullname: fullname,
          phone: phone,
          address: address,
          username: username,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              userId: userCredential.user!.uid,
              email: email,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đúng thông tin và xác nhận mật khẩu'),
        ),
      );
    }
  }

  void goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB3E5FC),
            Color(0xFFB2EBF2),
            Color(0xFFB2DFDB),
            Color(0xFFC8E6C9),
            Color(0xFFB2DFDB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Đăng Ký'),
            actions: [
              IconButton(
                icon: const Icon(Icons.business),
                tooltip: 'Đăng ký tài khoản doanh nghiệp',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BusinessRegisterPage()),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: RegisterForm(
              emailController: emailController,
              passwordController: passwordController,
              confirmPasswordController: confirmPasswordController,
              fullnameController: fullnameController,
              phoneController: phoneController,
              addressController: addressController,
              usernameController: usernameController,
              onSubmit: () => register(context),
              onGoToLogin: goToLogin,
            ),
          ),
        ],
      ),
    ),
  );
}
}
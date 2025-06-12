import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_task_management/app/auth/otp_verification.dart';
import 'package:new_task_management/common/services/auth_service.dart';
import 'package:new_task_management/app/auth/widget/business_register_form.dart';

class BusinessRegisterPage extends StatefulWidget {
  @override
  State<BusinessRegisterPage> createState() => _BusinessRegisterPageState();
}

class _BusinessRegisterPageState extends State<BusinessRegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullnameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final usernameController = TextEditingController();
  final companyNameController = TextEditingController();
  final companyLocationController = TextEditingController();
  final companySectorController = TextEditingController();

  Future<void> registerBusiness(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final fullname = fullnameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final username = usernameController.text.trim();
    final companyName = companyNameController.text.trim();
    final companyLocation = companyLocationController.text.trim();
    final companySector = companySectorController.text.trim();

    if (email.isNotEmpty &&
        password.isNotEmpty &&
        password == confirmPassword &&
        fullname.isNotEmpty &&
        phone.isNotEmpty &&
        address.isNotEmpty &&
        username.isNotEmpty &&
        companyName.isNotEmpty &&
        companyLocation.isNotEmpty &&
        companySector.isNotEmpty) {
      try {
        final userCredential = await AuthService().registerBusinessUser(
          email: email,
          password: password,
          fullname: fullname,
          phone: phone,
          address: address,
          username: username,
          companyName: companyName,
          companyLocation: companyLocation,
          companySector: companySector,
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
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng Ký Tài Khoản Doanh Nghiệp')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: BusinessRegisterForm(
            emailController: emailController,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
            fullnameController: fullnameController,
            phoneController: phoneController,
            addressController: addressController,
            usernameController: usernameController,
            companyNameController: companyNameController,
            companyLocationController: companyLocationController,
            companySectorController: companySectorController,
            onSubmit: () => registerBusiness(context),
          ),
        ),
      ),
    );
  }
}

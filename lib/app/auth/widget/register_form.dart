import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController fullnameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController usernameController;
  final VoidCallback onSubmit;
  final VoidCallback onGoToLogin;

  const RegisterForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.fullnameController,
    required this.phoneController,
    required this.addressController,
    required this.usernameController,
    required this.onSubmit,
    required this.onGoToLogin,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool obscurePassword = true;
  bool obscureConfirm = true;

InputDecoration _buildInputDecoration(String label, IconData icon,
    {bool isPassword = false, VoidCallback? toggleObscure}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.black87),
    floatingLabelStyle: const TextStyle(color: Colors.teal),
    border: const OutlineInputBorder(),
    prefixIcon: Icon(icon, color: Colors.teal),
    suffixIcon: isPassword
        ? IconButton(
            icon: Icon(
              (label.contains('Xác'))
                  ? (obscureConfirm ? Icons.visibility_off : Icons.visibility)
                  : (obscurePassword ? Icons.visibility_off : Icons.visibility),
              color: Colors.teal,
            ),
            onPressed: toggleObscure,
          )
        : null,
  );
}


  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Group 1: Account Info
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Thông tin tài khoản',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: widget.emailController,
                        decoration: _buildInputDecoration('Email', Icons.email),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: widget.passwordController,
                        obscureText: obscurePassword,
                        decoration: _buildInputDecoration(
                          'Mật khẩu',
                          Icons.lock,
                          isPassword: true,
                          toggleObscure: () =>
                              setState(() => obscurePassword = !obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: widget.confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: _buildInputDecoration(
                          'Xác nhận mật khẩu',
                          Icons.lock_outline,
                          isPassword: true,
                          toggleObscure: () =>
                              setState(() => obscureConfirm = !obscureConfirm),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Group 2: Personal Info
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Thông tin cá nhân',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: widget.fullnameController,
                        decoration: _buildInputDecoration('Họ và tên', Icons.person),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: widget.phoneController,
                        decoration: _buildInputDecoration('Số điện thoại', Icons.phone),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: widget.addressController,
                        decoration: _buildInputDecoration('Địa chỉ', Icons.home),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: widget.usernameController,
                        decoration: _buildInputDecoration('Tên người dùng', Icons.account_circle),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.app_registration),
                  label: const Text('Đăng ký'),
                  onPressed: widget.onSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: widget.onGoToLogin,
                child: const Text(
                  'Quay lại Đăng nhập',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

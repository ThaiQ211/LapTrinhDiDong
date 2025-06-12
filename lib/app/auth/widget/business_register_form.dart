import 'package:flutter/material.dart';

class BusinessRegisterForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController fullnameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController usernameController;
  final TextEditingController companyNameController;
  final TextEditingController companyLocationController;
  final TextEditingController companySectorController;
  final VoidCallback onSubmit;

  const BusinessRegisterForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.fullnameController,
    required this.phoneController,
    required this.addressController,
    required this.usernameController,
    required this.companyNameController,
    required this.companyLocationController,
    required this.companySectorController,
    required this.onSubmit,
  });

  @override
  State<BusinessRegisterForm> createState() => _BusinessRegisterFormState();
}

class _BusinessRegisterFormState extends State<BusinessRegisterForm> {
  bool obscurePassword = true;
  bool obscureConfirm = true;

  InputDecoration _buildInput(String label, IconData icon,
      {bool isPassword = false, VoidCallback? toggle}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      floatingLabelStyle: const TextStyle(color: Colors.teal),
      border: const OutlineInputBorder(),
      prefixIcon: Icon(icon, color: Colors.teal),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                label.contains('Xác')
                    ? (obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility)
                    : (obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                color: Colors.teal,
              ),
              onPressed: toggle,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  '👤 Thông tin cá nhân',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: widget.emailController,
                  decoration: _buildInput('Email', Icons.email),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widget.passwordController,
                  obscureText: obscurePassword,
                  decoration: _buildInput(
                    'Mật khẩu',
                    Icons.lock,
                    isPassword: true,
                    toggle: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widget.confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: _buildInput(
                    'Xác nhận mật khẩu',
                    Icons.lock_outline,
                    isPassword: true,
                    toggle: () =>
                        setState(() => obscureConfirm = !obscureConfirm),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widget.fullnameController,
                  decoration: _buildInput('Họ và tên', Icons.person),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widget.phoneController,
                  decoration: _buildInput('Số điện thoại', Icons.phone),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widget.addressController,
                  decoration: _buildInput('Địa chỉ', Icons.home),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widget.usernameController,
                  decoration: _buildInput('Tên người dùng', Icons.account_circle),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  '🏢 Thông tin công ty',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: widget.companyNameController,
                  decoration: _buildInput('Tên công ty', Icons.business),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widget.companyLocationController,
                  decoration:
                      _buildInput('Địa điểm công ty', Icons.location_on),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widget.companySectorController,
                  decoration:
                      _buildInput('Lĩnh vực hoạt động', Icons.work_outline),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onSubmit,
            icon: const Icon(Icons.app_registration),
            label: const Text('Đăng ký tài khoản doanh nghiệp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

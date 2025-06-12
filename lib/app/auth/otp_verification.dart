import 'package:flutter/material.dart';
import 'package:new_task_management/common/services/otp_verification_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String userId;
  final String email;

  const OTPVerificationScreen({
    Key? key,
    required this.userId,
    required this.email,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final service = OTPVerificationService();
    try {
      final success = await service.verifyOtp(
        userId: widget.userId,
        enteredOtp: _otpController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        _message = success ? '✅ Xác thực thành công!' : '❌ Mã OTP không chính xác.';
      });

      if (success) {
        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = '${e.toString()}';
      });
    }
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_person, size: 48, color: Colors.teal),
                    const SizedBox(height: 12),
                    Text(
                      'Xác Thực Tài Khoản',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "🔐 Nhập mã OTP đã gửi đến:",
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    Text(
                      widget.email,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Mã OTP',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.verified),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _verifyOtp,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Xác Thực'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                    if (_message.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _message.contains('thành công')
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

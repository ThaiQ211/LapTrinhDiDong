import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../common/services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  final String uid;

  const SettingsPage({super.key, required this.uid});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  String fullname = '';
  String phone = '';
  String address = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('UserInfo')
        .where('userId', isEqualTo: widget.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        fullname = data['fullname'] ?? '';
        phone = data['phone'] ?? '';
        address = data['address'] ?? '';
        isLoading = false;
      });
    }
  }

  Future<void> updateUserInfo() async {
    if (!_formKey.currentState!.validate()) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('UserInfo')
        .where('userId', isEqualTo: widget.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('UserInfo')
          .doc(snapshot.docs.first.id)
          .update({
        'fullname': fullname,
        'phone': phone,
        'address': address,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Cập nhật thành công')),
      );
    }
  }

  Future<void> logout() async {
    try {
      await AuthService().logout();
      await FirebaseAuth.instance.signOut();
      await FirebaseFirestore.instance.clearPersistence();
      debugPrint("Đã signOut và xóa cache Firestore");
    } catch (e) {
      debugPrint("Lỗi khi đăng xuất: $e");
    }

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt'),
        backgroundColor: const Color.fromARGB(255, 37, 125, 225),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: fullname,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => fullname = val,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Không được để trống'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => phone = val,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Không được để trống'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: address,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => address = val,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Không được để trống'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: updateUserInfo,
                        icon: const Icon(Icons.save),
                        label: const Text('Lưu thay đổi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 37, 125, 225),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Đăng xuất',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

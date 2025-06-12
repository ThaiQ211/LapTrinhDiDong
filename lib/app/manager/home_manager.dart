import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_task_management/app/widgets/main_scaffold.dart';
import 'package:new_task_management/app/manager/company_detail_page.dart';

class HomeManager extends StatefulWidget {
  final String uid; // ✅ Nhận uid từ LoginPage

  const HomeManager({super.key, required this.uid});

  @override
  State<HomeManager> createState() => _HomeManagerState();
}

class _HomeManagerState extends State<HomeManager> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> companies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  Future<void> fetchCompanies() async {
    final uid = widget.uid; // ✅ Dùng uid truyền vào
    print('📌 Fetch công ty cho managerId: $uid');

    try {
      final snap = await FirebaseFirestore.instance
          .collection('Company')
          .where('ownerId', isEqualTo: uid)
          .get();

      final data = snap.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .cast<Map<String, dynamic>>()
          .toList();

      setState(() {
        companies = data;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Lỗi khi fetch công ty: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      role: 'Manager',
      uid: widget.uid,
      currentIndex: _selectedIndex,
      onTabChanged: (index) {
        setState(() => _selectedIndex = index);
      },
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (companies.isEmpty) {
      return const Center(child: Text('❗Bạn chưa sở hữu công ty nào.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: companies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final c = companies[index];
        return Card(
          elevation: 4,
          child: ListTile(
            leading: const Icon(Icons.business, size: 40, color: Colors.blue),
            title: Text(
              c['name'] ?? 'Tên không rõ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              c['status'] == true ? '✅ Đã được duyệt' : '⏳ Chờ duyệt',
              style: TextStyle(
                color: c['status'] == true ? Colors.green : Colors.orange,
              ),
            ),
            onTap: () {
              if (c['status'] == true) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompanyDetailPage(companyData: c),
                    settings: RouteSettings(arguments: c),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⏳ Công ty này chưa được duyệt.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}

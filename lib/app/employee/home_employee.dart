import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_task_management/app/employee/company/company_detail.dart';
import '../../common/services/auth_service.dart';
import '../widgets/main_scaffold.dart';

class HomeEmployee extends StatefulWidget {
  final String uid;

  const HomeEmployee({super.key, required this.uid});

  @override
  State<HomeEmployee> createState() => _HomeEmployeeState();
}

class _HomeEmployeeState extends State<HomeEmployee> {
  int _selectedIndex = 0;
  final TextEditingController _codeController = TextEditingController();
  List<Map<String, dynamic>> joinedCompanies = [];
  List<Map<String, dynamic>> pendingRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    final userId = widget.uid;

    final userInfoSnap = await FirebaseFirestore.instance
        .collection('UserInfo')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    final Map<String, dynamic> rawCompanyMap = userInfoSnap.docs.isNotEmpty
        ? Map<String, dynamic>.from(
            userInfoSnap.docs.first.data()['companyId'] ?? {},
          )
        : {};

    final approvedIds = rawCompanyMap.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    final List<Map<String, dynamic>> approvedCompanies = approvedIds.isNotEmpty
        ? (await FirebaseFirestore.instance
                .collection('Company')
                .where(FieldPath.documentId, whereIn: approvedIds)
                .get())
            .docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList()
            .cast<Map<String, dynamic>>()
        : [];

    final pendingIds = rawCompanyMap.entries
        .where((entry) => entry.value != true)
        .map((entry) => entry.key)
        .toList();

    final List<Map<String, dynamic>> pendingCompanies = pendingIds.isNotEmpty
        ? (await FirebaseFirestore.instance
                .collection('Company')
                .where(FieldPath.documentId, whereIn: pendingIds)
                .get())
            .docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList()
            .cast<Map<String, dynamic>>()
        : [];

    setState(() {
      joinedCompanies = approvedCompanies;
      pendingRequests = pendingCompanies;
      isLoading = false;
    });
  }

  Future<void> submitJoinRequest() async {
    final code = _codeController.text.trim().toUpperCase();
    final userId = widget.uid;
    if (code.isEmpty) return;

    final companyQuery = await FirebaseFirestore.instance
        .collection('Company')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

    if (companyQuery.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Mã công ty không tồn tại')),
      );
      return;
    }

    final companyId = companyQuery.docs.first.id;

    final existing = await FirebaseFirestore.instance
        .collection('JoinRequest')
        .where('userId', isEqualTo: userId)
        .where('companyId', isEqualTo: companyId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Bạn đã gửi yêu cầu rồi')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('JoinRequest').add({
      'userId': userId,
      'companyId': companyId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _codeController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã gửi yêu cầu chờ duyệt')),
    );
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      role: 'employee',
      uid: widget.uid,
      currentIndex: _selectedIndex,
      onTabChanged: (index) {
        setState(() => _selectedIndex = index);
      },
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔍 Nhập mã công ty để yêu cầu tham gia:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập mã công ty...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                ),
              ),
              const SizedBox(width: 10),
             ElevatedButton.icon(
                onPressed: submitJoinRequest,
                icon: const Icon(Icons.send),
                label: const Text('Tham gia', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 37, 125, 225),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '✅ Công ty đã tham gia:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (joinedCompanies.isNotEmpty)
                          ...joinedCompanies.map(
                            (c) => Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(c['name']),
                                subtitle: Text('Lĩnh vực: ${c['sector']}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EmployeeCompanyDetailPage(
                                        uid: widget.uid,
                                        company: c,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        else
                          const Text('Bạn chưa tham gia công ty nào.'),
                        const SizedBox(height: 20),
                        const Text(
                          '⏳ Yêu cầu đang chờ duyệt:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (pendingRequests.isNotEmpty)
                          ...pendingRequests.map(
                            (c) => Card(
                              color: Colors.orange.shade50,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.timelapse, color: Colors.orange),
                                title: Text(c['name']),
                                subtitle: const Text('Đang chờ quản lý duyệt'),
                              ),
                            ),
                          )
                        else
                          const Text('Không có yêu cầu nào đang chờ'),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

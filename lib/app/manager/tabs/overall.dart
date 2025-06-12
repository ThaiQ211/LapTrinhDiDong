import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OverallTab extends StatefulWidget {
  final Map<String, dynamic> companyData;

  const OverallTab({super.key, required this.companyData});

  @override
  State<OverallTab> createState() => _OverallTabState();
}

class _OverallTabState extends State<OverallTab> {
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    final snap = await FirebaseFirestore.instance
        .collection('JoinRequest')
        .where('companyId', isEqualTo: widget.companyData['id'])
        .where('status', isEqualTo: 'pending')
        .get();

    final data = await Future.wait(snap.docs.map((doc) async {
      final userId = doc['userId'];
      final userSnap = await FirebaseFirestore.instance
          .collection('UserInfo')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      final userData = userSnap.docs.isNotEmpty ? userSnap.docs.first.data() : {};
      return {
        'requestId': doc.id,
        'userId': userId,
        'fullname': userData['fullname'] ?? '',
        'username': userData['username'] ?? '',
      };
    }));

    setState(() {
      requests = data;
      isLoading = false;
    });
  }

  Future<void> approve(String requestId, String userId) async {
    await FirebaseFirestore.instance.collection('JoinRequest').doc(requestId).update({
      'status': 'approved',
    });

    final userSnap = await FirebaseFirestore.instance
        .collection('UserInfo')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (userSnap.docs.isNotEmpty) {
      final ref = userSnap.docs.first.reference;
      final existing = userSnap.docs.first.data();
      Map<String, dynamic> currentCompanies = {};

      if (existing['companyId'] is Map<String, dynamic>) {
        currentCompanies = Map<String, dynamic>.from(existing['companyId']);
      }

      currentCompanies[widget.companyData['id']] = true;

      await ref.update({'companyId': currentCompanies});
    }

    await fetchRequests();
  }

  Future<void> reject(String requestId) async {
    await FirebaseFirestore.instance.collection('JoinRequest').doc(requestId).delete();
    await fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.companyData['name']?.toString() ?? 'Không rõ';
    final location = widget.companyData['location']?.toString() ?? 'Không rõ';
    final sector = widget.companyData['sector']?.toString() ?? 'Không rõ';
    final isApproved = widget.companyData['status'] == true;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('🏢 $name', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('📍 Địa điểm: $location'),
        const SizedBox(height: 8),
        Text('💼 Lĩnh vực: $sector'),
        const SizedBox(height: 8),
        Text(
          isApproved ? '✅ Trạng thái: Đã duyệt' : '⏳ Trạng thái: Chờ duyệt',
          style: TextStyle(
            color: isApproved ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        const Text('📩 Yêu cầu tham gia công ty:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (isLoading)
          const CircularProgressIndicator()
        else if (requests.isEmpty)
          const Text('📭 Không có yêu cầu nào đang chờ duyệt.')
        else
          ...requests.map((r) => Card(
                child: ListTile(
                  title: Text(r['fullname']),
                  subtitle: Text('@${r['username']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => approve(r['requestId'], r['userId']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => reject(r['requestId']),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}
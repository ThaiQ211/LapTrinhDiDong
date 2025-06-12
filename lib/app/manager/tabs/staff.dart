import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_task_management/app/manager/create_team.dart';
import 'package:new_task_management/app/manager/team_list.dart';

class Staff extends StatefulWidget {
  final Map<String, dynamic> companyData;
  const Staff({super.key, required this.companyData});

  @override
  State<Staff> createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  int total = 0;
  int leaders = 0;
  int employees = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    final companyId = widget.companyData['id'];

    final userInfoSnap = await FirebaseFirestore.instance
        .collection('UserInfo')
        .where('companyId.$companyId', isEqualTo: true)
        .get();

    final userIds = userInfoSnap.docs.map((doc) => doc['userId'] as String).toList();
    total = userIds.length;

    int tempLeaders = 0;
    int tempEmployees = 0;

    if (userIds.isNotEmpty) {
      final userSnap = await FirebaseFirestore.instance
          .collection('User')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      for (var doc in userSnap.docs) {
        final role = doc['role'];
        if (role == 'leader') tempLeaders++;
        if (role == 'employee') tempEmployees++;
      }
    }

    setState(() {
      leaders = tempLeaders;
      employees = tempEmployees;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final companyId = widget.companyData['id']?.toString() ?? '';

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('📊 Thống kê nhân sự', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('👥 Tổng số nhân sự: $total'),
              Text('🧑‍💼 Leader: $leaders'),
              Text('👨‍🔧 Employee: $employees'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('👥 Các team trong công ty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo team'),
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => CreateTeam(companyId: companyId),
                      );
                      fetchCounts();
                      setState(() {});
                    },
                  )
                ],
              ),
              const SizedBox(height: 12),
              TeamList(companyId: companyId),
            ],
          );
  }
}
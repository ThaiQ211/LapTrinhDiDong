import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'team_detail.dart';

class TeamList extends StatelessWidget {
  final String companyId;
  const TeamList({super.key, required this.companyId});

  Future<String> _getLeaderName(String leaderId) async {
    final userInfoSnap = await FirebaseFirestore.instance
        .collection('UserInfo')
        .where('userId', isEqualTo: leaderId)
        .limit(1)
        .get();
    if (userInfoSnap.docs.isEmpty) return 'Không rõ';
    return userInfoSnap.docs.first['fullname'] ?? 'Không rõ';
  }

  void _openTeamDetails(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeamDetailPage(teamData: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('Teams')
          .where('companyId', isEqualTo: companyId)
          .orderBy('createdAt', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Text('🚫 Chưa có team nào trong công ty.');
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'Không tên';
            final members = List<String>.from(data['members'] ?? []);
            final leaderId = data['leaderId'] ?? '';

            return FutureBuilder<String>(
              future: _getLeaderName(leaderId),
              builder: (context, leaderSnapshot) {
                final leaderName = leaderSnapshot.data ?? 'Đang tải...';
                return Card(
                  child: ListTile(
                    title: Text('🧩 $name'),
                    subtitle: Text('👑 Leader: $leaderName\n👥 Thành viên: ${members.length} người'),
                    onTap: () => _openTeamDetails(context, data),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
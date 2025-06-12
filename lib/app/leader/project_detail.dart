import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectDetail extends StatefulWidget {
  final String projectId;
  final String leaderId;

  const ProjectDetail({
    super.key,
    required this.projectId,
    required this.leaderId,
  });

  @override
  State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {
  Map<String, dynamic>? projectData;
  List<Map<String, dynamic>> _projectDetails = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProjectAndDetails();
  }

  Future<void> _loadProjectAndDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Project')
          .doc(widget.projectId)
          .get();

      if (!doc.exists || doc.data() == null) {
        setState(() => _loading = false);
        return;
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      projectData = data;

      final detailSnap = await FirebaseFirestore.instance
          .collection('ProjectDetail')
          .where('project_id', isEqualTo: widget.projectId)
          .get();

      final List<Map<String, dynamic>> details = [];

      for (final doc in detailSnap.docs) {
        final data = doc.data();
        final teamId = data['team_id'];

        final teamDoc = await FirebaseFirestore.instance
            .collection('Teams')
            .doc(teamId)
            .get();

        final teamData = teamDoc.data();
        if (teamData == null || teamData['leaderId'] != widget.leaderId) continue;

        final members = <Map<String, String>>[];
        if (teamData['members'] != null && teamData['members'] is List) {
          for (final userId in teamData['members']) {
            final infoSnap = await FirebaseFirestore.instance
                .collection('UserInfo')
                .where('userId', isEqualTo: userId)
                .limit(1)
                .get();
            if (infoSnap.docs.isNotEmpty) {
              final info = infoSnap.docs.first.data();
              members.add({
                'fullname': info['fullname'] ?? 'Không rõ',
                'username': info['username'] ?? '',
              });
            }
          }
        }

        details.add({
          'title': data['title'] ?? 'Không rõ',
          'description': data['description'] ?? '',
          'team_id': teamId,
          'members': members,
        });
      }

      setState(() {
        _projectDetails = details;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (projectData == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy dự án')),
      );
    }

    final name = projectData!['name'] ?? 'Không rõ';
    final desc = projectData!['description'] ?? 'Không có mô tả';
    final expiredAt = projectData!['expired_at'];
    final expiredDate = expiredAt is Timestamp
        ? expiredAt.toDate()
        : DateTime.tryParse(expiredAt.toString()) ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết dự án'),
        backgroundColor: const Color.fromARGB(255, 37, 125, 225),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildLabelValue(Icons.push_pin, 'Tên dự án', name),
            _buildLabelValue(Icons.edit_note, 'Mô tả', desc),
            _buildLabelValue(Icons.calendar_month, 'Hạn chót', DateFormat('dd/MM/yyyy').format(expiredDate)),
            const SizedBox(height: 24),
            const Text(
              'Nhiệm vụ được giao',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 12),
            ..._projectDetails.map((detail) {
              final members = detail['members'] as List;
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📄 ${detail['title']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(detail['description'], style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      const Text('👥 Thành viên:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ...members.map((m) => Text('- ${m['fullname']} (@${m['username']})')),
                    ],
                  ),
                ),
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _buildLabelValue(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.green),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
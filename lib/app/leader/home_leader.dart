import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:new_task_management/app/leader/tabs/setting_tab.dart';
import 'package:new_task_management/app/leader/tabs/team_tab.dart';
import 'package:new_task_management/app/leader/project/leader_navbar.dart';

class HomeLeader extends StatefulWidget {
  final String uid;

  const HomeLeader({super.key, required this.uid});

  @override
  State<HomeLeader> createState() => _HomeLeaderState();
}

class _HomeLeaderState extends State<HomeLeader> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjectsForLeader();
  }

  Future<void> _loadProjectsForLeader() async {
    final userId = widget.uid;

    try {
      final teamSnap = await FirebaseFirestore.instance
          .collection('Teams')
          .where('leaderId', isEqualTo: userId)
          .get();

      final teamIds = teamSnap.docs.map((e) => e.id).toList();
      if (teamIds.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final detailSnap = await FirebaseFirestore.instance
          .collection('ProjectDetail')
          .where('team_id', whereIn: teamIds)
          .get();

      final projectIds = detailSnap.docs
          .map((e) => e['project_id']?.toString())
          .whereType<String>()
          .toSet()
          .toList();

      if (projectIds.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final List<Map<String, dynamic>> projects = [];
      for (final pid in projectIds) {
        final doc = await FirebaseFirestore.instance
            .collection('Project')
            .doc(pid)
            .get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            data['id'] = doc.id;
            projects.add(data);
          }
        }
      }

      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _goToDetail(Map<String, dynamic> project) {
    final projectId = project['id'];
    if (projectId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeaderNavbar(
          projectId: projectId,
          leaderId: widget.uid,
        ),
      ),
    );
  }

  Widget _buildProjectTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_projects.isEmpty) {
      return const Center(child: Text('Không có dự án nào'));
    }

    return ListView.builder(
      itemCount: _projects.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (_, index) {
        final p = _projects[index];
        final expiredAt = p['expired_at'];
        final expiredDate = expiredAt is Timestamp
            ? expiredAt.toDate()
            : DateTime.tryParse(expiredAt.toString()) ?? DateTime.now();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.folder, color: Colors.blueAccent),
            title: Text(
              p['name'] ?? 'Không rõ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Hạn: ${DateFormat('dd/MM/yyyy').format(expiredDate)}',
              style: const TextStyle(color: Colors.black54),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _goToDetail(p),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildProjectTab(),
      const TeamTab(),
      const SettingTab(),
    ];

    final titles = [
      'Dự án được giao',
      'Team quản lý',
      'Cài đặt',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        backgroundColor: const Color.fromARGB(255, 37, 125, 225),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 37, 125, 225),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Dự án',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Team',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}
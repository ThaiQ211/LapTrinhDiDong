import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_task_management/app/leader/project_detail.dart';
import 'assign.dart';
import 'progress.dart';
import 'report.dart';

class LeaderNavbar extends StatefulWidget {
  final String projectId;
  final String leaderId;

  const LeaderNavbar({super.key, required this.projectId, required this.leaderId});

  @override
  State<LeaderNavbar> createState() => _LeaderNavbarState();
}

class _LeaderNavbarState extends State<LeaderNavbar> {
  int _currentIndex = 0;
  List<Widget> _tabs = [];
  Map<String, dynamic>? projectData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProject();
  }

  Future<void> fetchProject() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Project')
              .doc(widget.projectId)
              .get();

      if (!doc.exists || doc.data() == null) {
        print('❌ Không tìm thấy project với ID: ${widget.projectId}');
        setState(() => isLoading = false);
        return;
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      setState(() {
        projectData = data;
        _tabs = [
          ProjectDetail(
            projectId: widget.projectId,
            leaderId: widget.leaderId,
          ),
          AssignTab(project: data, leaderId: widget.leaderId),
          ProgressTab(project: data,leaderId: widget.leaderId,),
          ReportTab(project: data, leaderId: widget.leaderId,),
        ];
        isLoading = false;
      });
    } catch (e) {
      print('❌ Lỗi khi fetch project: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (projectData == null) {
      return const Scaffold(
        body: Center(child: Text('❌ Không tìm thấy dữ liệu dự án')),
      );
    }

    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Giao việc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Tiến độ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            label: 'Báo cáo',
          ),
        ],
      ),
    );
  }
}

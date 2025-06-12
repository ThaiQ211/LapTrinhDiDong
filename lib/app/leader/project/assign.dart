import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_task_management/app/leader/assign_task.dart';
import 'package:new_task_management/common/services/task_service.dart';

class AssignTab extends StatefulWidget {
  final Map<String, dynamic> project;
  final String leaderId;

  const AssignTab({super.key, required this.project, required this.leaderId});

  @override
  State<AssignTab> createState() => _AssignTabState();
}

class _AssignTabState extends State<AssignTab> {
  final List<_FormData> _formList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderDetails();
  }

  Future<void> _loadLeaderDetails() async {
    final snap = await FirebaseFirestore.instance
        .collection('ProjectDetail')
        .where('project_id', isEqualTo: widget.project['id'])
        .get();

    final List<_FormData> tempList = [];

    for (final doc in snap.docs) {
      final data = doc.data();
      final teamId = data['team_id'];

      final teamSnap = await FirebaseFirestore.instance
          .collection('Teams')
          .doc(teamId)
          .get();

      final team = teamSnap.data();
      if (team == null || team['leaderId'] != widget.leaderId) continue;

      final members = <Map<String, dynamic>>[];

      for (final id in team['members']) {
        final userInfoSnap = await FirebaseFirestore.instance
            .collection('UserInfo')
            .where('userId', isEqualTo: id)
            .limit(1)
            .get();

        if (userInfoSnap.docs.isNotEmpty) {
          final info = userInfoSnap.docs.first.data();
          members.add({
            'userId': id,
            'fullname': info['fullname'],
            'username': info['username'],
          });
        }
      }

      final key = GlobalKey<AssignTaskFormState>();
      tempList.add(
        _FormData(
          key: key,
          form: AssignTaskForm(
            key: key,
            projectId: widget.project['id'],
            teamId: teamId,
            detailTitle: data['title'],
            detailDesc: data['description'],
            members: members,
          ),
        ),
      );
    }

    setState(() {
      _formList.addAll(tempList);
      _loading = false;
    });
  }

  Future<void> _submitAllTasks() async {
    int submitted = 0;
    for (final item in _formList) {
      final form = item.key.currentState;
      if (form == null) continue;

      final tasks = form.getTasks();
      for (final task in tasks) {
        await TaskService.assignTask(
          projectId: task['projectId'],
          teamId: task['teamId'],
          title: task['title'],
          desc: task['desc'],
          requirement: task['requirement'],
          start: task['start'],
          end: task['end'],
          userId: task['userId'],
        );
        submitted++;
      }
      form.clearTasks();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã giao $submitted công việc thành công')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.assignment, size: 22),
            SizedBox(width: 6),
            Text('Giao việc'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: _formList.map((f) => f.form).toList(),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: _submitAllTasks,
                      icon: const Icon(Icons.send),
                      label: const Text('Giao tất cả công việc'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _FormData {
  final GlobalKey<AssignTaskFormState> key;
  final AssignTaskForm form;

  _FormData({required this.key, required this.form});
}
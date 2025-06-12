import 'package:flutter/material.dart';
import 'package:new_task_management/app/leader/progress_calendar.dart';

class ProgressTab extends StatelessWidget {
  final Map<String, dynamic> project;
  final String leaderId;

  const ProgressTab({super.key, required this.project, required this.leaderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiến độ công việc'),
        backgroundColor: Colors.blue,
      ),
      body: ProgressCalendar(
        projectId: project['id'],
        leaderId: leaderId,
      ),
    );
  }
}

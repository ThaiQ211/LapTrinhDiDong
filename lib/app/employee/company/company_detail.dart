import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../common/services/employee_service.dart';
import 'employee_report.dart';

class EmployeeCompanyDetailPage extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> company;

  const EmployeeCompanyDetailPage({super.key, required this.uid, required this.company});

  @override
  State<EmployeeCompanyDetailPage> createState() => _EmployeeCompanyDetailPageState();
}

class _EmployeeCompanyDetailPageState extends State<EmployeeCompanyDetailPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final list = await EmployeeService.getTasksByUser(widget.uid);
    setState(() {
      _tasks = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.company['name'] ?? 'Chi tiết công ty'),
        backgroundColor: const Color.fromARGB(255, 7, 135, 215),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(
                  child: Text(
                    '📭 Bạn chưa được giao công việc nào.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _tasks.length,
                  itemBuilder: (_, index) {
                    final task = _tasks[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    task['title'] ?? 'Không rõ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (task['isDone'] == true)
                                  const Text(
                                    '✅ Đã hoàn thành',
                                    style: TextStyle(color: Colors.green),
                                  )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              task['desc'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  'Từ ${_format(task['startTime'])} đến ${_format(task['endTime'])}',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            if (task['productLink'] != null && task['productLink'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '🔗 Sản phẩm: ${task['productLink']}',
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ),
                            if (task['isDone'] != true)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.note_add, size: 18),
                                    label: const Text('Báo cáo'),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EmployeeReportPage(
                                            uid: widget.uid,
                                            scheduleId: task['id'],
                                            projectId: task['projectId'],
                                            leaderId: task['leaderId'],
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 27, 61, 182),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _format(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}

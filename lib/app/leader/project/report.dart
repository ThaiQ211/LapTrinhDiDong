import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_task_management/common/services/task_service.dart';

class ReportTab extends StatefulWidget {
  final Map<String, dynamic> project;
  final String leaderId;

  const ReportTab({super.key, required this.project, required this.leaderId});

  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> {
  List<Map<String, dynamic>> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
    });
  }

  Future<void> _loadReports() async {
    try {
      final reports = await TaskService.getReports(
        projectId: widget.project['id'],
        leaderId: widget.leaderId,
      );

      setState(() {
        _reports = reports;
        _loading = false;
      });
    } catch (e) {
      print('❌ Lỗi khi load báo cáo: $e');
      setState(() {
        _reports = [];
        _loading = false;
      });
    }
  }

  Widget _reportLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.bar_chart, size: 20),
            SizedBox(width: 8),
            Text('Báo cáo công việc'),
          ],
        ),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _reports.isEmpty
              ? const Center(
                child: Text(
                  'Chưa có báo cáo nào.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  final r = _reports[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.assignment_outlined,
                                size: 28,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r['taskTitle'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      r['description'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        r['status'] == true
                                            ? Icons.check_circle
                                            : Icons.schedule,
                                        color:
                                            r['status'] == true
                                                ? Colors.green
                                                : Colors.orange,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        r['status'] == true
                                            ? 'Đã hoàn thành'
                                            : 'Chưa hoàn thành',
                                        style: TextStyle(
                                          color:
                                              r['status'] == true
                                                  ? Colors.green
                                                  : Colors.orange,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _reportLine(
                            Icons.access_time,
                            DateFormat('dd/MM/yyyy HH:mm').format(r['time']),
                          ),
                          if ((r['productLink'] ?? '').toString().isNotEmpty)
                            _reportLine(Icons.link, r['productLink']),
                          _reportLine(Icons.person_outline, r['userName']),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

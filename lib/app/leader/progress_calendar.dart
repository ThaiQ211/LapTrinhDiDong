import 'package:flutter/material.dart';
import 'package:new_task_management/common/services/task_service.dart';
import 'package:new_task_management/app/leader/widgets/task_cell.dart';
import 'package:new_task_management/app/leader/widgets/date_header.dart';
import 'package:new_task_management/app/leader/widgets/grid_lines.dart';

class ProgressCalendar extends StatefulWidget {
  final String projectId;
  final String leaderId;

  const ProgressCalendar({super.key, required this.projectId, required this.leaderId});

  @override
  State<ProgressCalendar> createState() => _ProgressCalendarState();
}

class _ProgressCalendarState extends State<ProgressCalendar> {
  List<Map<String, dynamic>> _tasks = [];
  List<DateTime> _dateRange = [];
  List<List<Map<String, dynamic>>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final list = await TaskService.getLeaderTasksByProjectAndLeader(
      widget.projectId, 
      widget.leaderId,
    );
    final users = await TaskService.getUserNameMap();

    final dates = list.expand((task) {
      return [task['startTime'] as DateTime, task['endTime'] as DateTime];
    });

    final minDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    final range = <DateTime>[];
    for (DateTime d = minDate; !d.isAfter(maxDate); d = d.add(const Duration(days: 1))) {
      range.add(DateTime(d.year, d.month, d.day));
    }

    final enrichedTasks = list.map((task) {
      final id = task['userId'];
      task['username'] = users[id] ?? id;
      task['fromIndex'] = range.indexWhere((d) => _isSameDate(d, task['startTime']));
      task['toIndex'] = range.indexWhere((d) => _isSameDate(d, (task['endTime'] as DateTime).subtract(const Duration(minutes: 1))));
      return task;
    }).toList();

    final rows = _assignTasksToRows(enrichedTasks);

    setState(() {
      _tasks = enrichedTasks;
      _dateRange = range;
      _rows = rows;
      _loading = false;
    });
  }

  List<List<Map<String, dynamic>>> _assignTasksToRows(List<Map<String, dynamic>> tasks) {
    final List<List<Map<String, dynamic>>> rows = [];

    for (var task in tasks) {
      final from = task['fromIndex'];
      final to = task['toIndex'];
      bool placed = false;

      for (var row in rows) {
        final overlap = row.any((t) {
          final tFrom = t['fromIndex'];
          final tTo = t['toIndex'];
          return !(to < tFrom || from > tTo);
        });
        if (!overlap) {
          row.add(task);
          placed = true;
          break;
        }
      }
      if (!placed) {
        rows.add([task]);
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_tasks.isEmpty) return const Center(child: Text('❗ Chưa có công việc nào được giao.'));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateHeader(dateRange: _dateRange),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 4),
          GridLines(dateRange: _dateRange, taskRowCount: _rows.length),
          const SizedBox(height: 4),
          _buildTaskGrid(),
        ],
      ),
    );
  }

  Widget _buildTaskGrid() {
    return SizedBox(
      width: 120.0 * _dateRange.length,
      height: 100.0 * _rows.length,
      child: Stack(
        children: [
          for (int row = 0; row < _rows.length; row++)
            for (final task in _rows[row])
              Positioned(
                left: 120.0 * task['fromIndex'] + 4,
                top: 100.0 * row + 4,
                child: TaskCell(
                  task: task,
                  span: task['toIndex'] - task['fromIndex'] + 1,
                ),
              ),
        ],
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
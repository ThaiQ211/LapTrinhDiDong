import 'package:flutter/material.dart';

class AssignTaskForm extends StatefulWidget {
  final String projectId;
  final String teamId;
  final String detailTitle;
  final String detailDesc;
  final List<Map<String, dynamic>> members;

  const AssignTaskForm({
    super.key,
    required this.projectId,
    required this.teamId,
    required this.detailTitle,
    required this.detailDesc,
    required this.members,
  });

  @override
  State<AssignTaskForm> createState() => AssignTaskFormState();
}

class AssignTaskFormState extends State<AssignTaskForm> {
  final List<_TaskInput> _taskInputs = [];

  @override
  void initState() {
    super.initState();
    _addTaskInput();
  }

  void _addTaskInput() {
    setState(() {
      _taskInputs.add(_TaskInput());
    });
  }

  void _removeTaskInput(int index) {
    setState(() {
      _taskInputs.removeAt(index);
    });
  }

  void clearTasks() {
    setState(() {
      _taskInputs.clear();
      _addTaskInput();
    });
  }

  List<Map<String, dynamic>> getTasks() {
    final List<Map<String, dynamic>> validTasks = [];
    for (final task in _taskInputs) {
      if (task.isValid) {
        validTasks.add({
          'title': task.title.text,
          'desc': task.desc.text,
          'requirement': task.req.text,
          'start': task.start!,
          'end': task.end!,
          'userId': task.userId!,
          'teamId': widget.teamId,
          'projectId': widget.projectId,
        });
      }
    }
    return validTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_outlined, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.detailTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.detailDesc,
              style: const TextStyle(color: Colors.black54),
            ),
            const Divider(),
            ..._taskInputs.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              return _buildTaskItem(task, index);
            }),
            const SizedBox(height: 12),
            Center(
              child: OutlinedButton.icon(
                onPressed: _addTaskInput,
                icon: const Icon(Icons.add),
                label: const Text('Thêm công việc'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(_TaskInput task, int index) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: task.title,
              decoration: const InputDecoration(labelText: 'Tên công việc'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: task.desc,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: task.req,
              decoration: const InputDecoration(labelText: 'Yêu cầu'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: task.userId,
              decoration: const InputDecoration(labelText: 'Chọn nhân viên'),
              items:
                  widget.members.map((m) {
                    return DropdownMenuItem<String>(
                      value: m['userId'] as String,
                      child: Text('${m['fullname']} (@${m['username']})'),
                    );
                  }).toList(),
              onChanged: (val) => setState(() => task.userId = val),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await _pickDateTime();
                      if (picked != null) setState(() => task.start = picked);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      task.start == null
                          ? 'Bắt đầu'
                          : '${task.start!.hour.toString().padLeft(2, '0')}:${task.start!.minute.toString().padLeft(2, '0')}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await _pickDateTime();
                      if (picked != null) setState(() => task.end = picked);
                    },
                    icon: const Icon(Icons.stop),
                    label: Text(
                      task.end == null
                          ? 'Kết thúc'
                          : '${task.end!.hour.toString().padLeft(2, '0')}:${task.end!.minute.toString().padLeft(2, '0')}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            if (_taskInputs.length > 1)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => _removeTaskInput(index),
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }
}

class _TaskInput {
  final TextEditingController title = TextEditingController();
  final TextEditingController desc = TextEditingController();
  final TextEditingController req = TextEditingController();
  DateTime? start;
  DateTime? end;
  String? userId;

  bool get isValid =>
      title.text.isNotEmpty &&
      desc.text.isNotEmpty &&
      req.text.isNotEmpty &&
      start != null &&
      end != null &&
      userId != null;
}

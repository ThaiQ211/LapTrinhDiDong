import 'package:flutter/material.dart';

class ProjectDetailForm extends StatelessWidget {
  final List<Map<String, dynamic>> details;
  final Function(Map<String, dynamic>) onAdd;
  final Function(int) onRemove;
  final List<Map<String, dynamic>> teams;

  const ProjectDetailForm({
    super.key,
    required this.details,
    required this.onAdd,
    required this.onRemove,
    required this.teams,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('📌 Phân chia phần công việc', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...details.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: item['title'],
                    decoration: const InputDecoration(labelText: 'Tiêu đề phần việc'),
                    onChanged: (val) => item['title'] = val,
                  ),
                  TextFormField(
                    initialValue: item['description'],
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                    onChanged: (val) => item['description'] = val,
                  ),
                  DropdownButtonFormField<String>(
                    value: item['team_id'],
                    items: teams.map((team) {
                      return DropdownMenuItem<String>(
                        value: team['id'],
                        child: Text(team['name'] ?? 'Không tên'),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Chọn team đảm nhận'),
                    onChanged: (val) => item['team_id'] = val,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onRemove(index),
                    ),
                  )
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Thêm phần việc'),
            onPressed: () => onAdd({ 'title': '', 'description': '', 'team_id': null }),
          ),
        )
      ],
    );
  }
}
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCell extends StatelessWidget {
  final Map<String, dynamic> task;
  final int span;

  const TaskCell({super.key, required this.task, required this.span});

  Color _randomColor(bool isDone) {
    if (isDone) return Colors.green;
    const exclude = [Colors.green];
    final colors =
        [
          Colors.orange,
        ].where((c) => !exclude.contains(c)).toList();
    return colors[Random(task['title'].hashCode).nextInt(colors.length)];
  }

@override
Widget build(BuildContext context) {
  final isDone = task['isDone'] ?? false;

  return Stack(
    children: [
      Container(
        width: 120.0 * span,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _randomColor(isDone),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task['title'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              task['desc'] ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              '${DateFormat('dd/MM').format(task['startTime'])} → ${DateFormat('dd/MM').format(task['endTime'])}',
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 4),
            Text(
              '👤 ${task['username'] ?? 'Unknown'}',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
      if (isDone)
        const Positioned(
          top: 4,
          left: 4,
          child: Icon(Icons.check_circle, color: Colors.white, size: 18),
        ),
    ],
  );
}
}

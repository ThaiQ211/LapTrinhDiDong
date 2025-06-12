import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHeader extends StatelessWidget {
  final List<DateTime> dateRange;

  const DateHeader({super.key, required this.dateRange});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: dateRange.map((d) {
        return Container(
          width: 120,
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(DateFormat.E().format(d), style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(DateFormat('dd/MM').format(d)),
            ],
          ),
        );
      }).toList(),
    );
  }
} 
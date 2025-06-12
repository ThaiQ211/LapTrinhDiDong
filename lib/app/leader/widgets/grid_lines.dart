import 'package:flutter/material.dart';

class GridLines extends StatelessWidget {
  final List<DateTime> dateRange;
  final int taskRowCount;

  const GridLines({super.key, required this.dateRange, required this.taskRowCount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120.0 * dateRange.length,
      height: 90.0 * taskRowCount,
      child: Stack(
        children: [
          for (int row = 0; row < taskRowCount; row++)
            for (int col = 0; col < dateRange.length; col++)
              Positioned(
                top: row * 90.0,
                left: col * 120.0,
                child: Container(
                  width: 120,
                  height: 90,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ManagerNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const ManagerNavbar({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabChanged,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Nhân sự'),
        BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Dự án'),
      ],
    );
  }
}
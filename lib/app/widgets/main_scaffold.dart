import 'package:flutter/material.dart';
import 'package:new_task_management/app/pages/setting_page.dart';

class MainScaffold extends StatelessWidget {
  final String role;
  final Widget body;
  final int currentIndex;
  final Function(int) onTabChanged;
  final String uid;

  const MainScaffold({
    Key? key,
    required this.role,
    required this.body,
    required this.currentIndex,
    required this.onTabChanged,
    required this.uid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navItems = _getNavItems(role);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trang Chủ - $role'),
        backgroundColor: Colors.blue,
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          final isSettingsTab = index == navItems.length - 1;

          if (isSettingsTab) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage(uid: uid)),
            );
          } else {
            onTabChanged(index);
          }
        },
        items: navItems,
      ),
    );
  }

  List<BottomNavigationBarItem> _getNavItems(String role) {
    if (role == 'manager') {
      return [
        BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Công ty'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Nhân sự'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
      ];
    } else if (role == 'superadmin') {
      return [
        BottomNavigationBarItem(icon: Icon(Icons.approval), label: 'Duyệt'),
        BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Quản lý'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
      ];
    } else if (role == 'employee') {
      return [
        BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Công việc'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tôi'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
      ];
    } else {
      return [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
      ];
    }
  }
}
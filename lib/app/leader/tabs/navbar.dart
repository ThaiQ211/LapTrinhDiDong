import 'package:flutter/material.dart';
import 'package:new_task_management/app/leader/home_leader.dart';
import 'team_tab.dart';
import 'setting_tab.dart';

class LeaderMainNavbar extends StatefulWidget {
  final String uid;

  const LeaderMainNavbar({super.key, required this.uid});

  @override
  State<LeaderMainNavbar> createState() => _LeaderMainNavbarState();
}

class _LeaderMainNavbarState extends State<LeaderMainNavbar> {
  int _currentIndex = 0;
  late List<Widget> _tabs;

  final List<String> _titles = const [
    '📁 Dự án được giao',
    '👥 Team quản lý',
    '⚙️ Cài đặt',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = [
      HomeLeader(uid: widget.uid),
      const TeamTab(),
      const SettingTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.green,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_copy),
            label: 'Dự án',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_2),
            label: 'Team',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}

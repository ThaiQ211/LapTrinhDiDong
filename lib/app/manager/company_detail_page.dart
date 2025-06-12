import 'package:flutter/material.dart';
import 'package:new_task_management/app/manager/manager_navbar.dart';
import 'package:new_task_management/app/manager/tabs/overall.dart';
import 'package:new_task_management/app/manager/tabs/staff.dart';
import 'package:new_task_management/app/manager/tabs/project.dart';

class CompanyDetailPage extends StatefulWidget {
  final Map<String, dynamic> companyData;

  const CompanyDetailPage({super.key, required this.companyData});

  @override
  State<CompanyDetailPage> createState() => _CompanyDetailPageState();
}

class _CompanyDetailPageState extends State<CompanyDetailPage> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi Tiết Công Ty')),
      body: _buildBodyByTab(),
      bottomNavigationBar: ManagerNavbar(
        currentIndex: _navIndex,
        onTabChanged: (index) => setState(() => _navIndex = index),
      ),
    );
  }

  Widget _buildBodyByTab() {
    switch (_navIndex) {
      case 0:
        return OverallTab(companyData: widget.companyData);
      case 1:
  return Staff(companyData: widget.companyData);
      case 2:
        return const ProjectPage();
      default:
        return const Center(child: Text("Tab không tồn tại"));
    }
  }
}
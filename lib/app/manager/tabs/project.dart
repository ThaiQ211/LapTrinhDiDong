import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:new_task_management/app/manager/project_detail_form.dart';
import 'package:new_task_management/common/services/project_service.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final _formKey = GlobalKey<FormState>();
  String? _projectName;
  String? _description;
  DateTime? _expiredDate;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _details = [];
  List<Map<String, dynamic>> _teams = [];
  String? _companyId;
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_companyId == null) {
      final route = ModalRoute.of(context);
      if (route != null && route.settings.arguments is Map<String, dynamic>) {
        final companyData = route.settings.arguments as Map<String, dynamic>;
        _companyId = companyData['id']?.toString();
        _loadProjects();
      }
    }
  }

  Future<void> _loadProjects() async {
    if (_companyId == null) return;
    _projects = await ProjectService.fetchProjectsByCompany(_companyId!);
    setState(() => _isLoading = false);
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate() ||
        _expiredDate == null ||
        _details.isEmpty ||
        _companyId == null) return;

    if (_details.any((d) => d['title'] == '' || d['team_id'] == null)) return;

    setState(() => _isSubmitting = true);
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    await ProjectService.createProject(
      name: _projectName!,
      description: _description,
      expiredAt: _expiredDate!,
      createdBy: userId,
      companyId: _companyId!,
      details: _details,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã tạo dự án thành công')),
      );
      await _loadProjects();
    }
  }

  void _showCreateProjectModal() async {
    _details = [
      {'title': '', 'description': '', 'team_id': null},
    ];
    _teams = await ProjectService.fetchTeams();
    setState(() {});

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '➕ Tạo Dự Án Mới',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Tên dự án'),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Không được để trống' : null,
                      onChanged: (val) => _projectName = val,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Mô tả (tuỳ chọn)'),
                      onChanged: (val) => _description = val,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('🗓 Hạn dự án:'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _expiredDate != null
                                ? DateFormat('dd/MM/yyyy').format(_expiredDate!)
                                : 'Chưa chọn',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await ProjectService.pickDate(context);
                            if (picked != null) {
                              setState(() => _expiredDate = picked);
                              setModalState(() {});
                            }
                          },
                          child: const Text('Chọn ngày'),
                        ),
                      ],
                    ),
                    ProjectDetailForm(
                      details: _details,
                      teams: _teams,
                      onAdd: (detail) => setModalState(() => _details.add(detail)),
                      onRemove: (index) => setModalState(() => _details.removeAt(index)),
                    ),
                    const SizedBox(height: 16),
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _createProject,
                            icon: const Icon(Icons.save),
                            label: const Text('Tạo Dự Án'),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📁 Dự Án')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateProjectModal,
        icon: const Icon(Icons.add),
        label: const Text('Tạo dự án'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? const Center(child: Text('📁 Chưa có dự án nào được tạo'))
              : ListView.builder(
                  itemCount: _projects.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (_, index) {
                    final p = _projects[index];
                    final expiredAt = p['expired_at'];
                    final expiredDate = expiredAt is Timestamp
                        ? expiredAt.toDate()
                        : DateTime.tryParse(expiredAt.toString()) ?? DateTime.now();
                    return Card(
                      child: ListTile(
                        title: Text(p['name'] ?? 'Không rõ'),
                        subtitle: Text(
                          'Hạn: ${DateFormat('dd/MM/yyyy').format(expiredDate)}',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
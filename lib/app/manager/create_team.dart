import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTeam extends StatefulWidget {
  final String companyId;
  const CreateTeam({super.key, required this.companyId});

  @override
  State<CreateTeam> createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {
  final _formKey = GlobalKey<FormState>();
  String? _teamName;
  String? _selectedLeaderId;
  List<String> _selectedMemberIds = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> allEmployees = [];

  Future<void> loadEmployees() async {
    final userInfoSnap = await FirebaseFirestore.instance
        .collection('UserInfo')
        .where('companyId.${widget.companyId}', isEqualTo: true)
        .get();

    final userIds = userInfoSnap.docs.map((doc) => doc['userId'] as String).toList();
    if (userIds.isEmpty) return;

    final userSnap = await FirebaseFirestore.instance
        .collection('User')
        .where(FieldPath.documentId, whereIn: userIds)
        .where('role', isEqualTo: 'employee')
        .get();

    final validUserIds = userSnap.docs.map((e) => e.id).toSet();

    setState(() {
      allEmployees = userInfoSnap.docs
          .where((doc) => validUserIds.contains(doc['userId']))
          .map((doc) => {
                'id': doc['userId'],
                'fullname': doc['fullname'] ?? '',
              })
          .toList();
    });
  }

  Future<void> createTeam() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLeaderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn leader')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Xóa leader khỏi mọi team cũ
    final teamSnap = await FirebaseFirestore.instance
        .collection('Teams')
        .where('members', arrayContains: _selectedLeaderId)
        .where('companyId', isEqualTo: widget.companyId)
        .get();

    for (var doc in teamSnap.docs) {
      final members = List<String>.from(doc['members'] ?? []);
      members.remove(_selectedLeaderId);
      await doc.reference.update({'members': members});
    }

    final allMembers = {_selectedLeaderId!, ..._selectedMemberIds}.toList();

    await FirebaseFirestore.instance.collection('Teams').add({
      'companyId': widget.companyId,
      'name': _teamName,
      'leaderId': _selectedLeaderId,
      'members': allMembers,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('User').doc(_selectedLeaderId).update({
      'role': 'leader',
    });

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    loadEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🆕 Tạo Team Mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Tên team'),
                onChanged: (val) => _teamName = val.trim(),
                validator: (val) => val == null || val.isEmpty ? 'Không được để trống' : null,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Chọn leader'),
              items: allEmployees.map<DropdownMenuItem<String>>((user) {
                return DropdownMenuItem<String>(
                  value: user['id'],
                  child: Text(user['fullname']),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedLeaderId = val),
              validator: (val) => val == null ? 'Bắt buộc chọn leader' : null,
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('👥 Chọn thành viên khác:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...allEmployees.where((u) => u['id'] != _selectedLeaderId).map((user) {
              final id = user['id'];
              final name = user['fullname'];
              final isChecked = _selectedMemberIds.contains(id);
              return CheckboxListTile(
                title: Text(name),
                value: isChecked,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedMemberIds.add(id);
                    } else {
                      _selectedMemberIds.remove(id);
                    }
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: createTeam,
                    child: const Text('Tạo Team'),
                  )
          ],
        ),
      ),
    );
  }
}
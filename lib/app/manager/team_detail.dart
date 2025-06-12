import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_task_management/common/services/team_service.dart';

class TeamDetailPage extends StatefulWidget {
  final Map<String, dynamic> teamData;
  const TeamDetailPage({super.key, required this.teamData});

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  Map<String, String> memberNames = {};
  bool isLoading = true;

  String get teamId => widget.teamData['id']?.toString() ?? '';
  String get teamName => widget.teamData['name']?.toString() ?? '';
  String get companyId => widget.teamData['companyId']?.toString() ?? '';

  Future<void> refreshTeam() async {
    Map<String, dynamic>? team = teamId.isNotEmpty
        ? await TeamService.loadTeamById(teamId)
        : await TeamService.loadTeamByName(teamName);
    if (team != null) {
      widget.teamData.clear();
      widget.teamData.addAll(team);
    }
    final memberIds = List<String>.from(widget.teamData['members'] ?? []);
    memberNames = await TeamService.loadMemberNames(memberIds);
    if (mounted) setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    refreshTeam();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.teamData['name'] ?? 'Không tên';
    final leaderId = widget.teamData['leaderId'] ?? '';
    final members = List<String>.from(widget.teamData['members'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết team: $name'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              await TeamService.deleteTeam(teamId);
              if (mounted) Navigator.pop(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('👑 Leader: ${memberNames[leaderId] ?? leaderId}'),
                  const SizedBox(height: 12),
                  const Text('👥 Thành viên:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (_, index) {
                        final id = members[index];
                        final name = memberNames[id] ?? id;
                        return ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(name),
                          subtitle: Text('ID: $id'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (id != leaderId)
                                IconButton(
                                  icon: const Icon(Icons.star_border),
                                  tooltip: 'Chọn làm leader',
                                  onPressed: () async {
                                    try {
                                      final oldLeaderId = widget.teamData['leaderId']?.toString();
                                      await TeamService.changeLeader(teamId, id);
                                      if (oldLeaderId != null && oldLeaderId.isNotEmpty && oldLeaderId != id) {
                                        await FirebaseFirestore.instance.collection('User').doc(oldLeaderId).update({
                                          'role': 'employee'
                                        });
                                      }
                                      await refreshTeam();
                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Đã chọn $id làm leader')),
                                      );
                                    } catch (e) {
                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Lỗi đổi leader: $e')),
                                      );
                                    }
                                  },
                                ),
                              if (id != leaderId)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  tooltip: 'Xoá khỏi team',
                                  onPressed: () async {
                                    try {
                                      await TeamService.removeMember(teamId, id);
                                      await refreshTeam();
                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Đã xoá $id khỏi team')),
                                      );
                                    } catch (e) {
                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Lỗi xoá thành viên: $e')),
                                      );
                                    }
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async => await refreshTeam(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Làm mới danh sách'),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

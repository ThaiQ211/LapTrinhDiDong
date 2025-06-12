import 'package:cloud_firestore/cloud_firestore.dart';

class TeamService {
  static Future<void> removeMember(String teamId, String userId) async {
    await FirebaseFirestore.instance.collection('Teams').doc(teamId).update({
      'members': FieldValue.arrayRemove([userId])
    });
  }

  static Future<void> changeLeader(String teamId, String newLeaderId) async {
    await FirebaseFirestore.instance.collection('Teams').doc(teamId).update({
      'leaderId': newLeaderId
    });
    await FirebaseFirestore.instance.collection('User').doc(newLeaderId).update({
      'role': 'leader'
    });
  }

  static Future<void> deleteTeam(String teamId) async {
    await FirebaseFirestore.instance.collection('Teams').doc(teamId).delete();
  }

  static Future<Map<String, String>> loadMemberNames(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    final snap = await FirebaseFirestore.instance
        .collection('UserInfo')
        .where('userId', whereIn: userIds)
        .get();
    return {
      for (var doc in snap.docs)
        doc['userId']: doc['fullname'] ?? doc['userId']
    };
  }

  static Future<Map<String, dynamic>?> loadTeamById(String teamId) async {
    final doc = await FirebaseFirestore.instance.collection('Teams').doc(teamId).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        return { ...data, 'id': doc.id };
      }
    }
    return null;
  }

  static Future<Map<String, dynamic>?> loadTeamByName(String name) async {
    final snap = await FirebaseFirestore.instance
        .collection('Teams')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      final doc = snap.docs.first;
      return { ...doc.data(), 'id': doc.id };
    }
    return null;
  }
}
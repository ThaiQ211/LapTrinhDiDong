import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService {
  static Future<void> assignTask({
    required String projectId,
    required String teamId,
    required String title,
    required String desc,
    required String requirement,
    required DateTime start,
    required DateTime end,
    required String userId,
  }) async {
    final leaderId = FirebaseAuth.instance.currentUser?.uid;
    if (leaderId == null) return;

    await FirebaseFirestore.instance.collection('Schedule').add({
      'projectId': projectId,
      'title': title,
      'desc': desc,
      'requirement': requirement,
      'startTime': Timestamp.fromDate(start),
      'endTime': Timestamp.fromDate(end),
      'isDone': false,
      'score': null,
      'userId': userId,
      'leaderId': leaderId,
    });
  }

  static Future<List<Map<String, dynamic>>> getLeaderTasks(
    String projectId,
  ) async {
    final leaderId = FirebaseAuth.instance.currentUser?.uid;
    if (leaderId == null) return [];

    final snap =
        await FirebaseFirestore.instance
            .collection('Schedule')
            .where('projectId', isEqualTo: projectId)
            .where('leaderId', isEqualTo: leaderId)
            .orderBy('startTime')
            .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return {
        'title': data['title'] ?? 'Không rõ',
        'desc': data['desc'] ?? '',
        'startTime': (data['startTime'] as Timestamp).toDate(),
        'endTime': (data['endTime'] as Timestamp).toDate(),
        'userId': data['userId'],
      };
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> getLeaderTasksByProjectAndLeader(
    String projectId,
    String leaderId,
  ) async {
    final snap =
        await FirebaseFirestore.instance
            .collection('Schedule')
            .where('projectId', isEqualTo: projectId)
            .where('leaderId', isEqualTo: leaderId)
            .orderBy('startTime')
            .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return {
        'title': data['title'] ?? 'Không rõ',
        'desc': data['desc'] ?? '',
        'startTime': (data['startTime'] as Timestamp).toDate(),
        'endTime': (data['endTime'] as Timestamp).toDate(),
        'userId': data['userId'],
        'isDone': data['isDone'] ?? false,
      };
    }).toList();
  }

  static Future<Map<String, String>> getUserNameMap() async {
    final infoSnap =
        await FirebaseFirestore.instance.collection('UserInfo').get();

    final result = <String, String>{};
    for (var doc in infoSnap.docs) {
      final data = doc.data();
      final userId = data['userId'];
      final name = data['fullname'] ?? data['username'];
      if (userId != null && name != null) {
        result[userId] = name;
      }
    }

    return result;
  }

  static Future<List<Map<String, dynamic>>> getReports({
    required String projectId,
    required String leaderId,
  }) async {
    if (projectId.isEmpty || leaderId.isEmpty) {
      throw Exception('Thiếu projectId hoặc leaderId');
    }

    final snap =
        await FirebaseFirestore.instance
            .collection('Report')
            .where('leaderId', isEqualTo: leaderId)
            .where('projectId', isEqualTo: projectId)
            .orderBy('time', descending: true)
            .get();

    final List<Map<String, dynamic>> result = [];

    for (var doc in snap.docs) {
      final data = doc.data();
      final scheduleId = data['scheduleId'];
      final userId = data['userId'];

      // Lấy thông tin task
      String? taskTitle;
      final scheduleSnap =
          await FirebaseFirestore.instance
              .collection('Schedule')
              .doc(scheduleId)
              .get();
      if (scheduleSnap.exists) {
        taskTitle = scheduleSnap.data()?['title'];
      }

      // Lấy thông tin nhân viên
      String? userName;
      final userSnap =
          await FirebaseFirestore.instance
              .collection('UserInfo')
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();
      if (userSnap.docs.isNotEmpty) {
        final userInfo = userSnap.docs.first.data();
        userName = userInfo['fullname'] ?? userInfo['username'];
      }

      result.add({
        'description': data['description'] ?? '',
        'scheduleId': scheduleId,
        'time': (data['time'] as Timestamp).toDate(),
        'productLink': data['productLink'] ?? '',
        'status': data['status'] ?? false,
        'taskTitle': taskTitle ?? '[Không rõ tên công việc]',
        'userName': userName ?? '[Không rõ nhân viên]',
      });
    }

    return result;
  }
}

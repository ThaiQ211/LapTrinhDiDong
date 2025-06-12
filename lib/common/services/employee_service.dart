import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeService {
  static Future<List<Map<String, dynamic>>> getTasksByUser(
    String userId,
  ) async {
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('Schedule')
              .where('userId', isEqualTo: userId)
              .orderBy('startTime')
              .get();

      return snap.docs.map((doc) {
        final data = doc.data();
        final startTime = data['startTime'];
        final endTime = data['endTime'];

        return {
          'id': doc.id,
          'title': data['title'] ?? 'Không rõ',
          'desc': data['desc'] ?? '',
          'requirement': data['requirement'] ?? '',
          'startTime':
              startTime is Timestamp ? startTime.toDate() : DateTime.now(),
          'endTime': endTime is Timestamp ? endTime.toDate() : DateTime.now(),
          'isDone': data['isDone'] ?? false,
          'score': data['score'],
          'leaderId': data['leaderId'],
          'projectId': data['projectId'],
          'userId': data['userId'],
        };
      }).toList();
    } catch (e) {
      print('❌ Lỗi khi lấy task theo userId: $e');
      return [];
    }
  }

  static Future<void> submitReport({
    required String userId,
    required String scheduleId,
    required String projectId,
    required String leaderId,
    required bool status,
    required String description,
    required DateTime time,
    required String productLink, // ✅ thêm trường mới
  }) async {
    try {
      await FirebaseFirestore.instance.collection('Report').add({
        'userId': userId,
        'scheduleId': scheduleId,
        'projectId': projectId,
        'leaderId': leaderId,
        'status': status,
        'description': description,
        'productLink': productLink, // ✅ thêm vào khi lưu
        'time': Timestamp.fromDate(time),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (status == true) {
        await FirebaseFirestore.instance
            .collection('Schedule')
            .doc(scheduleId)
            .update({'isDone': true});
      }
    } catch (e) {
      print('❌ Lỗi khi gửi báo cáo: $e');
      rethrow;
    }
  }
}

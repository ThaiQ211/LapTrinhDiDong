import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleTask {
  final String id;
  final String title;
  final String desc;
  final String requirement;
  final DateTime startTime;
  final DateTime endTime;
  final bool isDone;
  final dynamic score;
  final String leaderId;
  final String projectId;
  final String userId;
  final String? productLink;

  ScheduleTask({
    required this.id,
    required this.title,
    required this.desc,
    required this.requirement,
    required this.startTime,
    required this.endTime,
    required this.isDone,
    required this.score,
    required this.leaderId,
    required this.projectId,
    required this.userId,
    this.productLink,
  });

  factory ScheduleTask.fromFirestore(String id, Map<String, dynamic> data) {
    final start = data['startTime'];
    final end = data['endTime'];
    return ScheduleTask(
      id: id,
      title: data['title'] ?? 'Không rõ',
      desc: data['desc'] ?? '',
      requirement: data['requirement'] ?? '',
      startTime: start is Timestamp ? start.toDate() : DateTime.now(),
      endTime: end is Timestamp ? end.toDate() : DateTime.now(),
      isDone: data['isDone'] ?? false,
      score: data['score'],
      leaderId: data['leaderId'],
      projectId: data['projectId'],
      userId: data['userId'],
      productLink: data['productLink'],
    );
  }
}

class ReportData {
  final String userId;
  final String scheduleId;
  final String projectId;
  final String leaderId;
  final bool status;
  final String description;
  final DateTime time;
  final String productLink;

  ReportData({
    required this.userId,
    required this.scheduleId,
    required this.projectId,
    required this.leaderId,
    required this.status,
    required this.description,
    required this.time,
    required this.productLink,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'scheduleId': scheduleId,
      'projectId': projectId,
      'leaderId': leaderId,
      'status': status,
      'description': description,
      'productLink': productLink,
      'time': Timestamp.fromDate(time),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
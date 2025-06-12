import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProjectService {
  /// Hiển thị picker chọn ngày hết hạn dự án
  static Future<DateTime?> pickDate(BuildContext context) async {
    final now = DateTime.now();
    return await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
  }

  /// Tạo mới một dự án và các chi tiết dự án tương ứng
  static Future<DocumentReference> createProject({
    required String name,
    String? description,
    required DateTime expiredAt,
    required String createdBy,
    required String companyId,
    required List<Map<String, dynamic>> details,
  }) async {
    // Tạo dự án chính
    final projectRef = await FirebaseFirestore.instance
        .collection('Project')
        .add({
          'name': name,
          'description': description,
          'created_at': Timestamp.now(),
          'expired_at': Timestamp.fromDate(expiredAt),
          'created_by': createdBy,
          'company_id': companyId,
        });

    // Tạo các mục chi tiết dự án
    for (var detail in details) {
      await FirebaseFirestore.instance.collection('ProjectDetail').add({
        'project_id': projectRef.id,
        'title': detail['title'],
        'description': detail['description'],
        'team_id': detail['team_id'],
        'created_at': Timestamp.now(),
      });
    }

    return projectRef;
  }

  /// Lấy danh sách tất cả các team từ Firestore
  static Future<List<Map<String, dynamic>>> fetchTeams() async {
    final snap = await FirebaseFirestore.instance.collection('Teams').get();
    return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchProjectsByCompany(
    String companyId,
  ) async {
    final snap =
        await FirebaseFirestore.instance
            .collection('Project')
            .where('company_id', isEqualTo: companyId)
            .orderBy('created_at', descending: true)
            .get();

    return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }
}

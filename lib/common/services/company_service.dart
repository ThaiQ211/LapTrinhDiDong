import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyService {
  static Future<List<Map<String, dynamic>>> getApprovedCompanies(String userId) async {
    print('📌 Bắt đầu lấy công ty đã duyệt cho user: $userId');

    final userInfoSnap = await FirebaseFirestore.instance
        .collection('UserInfo')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (userInfoSnap.docs.isEmpty) {
      print('⚠️ Không tìm thấy userInfo cho userId: $userId');
      return [];
    }

    final userData = userInfoSnap.docs.first.data();
    print('✅ Dữ liệu userInfo: $userData');

    final Map<String, dynamic> companyMap =
        Map<String, dynamic>.from(userData['companyId'] ?? {});

    print('🔍 companyMap (duyệt = true): $companyMap');

    final approvedCompanyIds = companyMap.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();

    print('✅ Danh sách companyId đã duyệt: $approvedCompanyIds');

    if (approvedCompanyIds.isEmpty) {
      print('⚠️ Không có companyId nào được duyệt');
      return [];
    }

    List<Map<String, dynamic>> results = [];
    for (final id in approvedCompanyIds) {
      final doc = await FirebaseFirestore.instance.collection('Company').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        print('✅ Tìm thấy công ty [$id]: $data');
        results.add({...data, 'id': doc.id});
      } else {
        print('⚠️ Không tìm thấy công ty có id: $id');
      }
    }

    return results;
  }

  static Future<List<Map<String, dynamic>>> getPendingCompanies(String userId) async {
    print('📌 Bắt đầu lấy công ty đang chờ duyệt cho user: $userId');

    final userInfoSnap = await FirebaseFirestore.instance
        .collection('UserInfo')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (userInfoSnap.docs.isEmpty) {
      print('⚠️ Không tìm thấy userInfo cho userId: $userId');
      return [];
    }

    final userData = userInfoSnap.docs.first.data();
    print('✅ Dữ liệu userInfo: $userData');

    final Map<String, dynamic> companyMap =
        Map<String, dynamic>.from(userData['companyId'] ?? {});

    print('🔍 companyMap (đang chờ): $companyMap');

    final pendingCompanyIds = companyMap.entries
        .where((e) => e.value != true)
        .map((e) => e.key)
        .toList();

    print('✅ Danh sách companyId đang chờ: $pendingCompanyIds');

    if (pendingCompanyIds.isEmpty) {
      print('⚠️ Không có companyId nào đang chờ duyệt');
      return [];
    }

    List<Map<String, dynamic>> results = [];
    for (final id in pendingCompanyIds) {
      final doc = await FirebaseFirestore.instance.collection('Company').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        print('✅ Tìm thấy công ty [$id]: $data');
        results.add({...data, 'id': doc.id});
      } else {
        print('⚠️ Không tìm thấy công ty có id: $id');
      }
    }

    return results;
  }
}
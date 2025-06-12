import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CompanyReviewPage extends StatelessWidget {
  final String companyId;
  final Map<String, dynamic> companyData;

  const CompanyReviewPage({
    Key? key,
    required this.companyId,
    required this.companyData,
  }) : super(key: key);

  Future<void> approveCompany(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('Company')
        .doc(companyId)
        .update({'status': true});

    Navigator.pop(context);

    // ✅ Hiển thị snackbar sau một chút để tránh lỗi context
    Future.delayed(Duration(milliseconds: 200), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Công ty đã được duyệt')),
      );
    });
  }

  Future<void> rejectCompany(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('Company')
        .doc(companyId)
        .delete();

    Navigator.pop(context);

    Future.delayed(Duration(milliseconds: 200), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Công ty đã bị từ chối')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xét Duyệt Công Ty'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🏢 ${companyData['name']}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('📍 Địa điểm: ${companyData['location']}'),
            const SizedBox(height: 6),
            Text('💼 Lĩnh vực: ${companyData['sector']}'),
            const SizedBox(height: 6),
            Text('👤 Chủ sở hữu: ${companyData['ownerId']}'),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => approveCompany(context),
                    icon: Icon(Icons.check_circle),
                    label: Text('Duyệt'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => rejectCompany(context),
                    icon: Icon(Icons.cancel),
                    label: Text('Từ chối'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
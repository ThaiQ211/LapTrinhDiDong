import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/services/employee_service.dart';

class EmployeeReportPage extends StatefulWidget {
  final String uid;
  final String scheduleId;
  final String projectId;
  final String leaderId;

  const EmployeeReportPage({
    super.key,
    required this.uid,
    required this.scheduleId,
    required this.projectId,
    required this.leaderId,
  });

  @override
  State<EmployeeReportPage> createState() => _EmployeeReportPageState();
}

class _EmployeeReportPageState extends State<EmployeeReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  bool _status = false;
  DateTime _selectedTime = DateTime.now();
  bool _submitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      await EmployeeService.submitReport(
        userId: widget.uid,
        scheduleId: widget.scheduleId,
        projectId: widget.projectId,
        leaderId: widget.leaderId,
        status: _status,
        description: _descController.text.trim(),
        time: _selectedTime,
        productLink: _linkController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đã gửi báo cáo thành công')),
        );
      }
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gửi báo cáo thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Báo cáo công việc'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mô tả tiến độ',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Vui lòng nhập mô tả'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Link sản phẩm (nếu có)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _status,
                    onChanged: (val) => setState(() => _status = val ?? false),
                  ),
                  const Text('Đã hoàn thành'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Thời gian: '),
                  Text(DateFormat('dd/MM/yyyy – HH:mm').format(_selectedTime)),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedTime,
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _selectedTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          _selectedTime.hour,
                          _selectedTime.minute,
                        ));
                      }
                    },
                    child: const Text('🗓 Chọn ngày'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: const Icon(Icons.send),
                  label: const Text('Gửi báo cáo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
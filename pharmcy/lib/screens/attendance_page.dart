import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmcy/pharmacist_interface.dart';

class AttendancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedGenericListPage(
      title: 'Attendance',
      endpoint: 'attendance',
      columns: ['attnd_id', 'emp_id', 'check_in_time', 'check_out_time'],
      themeColor: Colors.cyan,
      icon: Icons.access_time,
      onAdd: (item) => _showAttendanceDialog(context, item),
      onEdit: (item) => _showAttendanceDialog(context, item),
    );
  }

  _showAttendanceDialog(BuildContext context, Map<String, dynamic> item) {
    final empIdController = TextEditingController(
      text: item['emp_id']?.toString() ?? '',
    );
    final checkInController = TextEditingController(
      text: item['check_in_time'] ?? '',
    );
    final checkOutController = TextEditingController(
      text: item['check_out_time'] ?? '',
    );
    final dateController = TextEditingController(text: item['date'] ?? '');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.access_time, color: Colors.cyan),
                SizedBox(width: 8),
                Text(item.isEmpty ? 'Add Attendance' : 'Edit Attendance'),
              ],
            ),
            content: Container(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      empIdController,
                      'Employee ID',
                      Icons.person,
                      isNumber: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      dateController,
                      'Date (YYYY-MM-DD)',
                      Icons.calendar_today,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      checkInController,
                      'Check In Time (HH:MM:SS)',
                      Icons.login,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      checkOutController,
                      'Check Out Time (HH:MM:SS)',
                      Icons.logout,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _saveAttendance(context, item, {
                    'emp_id': int.tryParse(empIdController.text),
                    'date': dateController.text,
                    'check_in_time': checkInController.text,
                    'check_out_time': checkOutController.text,
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  _saveAttendance(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, dynamic> data,
  ) async {
    try {
      final url =
          item.isEmpty
              ? 'http://localhost:3000/api/attendance'
              : 'http://localhost:3000/api/attendance/${item['attnd_id']}';

      final response =
          item.isEmpty
              ? await http.post(
                Uri.parse(url),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(data),
              )
              : await http.put(
                Uri.parse(url),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(data),
              );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving attendance: $e')));
    }
  }
}

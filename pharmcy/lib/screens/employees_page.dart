import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmcy/pharmacist_interface.dart';

class EmployeesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedGenericListPage(
      title: 'Employees',
      endpoint: 'employees',
      columns: ['employee_id', 'name', 'position', 'email'],
      themeColor: Colors.orange,
      icon: Icons.people,
      onAdd: (item) => _showEmployeeDialog(context, item),
      onEdit: (item) => _showEmployeeDialog(context, item),
    );
  }

  _showEmployeeDialog(BuildContext context, Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name'] ?? '');
    final positionController = TextEditingController(
      text: item['position'] ?? '',
    );
    final emailController = TextEditingController(text: item['email'] ?? '');
    final contactController = TextEditingController(
      text: item['contact'] ?? '',
    );
    final addressController = TextEditingController(
      text: item['address'] ?? '',
    );
    final branchIdController = TextEditingController(
      text: item['branch_id']?.toString() ?? '',
    );
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.people, color: Colors.orange),
                SizedBox(width: 8),
                Text(item.isEmpty ? 'Add Employee' : 'Edit Employee'),
              ],
            ),
            content: Container(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      branchIdController,
                      'Branch ID',
                      Icons.location_on,
                      isNumber: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      nameController,
                      'Employee Name',
                      Icons.person,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(positionController, 'Position', Icons.work),
                    SizedBox(height: 16),
                    _buildTextField(emailController, 'Email', Icons.email),
                    SizedBox(height: 16),
                    _buildTextField(contactController, 'Contact', Icons.phone),
                    SizedBox(height: 16),
                    _buildTextField(addressController, 'Address', Icons.home),
                    if (item.isEmpty) ...[
                      SizedBox(height: 16),
                      _buildTextField(
                        passwordController,
                        'Password',
                        Icons.lock,
                        isPassword: true,
                      ),
                    ],
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
                  final data = {
                    'branch_id': int.tryParse(branchIdController.text),
                    'name': nameController.text,
                    'position': positionController.text,
                    'email': emailController.text,
                    'contact': contactController.text,
                    'address': addressController.text,
                  };

                  if (item.isEmpty) {
                    data['password'] = passwordController.text;
                  }

                  await _saveEmployee(context, item, data);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  _saveEmployee(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, dynamic> data,
  ) async {
    try {
      final url =
          item.isEmpty
              ? 'http://localhost:3000/api/employees'
              : 'http://localhost:3000/api/employees/${item['employee_id']}';

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
            content: Text('Employee saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving employee: $e')));
    }
  }
}

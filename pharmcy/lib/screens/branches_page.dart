import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmcy/pharmacist_interface.dart';

class BranchesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedGenericListPage(
      title: 'Branches',
      endpoint: 'branches',
      columns: ['branch_id', 'name', 'address', 'contact'],
      themeColor: Colors.green,
      icon: Icons.location_on,
      onAdd: (item) => _showBranchDialog(context, item),
      onEdit: (item) => _showBranchDialog(context, item),
    );
  }

  _showBranchDialog(BuildContext context, Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name'] ?? '');
    final addressController = TextEditingController(
      text: item['address'] ?? '',
    );
    final contactController = TextEditingController(
      text: item['contact'] ?? '',
    );
    final pharmacyIdController = TextEditingController(
      text: item['pharmacy_id']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.location_on, color: Colors.green),
                SizedBox(width: 8),
                Text(item.isEmpty ? 'Add Branch' : 'Edit Branch'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    pharmacyIdController,
                    'Pharmacy ID',
                    Icons.business,
                    isNumber: true,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    nameController,
                    'Branch Name',
                    Icons.location_on,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(addressController, 'Address', Icons.home),
                  SizedBox(height: 16),
                  _buildTextField(contactController, 'Contact', Icons.phone),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _saveBranch(context, item, {
                    'pharmacy_id': int.tryParse(pharmacyIdController.text),
                    'name': nameController.text,
                    'address': addressController.text,
                    'contact': contactController.text,
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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

  _saveBranch(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, dynamic> data,
  ) async {
    try {
      final url =
          item.isEmpty
              ? 'http://localhost:3000/api/branches'
              : 'http://localhost:3000/api/branches/${item['branch_id']}';

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
            content: Text('Branch saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving branch: $e')));
    }
  }
}

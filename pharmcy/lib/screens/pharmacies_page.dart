import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmcy/pharmacist_interface.dart';

class PharmaciesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedGenericListPage(
      title: 'Pharmacies',
      endpoint: 'pharmacies',
      columns: ['pharmacy_id', 'name', 'address', 'contact'],
      themeColor: Colors.purple,
      icon: Icons.business,
      onAdd: (item) => _showPharmacyDialog(context, item),
      onEdit: (item) => _showPharmacyDialog(context, item),
    );
  }

  _showPharmacyDialog(BuildContext context, Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name'] ?? '');
    final addressController = TextEditingController(
      text: item['address'] ?? '',
    );
    final contactController = TextEditingController(
      text: item['contact'] ?? '',
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
                Icon(Icons.business, color: Colors.purple),
                SizedBox(width: 8),
                Text(item.isEmpty ? 'Add Pharmacy' : 'Edit Pharmacy'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  nameController,
                  'Pharmacy Name',
                  Icons.business,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  addressController,
                  'Address',
                  Icons.location_on,
                ),
                SizedBox(height: 16),
                _buildTextField(contactController, 'Contact', Icons.phone),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _savePharmacy(context, item, {
                    'name': nameController.text,
                    'address': addressController.text,
                    'contact': contactController.text,
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  _savePharmacy(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, dynamic> data,
  ) async {
    try {
      final url =
          item.isEmpty
              ? 'http://localhost:3000/api/pharmacies'
              : 'http://localhost:3000/api/pharmacies/${item['pharmacy_id']}';

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
            content: Text('Pharmacy saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving pharmacy: $e')));
    }
  }
}

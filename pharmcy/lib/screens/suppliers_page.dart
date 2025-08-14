import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmcy/pharmacist_interface.dart';

class SuppliersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedGenericListPage(
      title: 'Suppliers',
      endpoint: 'suppliers',
      columns: ['supplier_id', 'name', 'contact', 'product_type'],
      themeColor: Colors.teal,
      icon: Icons.local_shipping,
      onAdd: (item) => _showSupplierDialog(context, item),
      onEdit: (item) => _showSupplierDialog(context, item),
    );
  }

  _showSupplierDialog(BuildContext context, Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name'] ?? '');
    final contactController = TextEditingController(
      text: item['contact'] ?? '',
    );
    final productTypeController = TextEditingController(
      text: item['product_type'] ?? '',
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
                Icon(Icons.local_shipping, color: Colors.teal),
                SizedBox(width: 8),
                Text(item.isEmpty ? 'Add Supplier' : 'Edit Supplier'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  nameController,
                  'Supplier Name',
                  Icons.business,
                ),
                SizedBox(height: 16),
                _buildTextField(contactController, 'Contact', Icons.phone),
                SizedBox(height: 16),
                _buildTextField(
                  productTypeController,
                  'Product Type',
                  Icons.category,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _saveSupplier(context, item, {
                    'name': nameController.text,
                    'contact': contactController.text,
                    'product_type': productTypeController.text,
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
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

  _saveSupplier(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, dynamic> data,
  ) async {
    try {
      final url =
          item.isEmpty
              ? 'http://localhost:3000/api/suppliers'
              : 'http://localhost:3000/api/suppliers/${item['supplier_id']}';

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
            content: Text('Supplier saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving supplier: $e')));
    }
  }
}

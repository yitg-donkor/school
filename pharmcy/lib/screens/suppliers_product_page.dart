import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmcy/pharmacist_interface.dart';

class SupplierProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedGenericListPage(
      title: 'Supplier Products',
      endpoint: 'supplier-products',
      columns: ['supp_pro_id', 'supp_id', 'supp_prod_price', 'updated_at'],
      themeColor: Colors.brown,
      icon: Icons.link,
      onAdd: (item) => _showSupplierProductDialog(context, item),
      onEdit: (item) => _showSupplierProductDialog(context, item),
    );
  }

  _showSupplierProductDialog(BuildContext context, Map<String, dynamic> item) {
    final suppIdController = TextEditingController(
      text: item['supp_id']?.toString() ?? '',
    );
    final suppProdPriceController = TextEditingController(
      text: item['supp_prod_price']?.toString() ?? '',
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
                Icon(Icons.link, color: Colors.brown),
                SizedBox(width: 8),
                Text(
                  item.isEmpty
                      ? 'Add Supplier Product'
                      : 'Edit Supplier Product',
                ),
              ],
            ),
            content: Container(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      suppIdController,
                      'Supplier ID',
                      Icons.local_shipping,
                      isNumber: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      suppProdPriceController,
                      'Product Price',
                      Icons.attach_money,
                      isNumber: true,
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
                  await _saveSupplierProduct(context, item, {
                    'supp_id': int.tryParse(suppIdController.text),
                    'supp_prod_price': double.tryParse(
                      suppProdPriceController.text,
                    ),
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
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

  _saveSupplierProduct(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, dynamic> data,
  ) async {
    try {
      final url =
          item.isEmpty
              ? 'http://localhost:3000/api/supplier-products'
              : 'http://localhost:3000/api/supplier-products/${item['supp_pro_id']}';

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
            content: Text('Supplier product saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving supplier product: $e')),
      );
    }
  }
}

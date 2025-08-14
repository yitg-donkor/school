import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pharmcy/pharmacist_interface.dart';

class ProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedGenericListPage(
      title: 'Products',
      endpoint: 'products',
      columns: ['product_id', 'name', 'unit_price', 'quantity'],
      themeColor: Colors.indigo,
      icon: Icons.inventory,
      onAdd: (item) => _showProductDialog(context, item),
      onEdit: (item) => _showProductDialog(context, item),
    );
  }

  _showProductDialog(BuildContext context, Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name'] ?? '');
    final unitPriceController = TextEditingController(
      text: item['unit_price']?.toString() ?? '',
    );
    final quantityController = TextEditingController(
      text: item['quantity']?.toString() ?? '',
    );
    final supplierIdController = TextEditingController(
      text: item['supplier_id']?.toString() ?? '',
    );
    final expiryDateController = TextEditingController(
      text: item['latest_expiry_date'] ?? '',
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
                Icon(Icons.inventory, color: Colors.indigo),
                SizedBox(width: 8),
                Text(item.isEmpty ? 'Add Product' : 'Edit Product'),
              ],
            ),
            content: Container(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      supplierIdController,
                      'Supplier ID',
                      Icons.local_shipping,
                      isNumber: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      nameController,
                      'Product Name',
                      Icons.inventory,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      unitPriceController,
                      'Unit Price',
                      Icons.attach_money,
                      isNumber: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      quantityController,
                      'Quantity',
                      Icons.numbers,
                      isNumber: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      expiryDateController,
                      'Expiry Date (YYYY-MM-DD)',
                      Icons.calendar_today,
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
                  String? formattedDate;
                  if (expiryDateController.text.isNotEmpty) {
                    try {
                      // Parse whatever is in the text field into a DateTime
                      final parsedDate = DateTime.parse(
                        expiryDateController.text,
                      );
                      // Format as YYYY-MM-DD for MySQL DATE column
                      formattedDate = DateFormat(
                        'yyyy-MM-dd',
                      ).format(parsedDate);
                    } catch (e) {
                      // If parsing fails, you could handle the error or leave it null
                      formattedDate = null;
                    }
                  }

                  await _saveProduct(context, item, {
                    'supplier_id': int.tryParse(supplierIdController.text),
                    'name': nameController.text,
                    'unit_price': double.tryParse(unitPriceController.text),
                    'quantity': int.tryParse(quantityController.text),
                    'latest_expiry_date': formattedDate, // ✅ only YYYY-MM-DD
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                child: const Text('Save'),
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

  _saveProduct(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, dynamic> data,
  ) async {
    try {
      final url =
          item.isEmpty
              ? 'http://localhost:3000/api/products'
              : 'http://localhost:3000/api/products/${item['product_id']}';

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
            content: Text('Product saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the page to show updated data
        (context as Element).markNeedsBuild();
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

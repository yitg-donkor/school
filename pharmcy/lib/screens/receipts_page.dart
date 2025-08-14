import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmcy/pharmacist_interface.dart';

class ReceiptsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedGenericListPage(
      title: 'Receipts',
      endpoint: 'receipts',
      columns: ['receipt_number', 'pharm_name', 'prod_name', 'total_amount'],
      themeColor: Colors.amber,
      icon: Icons.receipt_long,
      onAdd: (item) => _showReceiptDialog(context, item),
      onEdit: (item) => _showReceiptDialog(context, item),
    );
  }

  _showReceiptDialog(BuildContext context, Map<String, dynamic> item) {
    final receiptNumberController = TextEditingController(
      text: item['receipt_number'] ?? '',
    );
    final pharmNameController = TextEditingController(
      text: item['pharm_name'] ?? '',
    );
    final saleIdController = TextEditingController(
      text: item['sale_id']?.toString() ?? '',
    );
    final prodNameController = TextEditingController(
      text: item['prod_name'] ?? '',
    );
    final prodQuantityController = TextEditingController(
      text: item['prod_quantity']?.toString() ?? '',
    );
    final totalAmountController = TextEditingController(
      text: item['total_amount']?.toString() ?? '',
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
                Icon(Icons.receipt_long, color: Colors.amber),
                SizedBox(width: 8),
                Text(item.isEmpty ? 'Add Receipt' : 'Edit Receipt'),
              ],
            ),
            content: Container(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      receiptNumberController,
                      'Receipt Number',
                      Icons.receipt,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      pharmNameController,
                      'Pharmacy Name',
                      Icons.business,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      saleIdController,
                      'Sale ID',
                      Icons.shopping_cart,
                      isNumber: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      prodNameController,
                      'Product Name',
                      Icons.inventory,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      prodQuantityController,
                      'Quantity',
                      Icons.numbers,
                      isNumber: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      totalAmountController,
                      'Total Amount',
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
                  await _saveReceipt(context, item, {
                    'receipt_number': receiptNumberController.text,
                    'pharm_name': pharmNameController.text,
                    'sale_id': int.tryParse(saleIdController.text),
                    'prod_name': prodNameController.text,
                    'prod_quantity': int.tryParse(prodQuantityController.text),
                    'total_amount': double.tryParse(totalAmountController.text),
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
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

  _saveReceipt(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, dynamic> data,
  ) async {
    try {
      final url =
          item.isEmpty
              ? 'http://localhost:3000/api/receipts'
              : 'http://localhost:3000/api/receipts/${item['receipt_number']}';

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
            content: Text('Receipt saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving receipt: $e')));
    }
  }
}

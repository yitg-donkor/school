// Enhanced SalesPage with dropdown selections
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmcy/pharmacist_interface.dart';

class SalesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedGenericListPage(
      title: 'Sales',
      endpoint: 'sales',
      columns: ['sale_id', 'customer_name', 'product_name', 'total_cost'],
      themeColor: Colors.red,
      icon: Icons.shopping_cart,
      onAdd: (item) => _showSaleDialog(context, item),
      onEdit: (item) => _showSaleDialog(context, item),
    );
  }

  _showSaleDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => SaleDialogWidget(item: item),
    );
  }
}

// New StatefulWidget for the sale dialog
class SaleDialogWidget extends StatefulWidget {
  final Map<String, dynamic> item;

  SaleDialogWidget({required this.item});

  @override
  _SaleDialogWidgetState createState() => _SaleDialogWidgetState();
}

class _SaleDialogWidgetState extends State<SaleDialogWidget> {
  // Controllers for other fields
  final quantityController = TextEditingController();
  final totalCostController = TextEditingController();
  final paymentMethodController = TextEditingController();
  final receiptNumController = TextEditingController();

  // Dropdown values
  int? selectedEmployeeId;
  int? selectedCustomerId;
  int? selectedProductId;

  // Data lists for dropdowns
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> products = [];

  // Loading states
  bool isLoadingEmployees = true;
  bool isLoadingCustomers = true;
  bool isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadDropdownData();
  }

  void _initializeData() {
    if (widget.item.isNotEmpty) {
      selectedEmployeeId = widget.item['employee_id'];
      selectedCustomerId = widget.item['customer_id'];
      selectedProductId = widget.item['product_id'];
      quantityController.text = widget.item['quantity']?.toString() ?? '';
      totalCostController.text = widget.item['total_cost']?.toString() ?? '';
      paymentMethodController.text = widget.item['payment_method'] ?? '';
      receiptNumController.text = widget.item['receipt_num'] ?? '';
    }
  }

  Future<void> _loadDropdownData() async {
    await Future.wait([_loadEmployees(), _loadCustomers(), _loadProducts()]);
  }

  Future<void> _loadEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/employees'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          employees = List<Map<String, dynamic>>.from(
            data is List ? data : [data],
          );
          isLoadingEmployees = false;
        });
      }
    } catch (e) {
      print('Error loading employees: $e');
      setState(() {
        isLoadingEmployees = false;
      });
    }
  }

  Future<void> _loadCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/customers'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          customers = List<Map<String, dynamic>>.from(
            data is List ? data : [data],
          );
          isLoadingCustomers = false;
        });
      }
    } catch (e) {
      print('Error loading customers: $e');
      setState(() {
        isLoadingCustomers = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/products'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = List<Map<String, dynamic>>.from(
            data is List ? data : [data],
          );
          isLoadingProducts = false;
        });
      }
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        isLoadingProducts = false;
      });
    }
  }

  // Auto-calculate total when quantity changes
  void _calculateTotal() {
    if (selectedProductId != null && quantityController.text.isNotEmpty) {
      final product = products.firstWhere(
        (p) => p['product_id'] == selectedProductId,
        orElse: () => {},
      );

      if (product.isNotEmpty && product['unit_price'] != null) {
        final unitPrice =
            double.tryParse(product['unit_price'].toString()) ?? 0;
        final quantity = int.tryParse(quantityController.text) ?? 0;
        final total = unitPrice * quantity;

        setState(() {
          totalCostController.text = total.toStringAsFixed(2);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.shopping_cart, color: Colors.red),
          SizedBox(width: 8),
          Text(widget.item.isEmpty ? 'Add Sale' : 'Edit Sale'),
        ],
      ),
      content: Container(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Employee Dropdown
              _buildDropdownField<int>(
                value: selectedEmployeeId,
                label: 'Select Employee',
                icon: Icons.person,
                isLoading: isLoadingEmployees,
                items: employees,
                displayKey: 'name',
                valueKey: 'employee_id',
                onChanged: (value) {
                  setState(() {
                    selectedEmployeeId = value;
                  });
                },
              ),
              SizedBox(height: 16),

              // Customer Dropdown
              _buildDropdownField<int>(
                value: selectedCustomerId,
                label: 'Select Customer',
                icon: Icons.person_outline,
                isLoading: isLoadingCustomers,
                items: customers,
                displayKey: 'name',
                valueKey: 'customer_id',
                onChanged: (value) {
                  setState(() {
                    selectedCustomerId = value;
                  });
                },
              ),
              SizedBox(height: 16),

              // Product Dropdown
              _buildDropdownField<int>(
                value: selectedProductId,
                label: 'Select Product',
                icon: Icons.inventory,
                isLoading: isLoadingProducts,
                items: products,
                displayKey: 'name',
                valueKey: 'product_id',
                onChanged: (value) {
                  setState(() {
                    selectedProductId = value;
                    _calculateTotal(); // Recalculate when product changes
                  });
                },
              ),
              SizedBox(height: 16),

              // Show product price info
              if (selectedProductId != null) ...[
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Unit Price: GH₵${products.firstWhere((p) => p['product_id'] == selectedProductId)['unit_price']}',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],

              // Quantity Field
              _buildTextField(
                quantityController,
                'Quantity',
                Icons.numbers,
                isNumber: true,
                onChanged: (value) {
                  _calculateTotal(); // Recalculate when quantity changes
                },
              ),
              SizedBox(height: 16),

              // Total Cost Field (auto-calculated but editable)
              _buildTextField(
                totalCostController,
                'Total Cost (Auto-calculated)',
                Icons.attach_money,
                isNumber: true,
              ),
              SizedBox(height: 16),

              // Payment Method Dropdown
              _buildPaymentMethodDropdown(),
              SizedBox(height: 16),

              // Receipt Number Field
              _buildTextField(
                receiptNumController,
                'Receipt Number',
                Icons.receipt,
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
          onPressed:
              _isFormValid()
                  ? () async {
                    await _saveSale();
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text('Save Sale'),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String label,
    required IconData icon,
    required bool isLoading,
    required List<Map<String, dynamic>> items,
    required String displayKey,
    required String valueKey,
    required void Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child:
          isLoading
              ? Container(
                height: 56,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Loading ${label.toLowerCase()}...'),
                    ],
                  ),
                ),
              )
              : DropdownButtonFormField<T>(
                value: value,
                decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: Icon(icon),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items:
                    items.map((item) {
                      return DropdownMenuItem<T>(
                        value: item[valueKey] as T,
                        child: Row(
                          children: [
                            Text(
                              'ID: ${item[valueKey]} - ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item[displayKey]?.toString() ?? 'Unknown',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: onChanged,
                hint: Text('Select ${label.toLowerCase()}'),
              ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    final paymentMethods = ['Cash', 'Mobile Money', 'Bank Transfer', 'Card'];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: DropdownButtonFormField<String>(
        value:
            paymentMethodController.text.isNotEmpty
                ? paymentMethodController.text
                : null,
        decoration: InputDecoration(
          labelText: 'Payment Method',
          prefixIcon: Icon(Icons.payment),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items:
            paymentMethods.map((method) {
              return DropdownMenuItem<String>(
                value: method,
                child: Text(method),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            paymentMethodController.text = value ?? '';
          });
        },
        hint: Text('Select payment method'),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  bool _isFormValid() {
    return selectedEmployeeId != null &&
        selectedCustomerId != null &&
        selectedProductId != null &&
        quantityController.text.isNotEmpty &&
        totalCostController.text.isNotEmpty &&
        paymentMethodController.text.isNotEmpty;
  }

  Future<void> _saveSale() async {
    try {
      final saleData = {
        'employee_id': selectedEmployeeId,
        'customer_id': selectedCustomerId,
        'product_id': selectedProductId,
        'quantity': int.tryParse(quantityController.text),
        'total_cost': double.tryParse(totalCostController.text),
        'status': 'completed',
        'payment_method': paymentMethodController.text,
        'receipt_num': receiptNumController.text,
      };

      final response = await http.post(
        Uri.parse('http://localhost:3000/api/sales'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(saleData),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sale saved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the parent page
        if (context is Element) {
          (context as Element).markNeedsBuild();
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving sale: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    totalCostController.dispose();
    paymentMethodController.dispose();
    receiptNumController.dispose();
    super.dispose();
  }
}

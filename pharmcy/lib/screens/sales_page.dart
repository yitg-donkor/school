// Fixed SalesPage with proper widget structure
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

// Fixed StatefulWidget for the sale dialog
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
      print('📞 Loading employees from API...');
      final response = await http
          .get(
            Uri.parse('http://localhost:3000/api/employees'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 10));

      print('👥 Employees Response Status: ${response.statusCode}');
      print('👥 Employees Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Map<String, dynamic>> employeeList = [];

        // Handle different response formats
        if (data is List) {
          employeeList = List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          // Check if it's wrapped in a success response
          if (data['success'] == true && data['data'] is List) {
            employeeList = List<Map<String, dynamic>>.from(data['data']);
          } else if (data['success'] == true && data['data'] is Map) {
            employeeList = [Map<String, dynamic>.from(data['data'])];
          } else {
            employeeList = [Map<String, dynamic>.from(data)];
          }
        }

        print('👥 Processed ${employeeList.length} employees');
        if (mounted) {
          setState(() {
            employees = employeeList;
            isLoadingEmployees = false;
          });
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error loading employees: $e');
      if (mounted) {
        setState(() {
          isLoadingEmployees = false;
          employees = []; // Set empty list on error
        });

        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load employees: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadCustomers() async {
    try {
      print('📞 Loading customers from API...');
      final response = await http
          .get(
            Uri.parse('http://localhost:3000/api/customers'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 10));

      print('👤 Customers Response Status: ${response.statusCode}');
      print('👤 Customers Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Map<String, dynamic>> customerList = [];

        // Handle different response formats
        if (data is List) {
          customerList = List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          // Check if it's wrapped in a success response
          if (data['success'] == true && data['data'] is List) {
            customerList = List<Map<String, dynamic>>.from(data['data']);
          } else if (data['success'] == true && data['data'] is Map) {
            customerList = [Map<String, dynamic>.from(data['data'])];
          } else {
            customerList = [Map<String, dynamic>.from(data)];
          }
        }

        print('👤 Processed ${customerList.length} customers');
        if (mounted) {
          setState(() {
            customers = customerList;
            isLoadingCustomers = false;
          });
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error loading customers: $e');
      if (mounted) {
        setState(() {
          isLoadingCustomers = false;
          customers = []; // Set empty list on error
        });

        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load customers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadProducts() async {
    try {
      print('📞 Loading products from API...');
      final response = await http
          .get(
            Uri.parse('http://localhost:3000/api/products'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 10));

      print('📦 Products Response Status: ${response.statusCode}');
      print('📦 Products Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Map<String, dynamic>> productList = [];

        // Handle different response formats
        if (data is List) {
          productList = List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          // Check if it's wrapped in a success response
          if (data['success'] == true && data['data'] is List) {
            productList = List<Map<String, dynamic>>.from(data['data']);
          } else if (data['success'] == true && data['data'] is Map) {
            productList = [Map<String, dynamic>.from(data['data'])];
          } else {
            productList = [Map<String, dynamic>.from(data)];
          }
        }

        print('📦 Processed ${productList.length} products');
        if (mounted) {
          setState(() {
            products = productList;
            isLoadingProducts = false;
          });
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error loading products: $e');
      if (mounted) {
        setState(() {
          isLoadingProducts = false;
          products = []; // Set empty list on error
        });

        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        constraints: BoxConstraints(maxHeight: 600), // Add height constraint
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
                        child: Container(
                          width: 350, // Fixed width to prevent overflow
                          child: Row(
                            children: [
                              Text(
                                'ID: ${item[valueKey]} - ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  item[displayKey]?.toString() ?? 'Unknown',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: onChanged,
                hint: Text('Select ${label.toLowerCase()}'),
                isExpanded: true, // This prevents overflow issues
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
        isExpanded: true, // This prevents overflow issues
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
        if (context.mounted) {
          // Trigger a rebuild of the parent widget if possible
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

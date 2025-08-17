import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportsDashboard extends StatefulWidget {
  @override
  _ReportsDashboardState createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends State<ReportsDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  String selectedPeriod = 'month';

  // Update the base URL to match your server
  // ignore: unused_field
  static const String baseUrl = 'http://localhost:3000/api';

  final List<Map<String, String>> periods = [
    {'display': 'Today', 'value': 'today'},
    {'display': 'This Week', 'value': 'week'},
    {'display': 'This Month', 'value': 'month'},
    {'display': 'This Quarter', 'value': 'quarter'},
    {'display': 'This Year', 'value': 'year'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reports Dashboard',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Comprehensive pharmacy analytics and insights',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedPeriod,
                          dropdownColor: Color(0xFF667eea),
                          style: TextStyle(color: Colors.white),
                          items:
                              periods.map((period) {
                                return DropdownMenuItem<String>(
                                  value: period['value'],
                                  child: Text(period['display']!),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPeriod = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: 'Sales Performance'),
                    Tab(text: 'Inventory'),
                    Tab(text: 'Employee Performance'),
                    Tab(text: 'Branch Performance'),
                    Tab(text: 'Medicine Expiry'),
                    Tab(text: 'Supplier Analysis'),
                    Tab(text: 'Customer Insights'),
                    Tab(text: 'Financial Summary'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Color(0xFFF8F9FA),
        child: TabBarView(
          controller: _tabController,
          children: [
            SalesPerformanceReport(selectedPeriod: selectedPeriod),
            InventoryManagementReport(),
            EmployeePerformanceReport(selectedPeriod: selectedPeriod),
            BranchPerformanceReport(selectedPeriod: selectedPeriod),
            MedicineExpiryReport(),
            SupplierAnalysisReport(),
            CustomerInsightsReport(),
            FinancialSummaryReport(selectedPeriod: selectedPeriod),
          ],
        ),
      ),
    );
  }
}

// Fixed Sales Performance Report
class SalesPerformanceReport extends StatefulWidget {
  final String selectedPeriod;

  const SalesPerformanceReport({Key? key, required this.selectedPeriod})
    : super(key: key);

  @override
  _SalesPerformanceReportState createState() => _SalesPerformanceReportState();
}

class _SalesPerformanceReportState extends State<SalesPerformanceReport> {
  Map<String, dynamic> salesData = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

  @override
  void didUpdateWidget(SalesPerformanceReport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPeriod != widget.selectedPeriod) {
      fetchSalesData();
    }
  }

  fetchSalesData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try the dedicated reports endpoint first
      final response = await http
          .get(
            Uri.parse(
              'http://localhost:3000/api/reports/sales-performance?period=${widget.selectedPeriod}',
            ),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            salesData = data['data'];
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Reports endpoint failed: $e');
    }

    // Fallback to basic sales endpoint
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/sales'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          salesData = _processSalesData(data is List ? data : []);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load sales data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load sales data: $e';
      });
    }
  }

  Map<String, dynamic> _processSalesData(List<dynamic> sales) {
    double totalRevenue = 0;
    int totalTransactions = sales.length;
    Map<String, int> productSales = {};
    Map<String, double> employeeSales = {};
    Map<String, int> paymentMethods = {};

    for (var sale in sales) {
      try {
        final cost =
            double.tryParse(sale['total_cost']?.toString() ?? '0') ?? 0;
        totalRevenue += cost;

        // Product sales count
        String productName = sale['product_name']?.toString() ?? 'Unknown';
        productSales[productName] = (productSales[productName] ?? 0) + 1;

        // Employee sales
        String empName = sale['emp_name']?.toString() ?? 'Unknown';
        employeeSales[empName] = (employeeSales[empName] ?? 0) + cost;

        // Payment methods
        String paymentMethod = sale['payment_method']?.toString() ?? 'Cash';
        paymentMethods[paymentMethod] =
            (paymentMethods[paymentMethod] ?? 0) + 1;
      } catch (e) {
        print('Error processing sale: $e');
      }
    }

    return {
      'summary': {
        'totalRevenue': totalRevenue,
        'totalTransactions': totalTransactions,
        'avgTransactionValue':
            totalTransactions > 0 ? totalRevenue / totalTransactions : 0,
      },
      'topProducts': _getTopEntries(productSales, 5),
      'employeePerformance': _getTopEntriesDouble(employeeSales, 5),
      'paymentMethods': paymentMethods,
    };
  }

  List<MapEntry<String, int>> _getTopEntries(Map<String, int> map, int count) {
    var entries = map.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(count).toList();
  }

  List<MapEntry<String, double>> _getTopEntriesDouble(
    Map<String, double> map,
    int count,
  ) {
    var entries = map.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF667eea)),
            SizedBox(height: 16),
            Text('Loading sales data...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(errorMessage!, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(onPressed: fetchSalesData, child: Text('Retry')),
          ],
        ),
      );
    }

    final summary = salesData['summary'] ?? {};

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Revenue',
                  'GH₵ ${(summary['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Total Transactions',
                  (summary['totalTransactions'] ?? 0).toString(),
                  Icons.receipt,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Average Transaction',
                  'GH₵ ${(summary['avgTransactionValue'] ?? 0).toStringAsFixed(2)}',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Charts Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildChartCard(
                  'Top Selling Products',
                  _buildProductChart(),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Employee Performance',
                  _buildEmployeeChart(),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Payment Methods
          _buildChartCard(
            'Payment Methods Distribution',
            _buildPaymentMethodsChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
              Icon(Icons.trending_up, color: Colors.green, size: 16),
            ],
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3e50),
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3e50),
            ),
          ),
          SizedBox(height: 20),
          chart,
        ],
      ),
    );
  }

  Widget _buildProductChart() {
    final topProducts =
        salesData['topProducts'] as List<MapEntry<String, int>>? ?? [];

    return Container(
      height: 300,
      child:
          topProducts.isEmpty
              ? Center(child: Text('No product data available'))
              : ListView.builder(
                itemCount: topProducts.length,
                itemBuilder: (context, index) {
                  final product = topProducts[index];
                  final maxValue =
                      topProducts.isNotEmpty ? topProducts[0].value : 1;
                  final percentage = (product.value / maxValue * 100).clamp(
                    0,
                    100,
                  );

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.key,
                                style: TextStyle(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('${product.value} sales'),
                          ],
                        ),
                        SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF667eea),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildEmployeeChart() {
    final employeePerf =
        salesData['employeePerformance'] as List<MapEntry<String, double>>? ??
        [];

    return Container(
      height: 300,
      child:
          employeePerf.isEmpty
              ? Center(child: Text('No employee data available'))
              : ListView.builder(
                itemCount: employeePerf.length,
                itemBuilder: (context, index) {
                  final employee = employeePerf[index];
                  final maxValue =
                      employeePerf.isNotEmpty ? employeePerf[0].value : 1;
                  final percentage = (employee.value / maxValue * 100).clamp(
                    0,
                    100,
                  );

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                employee.key,
                                style: TextStyle(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('GH₵ ${employee.value.toStringAsFixed(2)}'),
                          ],
                        ),
                        SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildPaymentMethodsChart() {
    final paymentMethods =
        salesData['paymentMethods'] as Map<String, int>? ?? {};
    final total = paymentMethods.values.fold(0, (sum, value) => sum + value);

    return Container(
      height: 200,
      child:
          paymentMethods.isEmpty
              ? Center(child: Text('No payment method data available'))
              : Row(
                children:
                    paymentMethods.entries.map((entry) {
                      final percentage =
                          total > 0 ? (entry.value / total * 100) : 0;
                      final colors = [
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                        Colors.purple,
                      ];
                      final colorIndex =
                          paymentMethods.keys.toList().indexOf(entry.key) %
                          colors.length;

                      return Expanded(
                        flex: entry.value,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: colors[colorIndex],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                entry.key,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${entry.value}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
    );
  }
}

// Inventory Management Report
class InventoryManagementReport extends StatefulWidget {
  @override
  _InventoryManagementReportState createState() =>
      _InventoryManagementReportState();
}

class _InventoryManagementReportState extends State<InventoryManagementReport> {
  Map<String, dynamic> inventoryData = {};
  bool isLoading = true;
  String? errorMessage;
  String filterType = 'all';

  @override
  void initState() {
    super.initState();
    fetchInventoryData();
  }

  fetchInventoryData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try the reports endpoint first
      final response = await http
          .get(
            Uri.parse(
              'http://localhost:3000/api/reports/inventory?filter=$filterType',
            ),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            inventoryData = data['data'];
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Inventory reports endpoint failed: $e');
    }

    // Fallback to basic products endpoint
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/products'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          inventoryData = _processInventoryData(data is List ? data : []);
          isLoading = false;
        });
      } else {
        throw Exception(
          'Failed to load inventory data: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load inventory data: $e';
      });
    }
  }

  Map<String, dynamic> _processInventoryData(List<dynamic> products) {
    int totalProducts = products.length;
    int lowStockCount = 0;
    int outOfStockCount = 0;
    int expiringSoonCount = 0;
    int expiredCount = 0;
    double totalValue = 0;

    List<Map<String, dynamic>> processedProducts = [];

    for (var product in products) {
      try {
        final quantity =
            int.tryParse(product['quantity']?.toString() ?? '0') ?? 0;
        final unitPrice =
            double.tryParse(product['unit_price']?.toString() ?? '0') ?? 0;
        final productValue = quantity * unitPrice;
        totalValue += productValue;

        String status = 'Good';
        Color statusColor = Colors.green;
        int daysToExpiry = 999;

        if (quantity == 0) {
          outOfStockCount++;
          status = 'Out of Stock';
          statusColor = Colors.red;
        } else if (quantity <= 10) {
          lowStockCount++;
          status = 'Low Stock';
          statusColor = Colors.orange;
        }

        // Check expiry
        if (product['latest_expiry_date'] != null) {
          try {
            final expiryDate = DateTime.parse(product['latest_expiry_date']);
            daysToExpiry = expiryDate.difference(DateTime.now()).inDays;

            if (daysToExpiry < 0) {
              expiredCount++;
              status = 'Expired';
              statusColor = Colors.red;
            } else if (daysToExpiry <= 30) {
              expiringSoonCount++;
              if (status == 'Good') {
                status = 'Expiring Soon';
                statusColor = Colors.amber;
              }
            }
          } catch (e) {
            // Invalid date format
          }
        }

        processedProducts.add({
          ...product,
          'status': status,
          'statusColor': statusColor,
          'daysToExpiry': daysToExpiry,
          'totalValue': productValue,
        });
      } catch (e) {
        print('Error processing product: $e');
      }
    }

    return {
      'summary': {
        'totalProducts': totalProducts,
        'totalValue': totalValue,
        'lowStockCount': lowStockCount,
        'outOfStockCount': outOfStockCount,
        'expiringSoonCount': expiringSoonCount,
        'expiredCount': expiredCount,
      },
      'products': processedProducts,
    };
  }

  List<Map<String, dynamic>> get filteredProducts {
    final products =
        inventoryData['products'] as List<Map<String, dynamic>>? ?? [];

    switch (filterType) {
      case 'low-stock':
        return products.where((p) => p['status'] == 'Low Stock').toList();
      case 'out-of-stock':
        return products.where((p) => p['status'] == 'Out of Stock').toList();
      case 'expiring-soon':
        return products.where((p) => p['status'] == 'Expiring Soon').toList();
      case 'expired':
        return products.where((p) => p['status'] == 'Expired').toList();
      default:
        return products;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF667eea)),
            SizedBox(height: 16),
            Text('Loading inventory data...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(errorMessage!, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(onPressed: fetchInventoryData, child: Text('Retry')),
          ],
        ),
      );
    }

    final summary = inventoryData['summary'] ?? {};

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics
          Row(
            children: [
              Expanded(
                child: _buildInventoryMetricCard(
                  'Total Products',
                  (summary['totalProducts'] ?? 0).toString(),
                  Icons.inventory,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInventoryMetricCard(
                  'Low Stock Items',
                  (summary['lowStockCount'] ?? 0).toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInventoryMetricCard(
                  'Out of Stock',
                  (summary['outOfStockCount'] ?? 0).toString(),
                  Icons.error,
                  Colors.red,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInventoryMetricCard(
                  'Total Value',
                  'GH₵ ${(summary['totalValue'] ?? 0).toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Filter and Products List
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventory Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                        {'display': 'All', 'value': 'all'},
                        {'display': 'Low Stock', 'value': 'low-stock'},
                        {'display': 'Out of Stock', 'value': 'out-of-stock'},
                        {'display': 'Expiring Soon', 'value': 'expiring-soon'},
                        {'display': 'Expired', 'value': 'expired'},
                      ].map((filter) {
                        return FilterChip(
                          label: Text(filter['display']!),
                          selected: filterType == filter['value'],
                          onSelected: (selected) {
                            setState(() {
                              filterType = selected ? filter['value']! : 'all';
                            });
                          },
                          selectedColor: Color(0xFF667eea).withOpacity(0.2),
                          checkmarkColor: Color(0xFF667eea),
                        );
                      }).toList(),
                ),
                SizedBox(height: 16),

                // Products List
                Container(
                  height: 400,
                  child:
                      filteredProducts.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text('No products found for selected filter'),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return _buildProductTile(product);
                            },
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3e50),
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProductTile(Map<String, dynamic> product) {
    final quantity = int.tryParse(product['quantity']?.toString() ?? '0') ?? 0;
    final unitPrice =
        double.tryParse(product['unit_price']?.toString() ?? '0') ?? 0;
    final totalValue = quantity * unitPrice;
    final status = product['status'] ?? 'Good';
    final statusColor = product['statusColor'] ?? Colors.green;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']?.toString() ?? 'Unknown Product',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Supplier: ${product['supplier_name']?.toString() ?? 'Unknown'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Qty: $quantity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'GH₵ ${totalValue.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Employee Performance Report with proper error handling
class EmployeePerformanceReport extends StatefulWidget {
  final String selectedPeriod;

  const EmployeePerformanceReport({Key? key, required this.selectedPeriod})
    : super(key: key);

  @override
  _EmployeePerformanceReportState createState() =>
      _EmployeePerformanceReportState();
}

class _EmployeePerformanceReportState extends State<EmployeePerformanceReport> {
  List<Map<String, dynamic>> employeeData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchEmployeeData();
  }

  @override
  void didUpdateWidget(EmployeePerformanceReport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPeriod != widget.selectedPeriod) {
      fetchEmployeeData();
    }
  }

  fetchEmployeeData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try the reports endpoint first
      final response = await http
          .get(
            Uri.parse(
              'http://localhost:3000/api/reports/employee-performance?period=${widget.selectedPeriod}',
            ),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            employeeData = List<Map<String, dynamic>>.from(
              data['data']['employees'] ?? [],
            );
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Employee reports endpoint failed: $e');
    }

    // Fallback to manual data processing
    try {
      final futures = await Future.wait([
        http
            .get(Uri.parse('http://localhost:3000/api/employees'))
            .timeout(Duration(seconds: 10)),
        http
            .get(Uri.parse('http://localhost:3000/api/sales'))
            .timeout(Duration(seconds: 10)),
        http
            .get(Uri.parse('http://localhost:3000/api/attendance'))
            .timeout(Duration(seconds: 10)),
      ]);

      if (futures.every((response) => response.statusCode == 200)) {
        final employees = json.decode(futures[0].body);
        final sales = json.decode(futures[1].body);
        final attendance = json.decode(futures[2].body);

        setState(() {
          employeeData = _processEmployeeData(
            employees is List ? employees : [],
            sales is List ? sales : [],
            attendance is List ? attendance : [],
          );
          isLoading = false;
        });
      } else {
        throw Exception('One or more API calls failed');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load employee data: $e';
      });
    }
  }

  List<Map<String, dynamic>> _processEmployeeData(
    List<dynamic> employees,
    List<dynamic> sales,
    List<dynamic> attendance,
  ) {
    return employees.map((emp) {
      final empId = emp['employee_id'];

      // Calculate sales performance
      final empSales = sales.where((s) => s['employee_id'] == empId).toList();
      final totalSales = empSales.length;
      final totalRevenue = empSales.fold(
        0.0,
        (sum, s) =>
            sum + (double.tryParse(s['total_cost']?.toString() ?? '0') ?? 0),
      );

      // Calculate attendance
      final empAttendance =
          attendance.where((a) => a['emp_id'] == empId).toList();
      final attendanceDays = empAttendance.length;

      // Calculate working hours
      double totalHours = 0;
      for (var att in empAttendance) {
        if (att['check_in_time'] != null && att['check_out_time'] != null) {
          try {
            final checkIn = att['check_in_time'].toString().split(':');
            final checkOut = att['check_out_time'].toString().split(':');
            if (checkIn.length >= 2 && checkOut.length >= 2) {
              final checkInMinutes =
                  int.parse(checkIn[0]) * 60 + int.parse(checkIn[1]);
              final checkOutMinutes =
                  int.parse(checkOut[0]) * 60 + int.parse(checkOut[1]);
              if (checkOutMinutes > checkInMinutes) {
                totalHours += (checkOutMinutes - checkInMinutes) / 60;
              }
            }
          } catch (e) {
            // Skip invalid time entries
          }
        }
      }

      return {
        'emp_id': empId,
        'emp_name': emp['name']?.toString() ?? 'Unknown',
        'emp_position': emp['position']?.toString() ?? 'Unknown',
        'brch_name': emp['branch_name']?.toString() ?? 'Unknown Branch',
        'total_sales': totalSales,
        'total_revenue': totalRevenue,
        'avg_sale_value': totalSales > 0 ? totalRevenue / totalSales : 0,
        'attendance_days': attendanceDays,
        'avg_hours_per_day':
            attendanceDays > 0 ? totalHours / attendanceDays : 0,
        'total_hours': totalHours,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF667eea)),
            SizedBox(height: 16),
            Text('Loading employee performance data...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(errorMessage!, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(onPressed: fetchEmployeeData, child: Text('Retry')),
          ],
        ),
      );
    }

    // Sort employees by total revenue
    employeeData.sort(
      (a, b) => (b['total_revenue'] as double).compareTo(
        a['total_revenue'] as double,
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee Performance Rankings (${widget.selectedPeriod.toUpperCase()})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 500,
                  child:
                      employeeData.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text('No employee data available'),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: employeeData.length,
                            itemBuilder: (context, index) {
                              final employee = employeeData[index];
                              return _buildEmployeeCard(employee, index + 1);
                            },
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> employee, int rank) {
    final rankColors = [Colors.amber, Colors.grey, Colors.brown];
    final rankColor = rank <= 3 ? rankColors[rank - 1] : Colors.blue;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rankColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),

          // Employee Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee['emp_name'] ?? 'Unknown',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  '${employee['emp_position'] ?? 'Unknown'} • ${employee['brch_name'] ?? 'Unknown Branch'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          // Performance Metrics
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'GH₵ ${(employee['total_revenue'] as double).toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green[700],
                ),
              ),
              Text(
                '${employee['total_sales']} sales',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                '${employee['attendance_days']} days',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                '${(employee['total_hours'] as double).toStringAsFixed(1)} hrs',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Branch Performance Report
class BranchPerformanceReport extends StatefulWidget {
  final String selectedPeriod;

  const BranchPerformanceReport({Key? key, required this.selectedPeriod})
    : super(key: key);

  @override
  _BranchPerformanceReportState createState() =>
      _BranchPerformanceReportState();
}

class _BranchPerformanceReportState extends State<BranchPerformanceReport> {
  List<Map<String, dynamic>> branchData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchBranchData();
  }

  @override
  void didUpdateWidget(BranchPerformanceReport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPeriod != widget.selectedPeriod) {
      fetchBranchData();
    }
  }

  fetchBranchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try the reports endpoint first
      final response = await http
          .get(
            Uri.parse(
              'http://localhost:3000/api/reports/branch-performance?period=${widget.selectedPeriod}',
            ),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            branchData = List<Map<String, dynamic>>.from(
              data['data']['branches'] ?? [],
            );
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Branch reports endpoint failed: $e');
    }

    // Fallback to manual processing
    try {
      final futures = await Future.wait([
        http
            .get(Uri.parse('http://localhost:3000/api/branches'))
            .timeout(Duration(seconds: 10)),
        http
            .get(Uri.parse('http://localhost:3000/api/employees'))
            .timeout(Duration(seconds: 10)),
        http
            .get(Uri.parse('http://localhost:3000/api/sales'))
            .timeout(Duration(seconds: 10)),
      ]);

      if (futures.every((response) => response.statusCode == 200)) {
        final branches = json.decode(futures[0].body);
        final employees = json.decode(futures[1].body);
        final sales = json.decode(futures[2].body);

        setState(() {
          branchData = _processBranchData(
            branches is List ? branches : [],
            employees is List ? employees : [],
            sales is List ? sales : [],
          );
          isLoading = false;
        });
      } else {
        throw Exception('One or more API calls failed');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load branch data: $e';
      });
    }
  }

  List<Map<String, dynamic>> _processBranchData(
    List<dynamic> branches,
    List<dynamic> employees,
    List<dynamic> sales,
  ) {
    return branches.map((branch) {
      final branchId = branch['branch_id'];

      // Get employees for this branch
      final branchEmployees =
          employees.where((e) => e['branch_id'] == branchId).toList();
      final employeeIds = branchEmployees.map((e) => e['employee_id']).toList();

      // Get sales for this branch's employees
      final branchSales =
          sales.where((s) => employeeIds.contains(s['employee_id'])).toList();
      final totalRevenue = branchSales.fold(
        0.0,
        (sum, s) =>
            sum + (double.tryParse(s['total_cost']?.toString() ?? '0') ?? 0),
      );
      final totalTransactions = branchSales.length;

      return {
        'brch_id': branchId,
        'brch_name': branch['name']?.toString() ?? 'Unknown Branch',
        'brch_address': branch['address']?.toString() ?? 'Unknown Address',
        'pharm_name': branch['pharmacy_name']?.toString() ?? 'Unknown Pharmacy',
        'employee_count': branchEmployees.length,
        'total_revenue': totalRevenue,
        'total_transactions': totalTransactions,
        'avg_transaction_value':
            totalTransactions > 0 ? totalRevenue / totalTransactions : 0.0,
        'total_units_sold': branchSales.fold<int>(
          0,
          (sum, s) => sum + ((s['quantity'] as num?)?.toInt() ?? 0),
        ),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF667eea)),
            SizedBox(height: 16),
            Text('Loading branch performance data...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(errorMessage!, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(onPressed: fetchBranchData, child: Text('Retry')),
          ],
        ),
      );
    }

    // Sort branches by total revenue
    branchData.sort(
      (a, b) => (b['total_revenue'] as double).compareTo(
        a['total_revenue'] as double,
      ),
    );

    final totalRevenue = branchData.fold<double>(
      0.0,
      (sum, branch) => sum + (branch['total_revenue'] as double? ?? 0.0),
    );

    final totalTransactions = branchData.fold<int>(
      0,
      (sum, branch) => sum + (branch['total_transactions'] as int? ?? 0),
    );

    final totalEmployees = branchData.fold<int>(
      0,
      (sum, branch) => sum + (branch['employee_count'] as int? ?? 0),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Metrics
          Row(
            children: [
              Expanded(
                child: _buildBranchMetricCard(
                  'Total Branches',
                  branchData.length.toString(),
                  Icons.business,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildBranchMetricCard(
                  'Total Revenue',
                  'GH₵ ${totalRevenue.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildBranchMetricCard(
                  'Total Employees',
                  totalEmployees.toString(),
                  Icons.people,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildBranchMetricCard(
                  'Total Transactions',
                  totalTransactions.toString(),
                  Icons.receipt,
                  Colors.purple,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Branch Performance List
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Branch Performance Comparison (${widget.selectedPeriod.toUpperCase()})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 400,
                  child:
                      branchData.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.business,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text('No branch data available'),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: branchData.length,
                            itemBuilder: (context, index) {
                              final branch = branchData[index];
                              return _buildBranchCard(
                                branch,
                                index + 1,
                                totalRevenue,
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3e50),
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBranchCard(
    Map<String, dynamic> branch,
    int rank,
    double totalRevenue,
  ) {
    final revenuePercentage =
        totalRevenue > 0
            ? ((branch['total_revenue'] as double) / totalRevenue * 100)
            : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch['brch_name'] ?? 'Unknown Branch',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      branch['pharm_name'] ?? 'Unknown Pharmacy',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                'GH₵ ${(branch['total_revenue'] as double).toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Performance bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: (revenuePercentage / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),

          // Metrics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${branch['employee_count']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Employees',
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${branch['total_transactions']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Transactions',
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'GH₵ ${(branch['avg_transaction_value'] as double).toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Avg Transaction',
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'GH₵ ${((branch['total_revenue'] as double) / (branch['employee_count'] as int)).toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rev/Employee',
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Medicine Expiry Report with proper error handling
class MedicineExpiryReport extends StatefulWidget {
  @override
  _MedicineExpiryReportState createState() => _MedicineExpiryReportState();
}

class _MedicineExpiryReportState extends State<MedicineExpiryReport> {
  Map<String, dynamic> expiryData = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchExpiryData();
  }

  fetchExpiryData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try the reports endpoint first
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/reports/medicine-expiry'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            expiryData = data['data'];
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Expiry reports endpoint failed: $e');
    }

    // Fallback to basic products endpoint
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/products'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          expiryData = _processExpiryData(data is List ? data : []);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load expiry data: $e';
      });
    }
  }

  Map<String, dynamic> _processExpiryData(List<dynamic> products) {
    final now = DateTime.now();
    final expired = <Map<String, dynamic>>[];
    final critical = <Map<String, dynamic>>[];
    final warning = <Map<String, dynamic>>[];
    final monitor = <Map<String, dynamic>>[];
    double expiredValue = 0;
    double criticalValue = 0;
    double warningValue = 0;

    for (var product in products) {
      if (product['latest_expiry_date'] == null) continue;

      try {
        final expiryDate = DateTime.parse(product['latest_expiry_date']);
        final daysToExpiry = expiryDate.difference(now).inDays;
        final quantity =
            int.tryParse(product['quantity']?.toString() ?? '0') ?? 0;
        final unitPrice =
            double.tryParse(product['unit_price']?.toString() ?? '0') ?? 0;
        final totalValue = quantity * unitPrice;

        final productWithDays = Map<String, dynamic>.from(product);
        productWithDays['days_to_expiry'] = daysToExpiry;
        productWithDays['potential_loss'] = totalValue;

        if (daysToExpiry < 0) {
          expired.add(productWithDays);
          expiredValue += totalValue;
        } else if (daysToExpiry <= 7) {
          critical.add(productWithDays);
          criticalValue += totalValue;
        } else if (daysToExpiry <= 30) {
          warning.add(productWithDays);
          warningValue += totalValue;
        } else if (daysToExpiry <= 60) {
          monitor.add(productWithDays);
        }
      } catch (e) {
        // Skip invalid dates
      }
    }

    return {
      'summary': {
        'expiredCount': expired.length,
        'criticalCount': critical.length,
        'warningCount': warning.length,
        'monitorCount': monitor.length,
        'expiredValue': expiredValue,
        'criticalValue': criticalValue,
        'warningValue': warningValue,
        'totalAtRiskValue': expiredValue + criticalValue + warningValue,
      },
      'categories': {
        'expired': expired,
        'critical': critical,
        'warning': warning,
        'monitor': monitor,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF667eea)),
            SizedBox(height: 16),
            Text('Loading medicine expiry data...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(errorMessage!, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(onPressed: fetchExpiryData, child: Text('Retry')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Expired Items',
                  (expiryData['summary']['expiredCount'] ?? 0).toString(),
                  Icons.error,
                  Colors.red,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Critical (≤7 days)',
                  (expiryData['summary']['criticalCount'] ?? 0).toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Warning (≤30 days)',
                  (expiryData['summary']['warningCount'] ?? 0).toString(),
                  Icons.schedule,
                  Colors.amber,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Monitor (≤60 days)',
                  (expiryData['summary']['monitorCount'] ?? 0).toString(),
                  Icons.watch_later,
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          _buildCategorySection(
            'Expired Items',
            expiryData['categories']['expired'] ?? [],
            Colors.red,
          ),
          SizedBox(height: 24),
          _buildCategorySection(
            'Critical Items (≤7 days)',
            expiryData['categories']['critical'] ?? [],
            Colors.orange,
          ),
          SizedBox(height: 24),
          _buildCategorySection(
            'Warning Items (≤30 days)',
            expiryData['categories']['warning'] ?? [],
            Colors.amber,
          ),
          SizedBox(height: 24),
          _buildCategorySection(
            'Monitor Items (≤60 days)',
            expiryData['categories']['monitor'] ?? [],
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3e50),
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    List<dynamic> products,
    Color color,
  ) {
    if (products.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title (${products.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3e50),
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 300,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildExpiryProductTile(product, color);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryProductTile(
    Map<String, dynamic> product,
    Color statusColor,
  ) {
    final daysToExpiry = product['days_to_expiry'] as int;
    final quantity = product['quantity'] as int;
    final totalValue = product['potential_loss'] as double;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Unknown Product',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Supplier: ${product['supplier_name'] ?? 'Unknown'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                daysToExpiry < 0
                    ? '${daysToExpiry.abs()} days ago'
                    : '$daysToExpiry days left',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              Text(
                'Qty: $quantity',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                'Value: GH₵ ${totalValue.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Supplier Analysis Report
class SupplierAnalysisReport extends StatefulWidget {
  @override
  _SupplierAnalysisReportState createState() => _SupplierAnalysisReportState();
}

class _SupplierAnalysisReportState extends State<SupplierAnalysisReport> {
  Map<String, dynamic> supplierData = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSupplierData();
  }

  fetchSupplierData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try the reports endpoint first
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/reports/supplier-analysis'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            supplierData = data['data'];
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Supplier reports endpoint failed: $e');
    }

    // Fallback to manual processing
    try {
      final futures = await Future.wait([
        http
            .get(Uri.parse('http://localhost:3000/api/suppliers'))
            .timeout(Duration(seconds: 10)),
        http
            .get(Uri.parse('http://localhost:3000/api/products'))
            .timeout(Duration(seconds: 10)),
        http
            .get(Uri.parse('http://localhost:3000/api/supplier-products'))
            .timeout(Duration(seconds: 10)),
      ]);

      if (futures.every((response) => response.statusCode == 200)) {
        final suppliers = json.decode(futures[0].body);
        final products = json.decode(futures[1].body);
        final supplierProducts = json.decode(futures[2].body);

        setState(() {
          supplierData = _processSupplierData(
            suppliers is List ? suppliers : [],
            products is List ? products : [],
            supplierProducts is List ? supplierProducts : [],
          );
          isLoading = false;
        });
      } else {
        throw Exception('One or more API calls failed');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load supplier data: $e';
      });
    }
  }

  Map<String, dynamic> _processSupplierData(
    List<dynamic> suppliers,
    List<dynamic> products,
    List<dynamic> supplierProducts,
  ) {
    final processedSuppliers =
        suppliers.map((supp) {
          final suppId = supp['supplier_id'];

          // Get products for this supplier
          final suppProducts =
              products.where((p) => p['supplier_id'] == suppId).toList();
          final productsSupplied = suppProducts.length;
          final totalUnits = suppProducts.fold(
            0,
            (sum, p) => sum + ((p['quantity'] ?? 0) as int),
          );
          final avgPrice =
              productsSupplied > 0
                  ? suppProducts.fold(
                        0.0,
                        (sum, p) => sum + (p['unit_price'] ?? 0),
                      ) /
                      productsSupplied
                  : 0.0;
          final totalValue = suppProducts.fold(
            0.0,
            (sum, p) => sum + ((p['quantity'] ?? 0) * (p['unit_price'] ?? 0)),
          );
          final lowStock =
              suppProducts.where((p) => (p['quantity'] ?? 0) <= 10).length;
          final expiring =
              suppProducts.where((p) {
                if (p['latest_expiry_date'] == null) return false;
                try {
                  final expiryDate = DateTime.parse(p['latest_expiry_date']);
                  final days = expiryDate.difference(DateTime.now()).inDays;
                  return days <= 30;
                } catch (e) {
                  return false;
                }
              }).length;

          return {
            'supp_id': suppId,
            'supp_name': supp['name']?.toString() ?? 'Unknown',
            'supp_contact': supp['contact']?.toString() ?? 'Unknown',
            'supp_product_type': supp['product_type']?.toString() ?? 'Unknown',
            'products_supplied': productsSupplied,
            'total_units_supplied': totalUnits,
            'avg_product_price': avgPrice,
            'total_inventory_value': totalValue,
            'low_stock_products': lowStock,
            'expiring_products': expiring,
          };
        }).toList();

    final totalSuppliers = suppliers.length;
    final totalProductsSupplied = processedSuppliers.fold(
      0,
      (sum, s) => sum + (s['products_supplied'] as int),
    );
    final totalInventoryValue = processedSuppliers.fold(
      0.0,
      (sum, s) => sum + s['total_inventory_value'],
    );
    final avgProductsPerSupplier =
        totalSuppliers > 0 ? totalProductsSupplied / totalSuppliers : 0;

    return {
      'suppliers': processedSuppliers,
      'pricing': supplierProducts, // Assuming this is pricing trends
      'summary': {
        'totalSuppliers': totalSuppliers,
        'totalProductsSupplied': totalProductsSupplied,
        'totalInventoryValue': totalInventoryValue,
        'avgProductsPerSupplier': avgProductsPerSupplier,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF667eea)),
            SizedBox(height: 16),
            Text('Loading supplier analysis data...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(errorMessage!, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(onPressed: fetchSupplierData, child: Text('Retry')),
          ],
        ),
      );
    }

    final summary = supplierData['summary'] ?? {};
    final suppliers =
        supplierData['suppliers'] as List<Map<String, dynamic>>? ?? [];

    // Sort suppliers by total_inventory_value
    suppliers.sort(
      (a, b) => (b['total_inventory_value'] as double).compareTo(
        a['total_inventory_value'] as double,
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Metrics
          Row(
            children: [
              Expanded(
                child: _buildSupplierMetricCard(
                  'Total Suppliers',
                  (summary['totalSuppliers'] ?? 0).toString(),
                  Icons.local_shipping,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSupplierMetricCard(
                  'Total Products Supplied',
                  (summary['totalProductsSupplied'] ?? 0).toString(),
                  Icons.inventory,
                  Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSupplierMetricCard(
                  'Total Inventory Value',
                  'GH₵ ${(summary['totalInventoryValue'] ?? 0).toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSupplierMetricCard(
                  'Avg Products/Supplier',
                  (summary['avgProductsPerSupplier'] ?? 0).toStringAsFixed(1),
                  Icons.calculate,
                  Colors.purple,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Suppliers List
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Supplier Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 500,
                  child:
                      suppliers.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_shipping,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text('No supplier data available'),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: suppliers.length,
                            itemBuilder: (context, index) {
                              final supplier = suppliers[index];
                              final maxValue =
                                  suppliers.isNotEmpty
                                      ? suppliers[0]['total_inventory_value']
                                      : 1.0;
                              return _buildSupplierCard(supplier, maxValue);
                            },
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3e50),
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(Map<String, dynamic> supplier, double maxValue) {
    final percentage = ((supplier['total_inventory_value'] as double) /
            maxValue *
            100)
        .clamp(0, 100);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  supplier['supp_name'] ?? 'Unknown Supplier',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Text(
                'GH₵ ${(supplier['total_inventory_value'] as double).toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Type: ${supplier['supp_product_type'] ?? 'Unknown'}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSupplierMetric(
                'Products',
                supplier['products_supplied'].toString(),
              ),
              _buildSupplierMetric(
                'Units',
                supplier['total_units_supplied'].toString(),
              ),
              _buildSupplierMetric(
                'Avg Price',
                'GH₵ ${(supplier['avg_product_price'] as double).toStringAsFixed(2)}',
              ),
              _buildSupplierMetric(
                'Low Stock',
                supplier['low_stock_products'].toString(),
              ),
              _buildSupplierMetric(
                'Expiring',
                supplier['expiring_products'].toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierMetric(String title, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
      ],
    );
  }
}

// Customer Insights Report
class CustomerInsightsReport extends StatefulWidget {
  @override
  _CustomerInsightsReportState createState() => _CustomerInsightsReportState();
}

class _CustomerInsightsReportState extends State<CustomerInsightsReport> {
  Map<String, dynamic> customerData = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
  }

  fetchCustomerData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try the reports endpoint first
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/reports/customer-insights'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            customerData = data['data'];
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Customer reports endpoint failed: $e');
    }

    // Fallback to manual processing
    try {
      final futures = await Future.wait([
        http
            .get(Uri.parse('http://localhost:3000/api/customers'))
            .timeout(Duration(seconds: 10)),
        http
            .get(Uri.parse('http://localhost:3000/api/sales'))
            .timeout(Duration(seconds: 10)),
        http
            .get(Uri.parse('http://localhost:3000/api/products'))
            .timeout(Duration(seconds: 10)),
      ]);

      if (futures.every((response) => response.statusCode == 200)) {
        final customers = json.decode(futures[0].body);
        final sales = json.decode(futures[1].body);
        final products = json.decode(futures[2].body);

        setState(() {
          customerData = _processCustomerData(
            customers is List ? customers : [],
            sales is List ? sales : [],
            products is List ? products : [],
          );
          isLoading = false;
        });
      } else {
        throw Exception('One or more API calls failed');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load customer data: $e';
      });
    }
  }

  Map<String, dynamic> _processCustomerData(
    List<dynamic> customers,
    List<dynamic> sales,
    List<dynamic> products,
  ) {
    final processedCustomers =
        customers
            .map((cust) {
              final custId = cust['customer_id'];

              // Get sales for this customer
              final custSales =
                  sales
                      .where(
                        (s) =>
                            s['customer_id'] == custId &&
                            s['status'] == 'completed',
                      )
                      .toList();
              final totalPurchases = custSales.length;
              final totalSpent = custSales.fold(
                0.0,
                (sum, s) =>
                    sum +
                    (double.tryParse(s['total_cost']?.toString() ?? '0') ?? 0),
              );
              final avgPurchase =
                  totalPurchases > 0 ? totalSpent / totalPurchases : 0.0;
              final totalItems = custSales.fold(
                0,
                (sum, s) => sum + ((s['prod_quantity'] ?? 0) as int),
              );

              String? firstPurchase;
              String? lastPurchase;
              int customerLifespan = 0;

              if (custSales.isNotEmpty) {
                final dates =
                    custSales
                        .map((s) => DateTime.parse(s['created_at']))
                        .toList();
                dates.sort();
                firstPurchase = dates.first.toIso8601String().split('T')[0];
                lastPurchase = dates.last.toIso8601String().split('T')[0];
                customerLifespan = dates.last.difference(dates.first).inDays;
              }

              return {
                'cust_id': custId,
                'cust_name': cust['name']?.toString() ?? 'Unknown',
                'cust_contact': cust['contact']?.toString() ?? 'Unknown',
                'total_purchases': totalPurchases,
                'total_spent': totalSpent,
                'avg_purchase_value': avgPurchase,
                'total_items_bought': totalItems,
                'first_purchase_date': firstPurchase,
                'last_purchase_date': lastPurchase,
                'customer_lifespan_days': customerLifespan,
              };
            })
            .where((cust) => cust['total_purchases'] > 0)
            .toList();

    // Product preferences
    final productPreferences = [];
    for (var sale in sales) {
      if (sale['status'] == 'completed') {
        final custName =
            customers.firstWhere(
              (c) => c['customer_id'] == sale['customer_id'],
              orElse: () => {},
            )['name'] ??
            'Unknown';
        final prodName =
            products.firstWhere(
              (p) => p['product_id'] == sale['prod_id'],
              orElse: () => {},
            )['name'] ??
            'Unknown';
        productPreferences.add({
          'cust_id': sale['customer_id'],
          'cust_name': custName,
          'prod_name': prodName,
          'purchase_count': 1, // Since each sale is one purchase
          'total_quantity': sale['prod_quantity'] ?? 0,
        });
      }
    }

    final totalCustomers = processedCustomers.length;
    final highValueCustomers =
        processedCustomers.where((c) => c['total_spent'] > 1000).length;
    final regularCustomers =
        processedCustomers.where((c) => c['total_purchases'] >= 5).length;
    final recentCustomers =
        processedCustomers.where((c) {
          if (c['last_purchase_date'] == null) return false;
          final lastPurchase = DateTime.parse(c['last_purchase_date']);
          return DateTime.now().difference(lastPurchase).inDays <= 30;
        }).length;

    return {
      'customers': processedCustomers,
      'productPreferences': productPreferences,
      'summary': {
        'totalCustomers': totalCustomers,
        'highValueCustomers': highValueCustomers,
        'regularCustomers': regularCustomers,
        'recentCustomers': recentCustomers,
        'totalRevenue': processedCustomers.fold(
          0.0,
          (sum, c) => sum + c['total_spent'],
        ),
        'avgCustomerValue':
            totalCustomers > 0
                ? processedCustomers.fold(
                      0.0,
                      (sum, c) => sum + c['total_spent'],
                    ) /
                    totalCustomers
                : 0.0,
        'avgPurchaseFrequency':
            totalCustomers > 0
                ? processedCustomers.fold(
                      0.0,
                      (sum, c) => sum + (c['total_purchases'] as int),
                    ) /
                    totalCustomers
                : 0.0,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF667eea)),
            SizedBox(height: 16),
            Text('Loading customer insights data...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(errorMessage!, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(onPressed: fetchCustomerData, child: Text('Retry')),
          ],
        ),
      );
    }

    final summary = customerData['summary'] ?? {};
    final customers =
        customerData['customers'] as List<Map<String, dynamic>>? ?? [];

    // Sort customers by total spent
    customers.sort(
      (a, b) =>
          (b['total_spent'] as double).compareTo(a['total_spent'] as double),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Metrics
          Row(
            children: [
              Expanded(
                child: _buildCustomerMetricCard(
                  'Total Customers',
                  (summary['totalCustomers'] ?? 0).toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildCustomerMetricCard(
                  'High Value Customers',
                  (summary['highValueCustomers'] ?? 0).toString(),
                  Icons.star,
                  Colors.amber,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildCustomerMetricCard(
                  'Regular Customers',
                  (summary['regularCustomers'] ?? 0).toString(),
                  Icons.repeat,
                  Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildCustomerMetricCard(
                  'Recent Customers',
                  (summary['recentCustomers'] ?? 0).toString(),
                  Icons.timelapse,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Customers List
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Customers by Spend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 500,
                  child:
                      customers.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text('No customer data available'),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: customers.length,
                            itemBuilder: (context, index) {
                              final customer = customers[index];
                              return _buildCustomerCard(customer);
                            },
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3e50),
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  customer['cust_name'] ?? 'Unknown Customer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Text(
                'GH₵ ${(customer['total_spent'] as double).toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Contact: ${customer['cust_contact'] ?? 'Unknown'}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCustomerMetric(
                'Purchases',
                customer['total_purchases'].toString(),
              ),
              _buildCustomerMetric(
                'Avg Value',
                'GH₵ ${(customer['avg_purchase_value'] as double).toStringAsFixed(2)}',
              ),
              _buildCustomerMetric(
                'Items Bought',
                customer['total_items_bought'].toString(),
              ),
              _buildCustomerMetric(
                'Lifespan',
                '${customer['customer_lifespan_days']} days',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerMetric(String title, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
      ],
    );
  }
}

// Financial Summary Report
class FinancialSummaryReport extends StatefulWidget {
  final String selectedPeriod;

  const FinancialSummaryReport({Key? key, required this.selectedPeriod})
    : super(key: key);

  @override
  _FinancialSummaryReportState createState() => _FinancialSummaryReportState();
}

class _FinancialSummaryReportState extends State<FinancialSummaryReport> {
  Map<String, dynamic> financialData = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchFinancialData();
  }

  @override
  void didUpdateWidget(FinancialSummaryReport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPeriod != widget.selectedPeriod) {
      fetchFinancialData();
    }
  }

  fetchFinancialData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try the reports endpoint first
      final response = await http
          .get(
            Uri.parse(
              'http://localhost:3000/api/reports/financial-summary?period=${widget.selectedPeriod}',
            ),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            financialData = data['data'];
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Financial reports endpoint failed: $e');
    }

    // Fallback to manual processing
    try {
      final futures = await Future.wait([
        http
            .get(Uri.parse('http://localhost:3000/api/sales'))
            .timeout(Duration(seconds: 10)),
        http
            .get(Uri.parse('http://localhost:3000/api/products'))
            .timeout(Duration(seconds: 10)),
      ]);

      if (futures.every((response) => response.statusCode == 200)) {
        final sales = json.decode(futures[0].body);
        final products = json.decode(futures[1].body);

        setState(() {
          financialData = _processFinancialData(
            sales is List ? sales : [],
            products is List ? products : [],
          );
          isLoading = false;
        });
      } else {
        throw Exception('One or more API calls failed');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load financial data: $e';
      });
    }
  }

  Map<String, dynamic> _processFinancialData(
    List<dynamic> sales,
    List<dynamic> products,
  ) {
    final revenueTrends = <String, double>{};
    final paymentBreakdown = <String, double>{};
    double totalRevenue = 0;
    int totalTransactions = 0;
    int totalUnitsSold = 0;
    double avgTransactionValue = 0;

    for (var sale in sales) {
      if (sale['status'] == 'completed') {
        final cost =
            double.tryParse(sale['total_cost']?.toString() ?? '0') ?? 0;
        totalRevenue += cost;
        totalTransactions += 1;
        totalUnitsSold += ((sale['prod_quantity'] ?? 0) as num).toInt();

        // Payment breakdown
        final method = sale['payment_method'] ?? 'Cash';
        paymentBreakdown[method] = (paymentBreakdown[method] ?? 0) + cost;

        // Revenue trends (group by date)
        final date =
            sale['created_at'].split(' ')[0]; // Assume created_at is string
        revenueTrends[date] = (revenueTrends[date] ?? 0) + cost;
      }
    }

    avgTransactionValue =
        totalTransactions > 0 ? totalRevenue / totalTransactions : 0.0;

    // Inventory cost
    double totalInventoryValue = 0;
    int totalProducts = 0;
    double avgProductPrice = 0;
    for (var product in products) {
      if ((product['quantity'] ?? 0) > 0) {
        totalProducts += 1;
        final price =
            double.tryParse(product['unit_price']?.toString() ?? '0') ?? 0;
        totalInventoryValue += price * (product['quantity'] ?? 0);
        avgProductPrice += price;
      }
    }
    avgProductPrice = totalProducts > 0 ? avgProductPrice / totalProducts : 0.0;

    return {
      'revenueTrends':
          revenueTrends.entries
              .map((e) => {'period': e.key, 'total_revenue': e.value})
              .toList(),
      'currentSummary': {
        'total_transactions': totalTransactions,
        'total_revenue': totalRevenue,
        'avg_transaction_value': avgTransactionValue,
        'total_units_sold': totalUnitsSold,
      },
      'paymentBreakdown':
          paymentBreakdown.entries
              .map((e) => {'payment_method': e.key, 'total_amount': e.value})
              .toList(),
      'inventoryCost': {
        'total_inventory_value': totalInventoryValue,
        'total_products': totalProducts,
        'avg_product_price': avgProductPrice,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF667eea)),
            SizedBox(height: 16),
            Text('Loading financial summary data...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(errorMessage!, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(onPressed: fetchFinancialData, child: Text('Retry')),
          ],
        ),
      );
    }

    final currentSummary = financialData['currentSummary'] ?? {};
    final revenueTrends =
        financialData['revenueTrends'] as List<Map<String, dynamic>>? ?? [];
    final paymentBreakdown =
        financialData['paymentBreakdown'] as List<Map<String, dynamic>>? ?? [];
    final inventoryCost = financialData['inventoryCost'] ?? {};

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Summary Metrics
          Row(
            children: [
              Expanded(
                child: _buildFinancialMetricCard(
                  'Total Revenue',
                  'GH₵ ${(currentSummary['total_revenue'] ?? 0).toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildFinancialMetricCard(
                  'Transactions',
                  (currentSummary['total_transactions'] ?? 0).toString(),
                  Icons.receipt,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildFinancialMetricCard(
                  'Avg Transaction',
                  'GH₵ ${(currentSummary['avg_transaction_value'] ?? 0).toStringAsFixed(2)}',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildFinancialMetricCard(
                  'Units Sold',
                  (currentSummary['total_units_sold'] ?? 0).toString(),
                  Icons.shopping_cart,
                  Colors.purple,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Inventory Cost
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventory Cost Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialMetricCard(
                        'Total Inventory Value',
                        'GH₵ ${(inventoryCost['total_inventory_value'] ?? 0).toStringAsFixed(2)}',
                        Icons.inventory,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildFinancialMetricCard(
                        'Total Products',
                        (inventoryCost['total_products'] ?? 0).toString(),
                        Icons.list,
                        Colors.green,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildFinancialMetricCard(
                        'Avg Product Price',
                        'GH₵ ${(inventoryCost['avg_product_price'] ?? 0).toStringAsFixed(2)}',
                        Icons.price_check,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Revenue Trends
          _buildChartCard(
            'Revenue Trends',
            Container(
              height: 300,
              child:
                  revenueTrends.isEmpty
                      ? Center(child: Text('No trend data available'))
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: revenueTrends.length,
                        itemBuilder: (context, index) {
                          final trend = revenueTrends[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      (trend['total_revenue'] as double)
                                          .toStringAsFixed(2),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  trend['period'],
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ),
          SizedBox(height: 24),

          // Payment Breakdown
          _buildChartCard(
            'Payment Method Breakdown',
            Container(
              height: 200,
              child:
                  paymentBreakdown.isEmpty
                      ? Center(child: Text('No payment data available'))
                      : Row(
                        children:
                            paymentBreakdown.map((payment) {
                              final total = paymentBreakdown.fold(
                                0.0,
                                (sum, p) => sum + (p['total_amount'] as double),
                              );
                              final percentage =
                                  total > 0
                                      ? ((payment['total_amount'] as double) /
                                          total *
                                          100)
                                      : 0.0;
                              final colors = [
                                Colors.blue,
                                Colors.green,
                                Colors.orange,
                                Colors.purple,
                              ];
                              final colorIndex =
                                  paymentBreakdown.indexOf(payment) %
                                  colors.length;

                              return Expanded(
                                flex:
                                    (payment['total_amount'] as double).round(),
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: colors[colorIndex],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        payment['payment_method'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3e50),
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3e50),
            ),
          ),
          SizedBox(height: 20),
          chart,
        ],
      ),
    );
  }
}

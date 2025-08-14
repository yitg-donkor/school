// main.dart - Modern Flutter Pharmacy Admin Dashboard
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmcy/screens/attendance_page.dart';
import 'dart:convert';

import 'package:pharmcy/screens/branches_page.dart';
import 'package:pharmcy/screens/customers_page.dart';
import 'package:pharmcy/screens/employees_page.dart';
import 'package:pharmcy/screens/pharmacies_page.dart';
import 'package:pharmcy/screens/products_page.dart';
import 'package:pharmcy/screens/receipts_page.dart';
import 'package:pharmcy/screens/sales_page.dart';
import 'package:pharmcy/screens/suppliers_page.dart';
import 'package:pharmcy/screens/suppliers_product_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharma One - Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Segoe UI',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final String baseUrl = 'http://localhost:3000/api';

  final List<Widget> _pages = [
    ModernDashboardOverview(),
    PharmaciesPage(),
    BranchesPage(),
    EmployeesPage(),
    ProductsPage(),
    SuppliersPage(),
    CustomersPage(),
    SalesPage(),
    ReceiptsPage(),
    AttendancePage(),
    SupplierProductPage(),
  ];

  final List<NavigationItem> _navItems = [
    NavigationItem(Icons.dashboard, 'Dashboard', Colors.blue),
    NavigationItem(Icons.business, 'Pharmacies', Colors.purple),
    NavigationItem(Icons.location_on, 'Branches', Colors.green),
    NavigationItem(Icons.people, 'Employees', Colors.orange),
    NavigationItem(Icons.inventory, 'Products', Colors.indigo),
    NavigationItem(Icons.local_shipping, 'Suppliers', Colors.teal),
    NavigationItem(Icons.person, 'Customers', Colors.pink),
    NavigationItem(Icons.shopping_cart, 'Sales', Colors.red),
    NavigationItem(Icons.receipt_long, 'Receipts', Colors.amber),
    NavigationItem(Icons.access_time, 'Attendance', Colors.cyan),
    NavigationItem(Icons.link, 'Supplier Products', Colors.brown),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Row(
          children: [
            _buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _pages[_selectedIndex],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.2, // 20% of screen width instead of fixed 280
      decoration: BoxDecoration(
        color: Color(0xFF2c3e50).withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                return _buildNavItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_pharmacy,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Pharma One',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Text(
                    'SA',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Group Nine',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Super Admin',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? item.color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border:
            isSelected ? Border.all(color: item.color.withOpacity(0.3)) : null,
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? item.color : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(item.icon, color: Colors.white, size: 20),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for anything here...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          _buildQuickAction(Icons.language, 'English (US)'),
          SizedBox(width: 8),
          _buildQuickAction(Icons.wb_sunny, 'Good Morning'),
          SizedBox(width: 8),
          Text(
            '14 January 2022   22:45:04',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String title;
  final Color color;

  NavigationItem(this.icon, this.title, this.color);
}

// Modern Dashboard Overview
class ModernDashboardOverview extends StatefulWidget {
  @override
  _ModernDashboardOverviewState createState() =>
      _ModernDashboardOverviewState();
}

class _ModernDashboardOverviewState extends State<ModernDashboardOverview> {
  Map<String, dynamic> stats = {};
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  fetchStats() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      print('Fetching dashboard stats...');
      final response = await http
          .get(
            Uri.parse('http://localhost:3000/api/dashboard/stats'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed data: $data');

        if (data['success'] == true && data['data'] != null) {
          setState(() {
            stats = Map<String, dynamic>.from(data['data']);
            isLoading = false;
            error = '';
          });
          print('Stats loaded successfully: $stats');
        } else {
          throw Exception(data['error'] ?? 'Invalid response format');
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stats: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
        // Provide fallback data
        stats = {
          'inventoryStatus': 'Unknown',
          'revenue': 0,
          'medicinesAvailable': 0,
          'medicineShortage': 0,
          'totalMedicines': 0,
          'medicineGroups': 0,
          'qtyMedicinesSold': 0,
          'invoicesGenerated': 0,
          'totalSuppliers': 0,
          'totalUsers': 0,
          'totalCustomers': 0,
          'frequentItem': 'No data available',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
            SizedBox(height: 16),
            Text('Loading dashboard statistics...'),
          ],
        ),
      );
    }

    if (error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            SizedBox(height: 16),
            Text(
              'Failed to load dashboard stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchStats,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
              Text(
                'A quick data overview of the inventory.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.download, size: 18),
                label: Text('Download Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Stats Row
              Container(
                height: 200,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 1200) {
                      // Desktop view - show all cards in a row
                      return Row(children: _buildStatCards());
                    } else {
                      // Mobile/Tablet view - show cards in PageView
                      return Column(
                        children: [
                          Expanded(
                            child: PageView(
                              controller: PageController(viewportFraction: 0.9),
                              children: _buildStatCards(),
                            ),
                          ),
                          SizedBox(height: 8),
                          // Page indicator dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (index) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 24),
              // Bottom Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard('Inventory', [
                      InfoItem(
                        'Total no of Medicines',
                        stats['totalMedicines'].toString(),
                      ),
                      InfoItem(
                        'Medicine Groups',
                        stats['medicineGroups'].toString(),
                      ),
                    ], 'Go to Configuration'),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard('Quick Report', [
                      InfoItem(
                        'Qty of Medicines Sold',
                        stats['qtyMedicinesSold'].toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                      ),
                      InfoItem(
                        'Invoices Generated',
                        stats['invoicesGenerated'].toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                      ),
                    ], 'January 2022'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard('My Pharmacy', [
                      InfoItem(
                        'Total no of Suppliers',
                        stats['totalSuppliers'].toString().padLeft(2, '0'),
                      ),
                      InfoItem(
                        'Total no of Users',
                        stats['totalUsers'].toString().padLeft(2, '0'),
                      ),
                    ], 'Go to User Management'),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard('Customers', [
                      InfoItem(
                        'Total no of Customers',
                        stats['totalCustomers'].toString(),
                      ),
                      InfoItem('Frequently bought Item', stats['frequentItem']),
                    ], 'Go to Customers Page'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStatCards() {
    return [
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: _buildMainStatCard(
            'Inventory Status',
            stats['inventoryStatus'],
            Colors.green,
            Icons.shield,
            'View Detailed Report',
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: _buildMainStatCard(
            'Revenue',
            'GH₵. ${stats['revenue']?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            Colors.orange,
            Icons.account_balance_wallet,
            'View Detailed Report',
            subtitle: 'Jan 2022',
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: _buildMainStatCard(
            'Medicines Available',
            stats['medicinesAvailable'].toString(),
            Colors.blue,
            Icons.medical_services,
            'Visit Inventory',
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: _buildMainStatCard(
            'Medicine Shortage',
            stats['medicineShortage'].toString(),
            Colors.red,
            Icons.warning,
            'Resolve Now',
          ),
        ),
      ),
    ];
  }

  Widget _buildMainStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
    String actionText, {
    String? subtitle,
  }) {
    return SingleChildScrollView(
      child: Container(
        height: 200,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey[500],
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  actionText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<InfoItem> items, String actionText) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
              Text(
                actionText,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...items
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

class InfoItem {
  final String label;
  final String value;

  InfoItem(this.label, this.value);
}

// Enhanced Generic List Page
class EnhancedGenericListPage extends StatefulWidget {
  final String title;
  final String endpoint;
  final List<String> columns;
  final Function(Map<String, dynamic>) onAdd;
  final Function(Map<String, dynamic>) onEdit;
  final Color themeColor;
  final IconData icon;

  EnhancedGenericListPage({
    required this.title,
    required this.endpoint,
    required this.columns,
    required this.onAdd,
    required this.onEdit,
    this.themeColor = Colors.blue,
    this.icon = Icons.list,
  });

  @override
  _EnhancedGenericListPageState createState() =>
      _EnhancedGenericListPageState();
}

class _EnhancedGenericListPageState extends State<EnhancedGenericListPage> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  fetchItems() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/${widget.endpoint}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          setState(() {
            items = List<Map<String, dynamic>>.from(
              data is List ? data : [data],
            );
            isLoading = false;
          });
        } else {
          throw Exception('No data received from server');
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching items: $e')));
    }
  }

  deleteItem(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/${widget.endpoint}/$id'),
      );
      if (response.statusCode == 200) {
        fetchItems();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
    }
  }

  List<Map<String, dynamic>> get filteredItems {
    if (searchQuery.isEmpty) return items;
    return items.where((item) {
      return item.values.any(
        (value) =>
            value.toString().toLowerCase().contains(searchQuery.toLowerCase()),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.02; // 2% padding
    final gridColumns = size.width < 1200 ? 2 : 3; // Responsive grid columns

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(170),
        child: AppBar(
          automaticallyImplyLeading: false,

          elevation: 0,
          flexibleSpace: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.themeColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2c3e50),
                            ),
                          ),
                          Text(
                            'Manage ${widget.title.toLowerCase()} in your pharmacy system.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => widget.onAdd({}),
                      icon: Icon(Icons.add),
                      label: Text(
                        'Add New ${widget.title.substring(0, widget.title.length - 1)}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search ${widget.title.toLowerCase()}...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.themeColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Loading ${widget.title.toLowerCase()}...'),
                  ],
                ),
              )
              : Padding(
                padding: EdgeInsets.all(24),
                child:
                    filteredItems.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.icon,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                searchQuery.isEmpty
                                    ? 'No ${widget.title.toLowerCase()} found'
                                    : 'No results found for "$searchQuery"',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                searchQuery.isEmpty
                                    ? 'Add your first ${widget.title.toLowerCase().substring(0, widget.title.length - 1)} to get started'
                                    : 'Try adjusting your search terms',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                        : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridColumns,
                                crossAxisSpacing: padding,
                                mainAxisSpacing: padding,
                                childAspectRatio: size.width < 1200 ? 1.5 : 1.2,
                              ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return _buildItemCard(item);
                          },
                        ),
              ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 1200;

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => widget.onEdit(item),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.themeColor,
                        size: 20,
                      ),
                    ),
                    Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          widget.onEdit(item);
                        } else if (value == 'delete') {
                          _showDeleteDialog(item);
                        }
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  item[widget.columns[1]]?.toString() ?? '',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  item[widget.columns.length > 2
                              ? widget.columns[2]
                              : widget.columns[1]]
                          ?.toString() ??
                      '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Spacer(),
                Container(
                  width: double.infinity,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'ID: ${item[widget.columns[0]]}',
                      style: TextStyle(
                        color: widget.themeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete this item? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  deleteItem(item[widget.columns[0]]);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }
}

// Specific Pages with enhanced UI

// New Pages for Missing Tables

// Add responsive dialogs
void _showResponsiveDialog(BuildContext context, Widget content) {
  final size = MediaQuery.of(context).size;
  final width = size.width;
  final dialogWidth = width < 600 ? width * 0.9 : 400.0;

  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(maxHeight: size.height * 0.8),
            child: content,
          ),
        ),
  );
}

// main.dart - Modern Flutter Pharmacy Admin Dashboard
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
                      'Subash',
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

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  fetchStats() async {
    try {
      final baseUrl = 'http://localhost:3000/api';

      // Simulate fetching data
      await Future.delayed(Duration(seconds: 1));

      setState(() {
        stats = {
          'inventoryStatus': 'Good',
          'revenue': 855875,
          'medicinesAvailable': 298,
          'medicineShortage': 1,
          'totalMedicines': 298,
          'medicineGroups': 24,
          'qtyMedicinesSold': 70856,
          'invoicesGenerated': 5288,
          'totalSuppliers': 4,
          'totalUsers': 5,
          'totalCustomers': 845,
          'frequentItem': 'Adalimumab',
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
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
        child: Column(
          children: [
            // Top Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildMainStatCard(
                    'Inventory Status',
                    stats['inventoryStatus'],
                    Colors.green,
                    Icons.shield,
                    'View Detailed Report',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildMainStatCard(
                    'Revenue',
                    'Rs. ${stats['revenue']?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    Colors.orange,
                    Icons.account_balance_wallet,
                    'View Detailed Report',
                    subtitle: 'Jan 2022',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildMainStatCard(
                    'Medicines Available',
                    stats['medicinesAvailable'].toString(),
                    Colors.blue,
                    Icons.medical_services,
                    'Visit Inventory',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildMainStatCard(
                    'Medicine Shortage',
                    stats['medicineShortage'].toString(),
                    Colors.red,
                    Icons.warning,
                    'Resolve Now',
                  ),
                ),
              ],
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
    );
  }

  Widget _buildMainStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
    String actionText, {
    String? subtitle,
  }) {
    return Container(
      height: 160,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
              Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[500]),
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
        preferredSize: Size.fromHeight(120),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
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
                    Column(
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

class EmployeesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedGenericListPage(
      title: 'Employees',
      endpoint: 'employees',
      columns: ['employee_id', 'name', 'position', 'email'],
      themeColor: Colors.orange,
      icon: Icons.people,
      onAdd: (item) => _showEmployeeDialog(context, item),
      onEdit: (item) => _showEmployeeDialog(context, item),
    );
  }

  _showEmployeeDialog(BuildContext context, Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name'] ?? '');
    final positionController = TextEditingController(
      text: item['position'] ?? '',
    );
    final emailController = TextEditingController(text: item['email'] ?? '');
    final contactController = TextEditingController(
      text: item['contact'] ?? '',
    );
    final addressController = TextEditingController(
      text: item['address'] ?? '',
    );
    final branchIdController = TextEditingController(
      text: item['branch_id']?.toString() ?? '',
    );
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.people, color: Colors.orange),
                SizedBox(width: 8),
                Text(item.isEmpty ? 'Add Employee' : 'Edit Employee'),
              ],
            ),
            content: Container(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      branchIdController,
                      'Branch ID',
                      Icons.location_on,
                      isNumber: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      nameController,
                      'Employee Name',
                      Icons.person,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(positionController, 'Position', Icons.work),
                    SizedBox(height: 16),
                    _buildTextField(emailController, 'Email', Icons.email),
                    SizedBox(height: 16),
                    _buildTextField(contactController, 'Contact', Icons.phone),
                    SizedBox(height: 16),
                    _buildTextField(addressController, 'Address', Icons.home),
                    if (item.isEmpty) ...[
                      SizedBox(height: 16),
                      _buildTextField(
                        passwordController,
                        'Password',
                        Icons.lock,
                        isPassword: true,
                      ),
                    ],
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
                  final data = {
                    'branch_id': int.tryParse(branchIdController.text),
                    'name': nameController.text,
                    'position': positionController.text,
                    'email': emailController.text,
                    'contact': contactController.text,
                    'address': addressController.text,
                  };

                  if (item.isEmpty) {
                    data['password'] = passwordController.text;
                  }

                  await _saveEmployee(context, item, data);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  _saveEmployee(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, dynamic> data,
  ) async {
    try {
      final url =
          item.isEmpty
              ? 'http://localhost:3000/api/employees'
              : 'http://localhost:3000/api/employees/${item['employee_id']}';

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
            content: Text('Employee saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving employee: $e')));
    }
  }
}

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

    _showResponsiveDialog(
      context,
      SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory, color: Colors.indigo, size: 28),
                  SizedBox(width: 8),
                  Text(
                    item.isEmpty ? 'Add Product' : 'Edit Product',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildTextField(
                supplierIdController,
                'Supplier ID',
                Icons.local_shipping,
                isNumber: true,
              ),
              SizedBox(height: 16),
              _buildTextField(nameController, 'Product Name', Icons.inventory),
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
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving product: $e')));
    }
  }
}

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

class CustomersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedGenericListPage(
      title: 'Customers',
      endpoint: 'customers',
      columns: ['customer_id', 'name', 'contact'],
      themeColor: Colors.pink,
      icon: Icons.person,
      onAdd: (item) => _showCustomerDialog(context, item),
      onEdit: (item) => _showCustomerDialog(context, item),
    );
  }

  _showCustomerDialog(BuildContext context, Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name'] ?? '');
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
                Icon(Icons.person, color: Colors.pink),
                SizedBox(width: 8),
                Text(item.isEmpty ? 'Add Customer' : 'Edit Customer'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Customer Name', Icons.person),
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
                  await _saveCustomer(context, item, {
                    'name': nameController.text,
                    'contact': contactController.text,
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
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

  _saveCustomer(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, dynamic> data,
  ) async {
    try {
      final url =
          item.isEmpty
              ? 'http://localhost:3000/api/customers'
              : 'http://localhost:3000/api/customers/${item['customer_id']}';

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
            content: Text('Customer saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving customer: $e')));
    }
  }
}

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
    final employeeIdController = TextEditingController(
      text: item['employee_id']?.toString() ?? '',
    );
    final customerIdController = TextEditingController(
      text: item['customer_id']?.toString() ?? '',
    );
    final productIdController = TextEditingController(
      text: item['product_id']?.toString() ?? '',
    );
    final quantityController = TextEditingController(
      text: item['quantity']?.toString() ?? '',
    );
    final totalCostController = TextEditingController(
      text: item['total_cost']?.toString() ?? '',
    );
    final paymentMethodController = TextEditingController(
      text: item['payment_method'] ?? '',
    );
    final receiptNumController = TextEditingController(
      text: item['receipt_num'] ?? '',
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
                Icon(Icons.shopping_cart, color: Colors.red),
                SizedBox(width: 8),
                Text(item.isEmpty ? 'Add Sale' : 'Edit Sale'),
              ],
            ),
            content: Container(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      employeeIdController,
                      'Employee ID',
                      Icons.person,
                      isNumber: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      customerIdController,
                      'Customer ID',
                      Icons.person_outline,
                      isNumber: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      productIdController,
                      'Product ID',
                      Icons.inventory,
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
                      totalCostController,
                      'Total Cost',
                      Icons.attach_money,
                      isNumber: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      paymentMethodController,
                      'Payment Method',
                      Icons.payment,
                    ),
                    SizedBox(height: 16),
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
                onPressed: () async {
                  await _saveSale(context, item, {
                    'employee_id': int.tryParse(employeeIdController.text),
                    'customer_id': int.tryParse(customerIdController.text),
                    'product_id': int.tryParse(productIdController.text),
                    'quantity': int.tryParse(quantityController.text),
                    'total_cost': double.tryParse(totalCostController.text),
                    'status': 'completed',
                    'payment_method': paymentMethodController.text,
                    'receipt_num': receiptNumController.text,
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

  _saveSale(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/sales'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sale saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving sale: $e')));
    }
  }
}

// New Pages for Missing Tables

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

class AttendancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedGenericListPage(
      title: 'Attendance',
      endpoint: 'attendance',
      columns: ['attnd_id', 'emp_id', 'check_in_time', 'check_out_time'],
      themeColor: Colors.cyan,
      icon: Icons.access_time,
      onAdd: (item) => _showAttendanceDialog(context, item),
      onEdit: (item) => _showAttendanceDialog(context, item),
    );
  }

  _showAttendanceDialog(BuildContext context, Map<String, dynamic> item) {
    final empIdController = TextEditingController(
      text: item['emp_id']?.toString() ?? '',
    );
    final checkInController = TextEditingController(
      text: item['check_in_time'] ?? '',
    );
    final checkOutController = TextEditingController(
      text: item['check_out_time'] ?? '',
    );
    final dateController = TextEditingController(text: item['date'] ?? '');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.access_time, color: Colors.cyan),
                SizedBox(width: 8),
                Text(item.isEmpty ? 'Add Attendance' : 'Edit Attendance'),
              ],
            ),
            content: Container(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      empIdController,
                      'Employee ID',
                      Icons.person,
                      isNumber: true,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      dateController,
                      'Date (YYYY-MM-DD)',
                      Icons.calendar_today,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      checkInController,
                      'Check In Time (HH:MM:SS)',
                      Icons.login,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      checkOutController,
                      'Check Out Time (HH:MM:SS)',
                      Icons.logout,
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
                  await _saveAttendance(context, item, {
                    'emp_id': int.tryParse(empIdController.text),
                    'date': dateController.text,
                    'check_in_time': checkInController.text,
                    'check_out_time': checkOutController.text,
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
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

  _saveAttendance(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, dynamic> data,
  ) async {
    try {
      final url =
          item.isEmpty
              ? 'http://localhost:3000/api/attendance'
              : 'http://localhost:3000/api/attendance/${item['attnd_id']}';

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
            content: Text('Attendance saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving attendance: $e')));
    }
  }
}

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

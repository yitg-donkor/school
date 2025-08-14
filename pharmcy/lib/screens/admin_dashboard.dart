// Updated Flutter Dashboard - Fixed overflow issues and real database stats
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Modern Dashboard Overview - Updated with real API calls
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

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/dashboard/stats'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            stats = data['data'];
            isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Failed to load stats');
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
          'frequentItem': 'No data',
        };
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load dashboard stats: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: fetchStats,
                      icon: Icon(Icons.refresh),
                      tooltip: 'Refresh Data',
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Stats Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 1200;
                final cardCount = 4;
                final spacing = 16.0;
                final availableWidth =
                    constraints.maxWidth - (spacing * (cardCount - 1));
                final cardWidth = availableWidth / cardCount;

                if (isWideScreen) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildMainStatCard(
                          'Inventory Status',
                          stats['inventoryStatus']?.toString() ?? 'Unknown',
                          _getStatusColor(
                            stats['inventoryStatus']?.toString() ?? 'Unknown',
                          ),
                          Icons.shield,
                          'View Detailed Report',
                        ),
                      ),
                      SizedBox(width: spacing),
                      Expanded(
                        child: _buildMainStatCard(
                          'Revenue',
                          'Rs. ${_formatNumber(stats['revenue'])}',
                          Colors.orange,
                          Icons.account_balance_wallet,
                          'View Detailed Report',
                          subtitle: 'Total Revenue',
                        ),
                      ),
                      SizedBox(width: spacing),
                      Expanded(
                        child: _buildMainStatCard(
                          'Medicines Available',
                          stats['medicinesAvailable']?.toString() ?? '0',
                          Colors.blue,
                          Icons.medical_services,
                          'Visit Inventory',
                        ),
                      ),
                      SizedBox(width: spacing),
                      Expanded(
                        child: _buildMainStatCard(
                          'Medicine Shortage',
                          stats['medicineShortage']?.toString() ?? '0',
                          Colors.red,
                          Icons.warning,
                          'Resolve Now',
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMainStatCard(
                              'Inventory Status',
                              stats['inventoryStatus']?.toString() ?? 'Unknown',
                              _getStatusColor(
                                stats['inventoryStatus']?.toString() ??
                                    'Unknown',
                              ),
                              Icons.shield,
                              'View Report',
                            ),
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: _buildMainStatCard(
                              'Revenue',
                              'Rs. ${_formatNumber(stats['revenue'])}',
                              Colors.orange,
                              Icons.account_balance_wallet,
                              'View Report',
                              subtitle: 'Total',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMainStatCard(
                              'Medicines Available',
                              stats['medicinesAvailable']?.toString() ?? '0',
                              Colors.blue,
                              Icons.medical_services,
                              'Visit Inventory',
                            ),
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: _buildMainStatCard(
                              'Medicine Shortage',
                              stats['medicineShortage']?.toString() ?? '0',
                              Colors.red,
                              Icons.warning,
                              'Resolve Now',
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 24),
            // Bottom Stats Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 800;

                if (isWideScreen) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard('Inventory', [
                          InfoItem(
                            'Total Medicines',
                            stats['totalMedicines']?.toString() ?? '0',
                          ),
                          InfoItem(
                            'Medicine Groups',
                            stats['medicineGroups']?.toString() ?? '0',
                          ),
                        ], 'Go to Configuration'),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard('Quick Report', [
                          InfoItem(
                            'Qty Sold',
                            _formatNumber(stats['qtyMedicinesSold']),
                          ),
                          InfoItem(
                            'Invoices Generated',
                            _formatNumber(stats['invoicesGenerated']),
                          ),
                        ], 'View All Reports'),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildInfoCard('Inventory', [
                        InfoItem(
                          'Total Medicines',
                          stats['totalMedicines']?.toString() ?? '0',
                        ),
                        InfoItem(
                          'Medicine Groups',
                          stats['medicineGroups']?.toString() ?? '0',
                        ),
                      ], 'Go to Configuration'),
                      SizedBox(height: 16),
                      _buildInfoCard('Quick Report', [
                        InfoItem(
                          'Qty Sold',
                          _formatNumber(stats['qtyMedicinesSold']),
                        ),
                        InfoItem(
                          'Invoices Generated',
                          _formatNumber(stats['invoicesGenerated']),
                        ),
                      ], 'View All Reports'),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 800;

                if (isWideScreen) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard('My Pharmacy', [
                          InfoItem(
                            'Total Suppliers',
                            stats['totalSuppliers']?.toString().padLeft(
                                  2,
                                  '0',
                                ) ??
                                '00',
                          ),
                          InfoItem(
                            'Total Users',
                            stats['totalUsers']?.toString().padLeft(2, '0') ??
                                '00',
                          ),
                        ], 'User Management'),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard('Customers', [
                          InfoItem(
                            'Total Customers',
                            stats['totalCustomers']?.toString() ?? '0',
                          ),
                          InfoItem(
                            'Frequent Item',
                            stats['frequentItem']?.toString() ?? 'No data',
                          ),
                        ], 'Go to Customers'),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildInfoCard('My Pharmacy', [
                        InfoItem(
                          'Total Suppliers',
                          stats['totalSuppliers']?.toString().padLeft(2, '0') ??
                              '00',
                        ),
                        InfoItem(
                          'Total Users',
                          stats['totalUsers']?.toString().padLeft(2, '0') ??
                              '00',
                        ),
                      ], 'User Management'),
                      SizedBox(height: 16),
                      _buildInfoCard('Customers', [
                        InfoItem(
                          'Total Customers',
                          stats['totalCustomers']?.toString() ?? '0',
                        ),
                        InfoItem(
                          'Frequent Item',
                          stats['frequentItem']?.toString() ?? 'No data',
                        ),
                      ], 'Go to Customers'),
                    ],
                  );
                }
              },
            ),
            if (error.isNotEmpty) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Using cached data due to connection error',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    TextButton(onPressed: fetchStats, child: Text('Retry')),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final num = int.tryParse(number.toString()) ?? 0;
    return num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxWidth < 200 ? 140.0 : 160.0;
        final fontSize = constraints.maxWidth < 200 ? 20.0 : 24.0;
        final iconSize = constraints.maxWidth < 200 ? 24.0 : 32.0;

        return Container(
          height: cardHeight,
          padding: EdgeInsets.all(constraints.maxWidth < 200 ? 12 : 20),
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
              Icon(icon, size: iconSize, color: color),
              SizedBox(height: 8),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subtitle != null) ...[
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: constraints.maxWidth < 200 ? 12 : 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    actionText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: constraints.maxWidth < 200 ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, List<InfoItem> items, String actionText) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                actionText,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.value,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2c3e50),
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

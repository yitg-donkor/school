import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PharmacyAdminDashboard extends StatefulWidget {
  @override
  _PharmacyAdminDashboardState createState() => _PharmacyAdminDashboardState();
}

class _PharmacyAdminDashboardState extends State<PharmacyAdminDashboard> {
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;
  bool _isLoading = false;
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      switch (_selectedIndex) {
        case 0: // Products
          _data = await _apiService.getProducts();
          break;
        case 1: // Employees
          _data = await _apiService.getEmployees();
          break;
        case 2: // Sales
          _data = await _apiService.getSales();
          break;
        case 3: // Suppliers
          _data = await _apiService.getSuppliers();
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pharmacy Admin Dashboard')),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                _loadData();
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.medical_services),
                label: Text('Products'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Employees'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.point_of_sale),
                label: Text('Sales'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_shipping),
                label: Text('Suppliers'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new item functionality
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_data.isEmpty) {
      return Center(child: Text('No data available'));
    }

    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (context, index) {
        final item = _data[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(item['name'] ?? 'No name'),
            subtitle: Text(item['description'] ?? 'No description'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Implement edit functionality
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // TODO: Implement delete functionality
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

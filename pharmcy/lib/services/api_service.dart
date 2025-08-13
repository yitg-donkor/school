import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://localhost:3000/api'; // Node.js server port (not MySQL port)

  // Authentication
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data'] ?? data; // Extract data if wrapped
      } else {
        throw Exception(data['error'] ?? 'Login failed');
      }
    } else {
      throw Exception('Failed to login');
    }
  }

  // Products
  Future<List<dynamic>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // API now returns arrays directly, no wrapper
      return List<dynamic>.from(data is List ? data : [data]);
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Add Product
  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add product');
    }
  }

  // Update Product
  Future<Map<String, dynamic>> updateProduct(
    int id,
    Map<String, dynamic> product,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update product');
    }
  }

  // Delete Product
  Future<Map<String, dynamic>> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete product');
    }
  }

  // Employees
  Future<List<dynamic>> getEmployees() async {
    final response = await http.get(Uri.parse('$baseUrl/employees'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // API now returns arrays directly, no wrapper
      return List<dynamic>.from(data is List ? data : [data]);
    } else {
      throw Exception('Failed to load employees');
    }
  }

  // Add Employee
  Future<Map<String, dynamic>> addEmployee(
    Map<String, dynamic> employee,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employees'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(employee),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add employee');
    }
  }

  // Update Employee
  Future<Map<String, dynamic>> updateEmployee(
    int id,
    Map<String, dynamic> employee,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/employees/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(employee),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update employee');
    }
  }

  // Delete Employee
  Future<Map<String, dynamic>> deleteEmployee(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/employees/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete employee');
    }
  }

  // Sales
  Future<List<dynamic>> getSales() async {
    final response = await http.get(Uri.parse('$baseUrl/sales'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // API now returns arrays directly, no wrapper
      return List<dynamic>.from(data is List ? data : [data]);
    } else {
      throw Exception('Failed to load sales');
    }
  }

  // Add Sale
  Future<Map<String, dynamic>> addSale(Map<String, dynamic> sale) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sales'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sale),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add sale');
    }
  }

  // Suppliers
  Future<List<dynamic>> getSuppliers() async {
    final response = await http.get(Uri.parse('$baseUrl/suppliers'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // API now returns arrays directly, no wrapper
      return List<dynamic>.from(data is List ? data : [data]);
    } else {
      throw Exception('Failed to load suppliers');
    }
  }

  // Add Supplier
  Future<Map<String, dynamic>> addSupplier(
    Map<String, dynamic> supplier,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/suppliers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(supplier),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add supplier');
    }
  }

  // Update Supplier
  Future<Map<String, dynamic>> updateSupplier(
    int id,
    Map<String, dynamic> supplier,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/suppliers/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(supplier),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update supplier');
    }
  }

  // Delete Supplier
  Future<Map<String, dynamic>> deleteSupplier(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/suppliers/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete supplier');
    }
  }

  // Customers
  Future<List<dynamic>> getCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/customers'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // API now returns arrays directly, no wrapper
      return List<dynamic>.from(data is List ? data : [data]);
    } else {
      throw Exception('Failed to load customers');
    }
  }

  // Add Customer
  Future<Map<String, dynamic>> addCustomer(
    Map<String, dynamic> customer,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(customer),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add customer');
    }
  }

  // Update Customer
  Future<Map<String, dynamic>> updateCustomer(
    int id,
    Map<String, dynamic> customer,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/customers/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(customer),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update customer');
    }
  }

  // Delete Customer
  Future<Map<String, dynamic>> deleteCustomer(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/customers/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete customer');
    }
  }

  // Pharmacies
  Future<List<dynamic>> getPharmacies() async {
    final response = await http.get(Uri.parse('$baseUrl/pharmacies'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // API now returns arrays directly, no wrapper
      return List<dynamic>.from(data is List ? data : [data]);
    } else {
      throw Exception('Failed to load pharmacies');
    }
  }

  // Add Pharmacy
  Future<Map<String, dynamic>> addPharmacy(
    Map<String, dynamic> pharmacy,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pharmacies'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(pharmacy),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add pharmacy');
    }
  }

  // Update Pharmacy
  Future<Map<String, dynamic>> updatePharmacy(
    int id,
    Map<String, dynamic> pharmacy,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pharmacies/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(pharmacy),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update pharmacy');
    }
  }

  // Delete Pharmacy
  Future<Map<String, dynamic>> deletePharmacy(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/pharmacies/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete pharmacy');
    }
  }

  // Branches
  Future<List<dynamic>> getBranches() async {
    final response = await http.get(Uri.parse('$baseUrl/branches'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // API now returns arrays directly, no wrapper
      return List<dynamic>.from(data is List ? data : [data]);
    } else {
      throw Exception('Failed to load branches');
    }
  }

  // Add Branch
  Future<Map<String, dynamic>> addBranch(Map<String, dynamic> branch) async {
    final response = await http.post(
      Uri.parse('$baseUrl/branches'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(branch),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add branch');
    }
  }

  // Update Branch
  Future<Map<String, dynamic>> updateBranch(
    int id,
    Map<String, dynamic> branch,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/branches/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(branch),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update branch');
    }
  }

  // Delete Branch
  Future<Map<String, dynamic>> deleteBranch(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/branches/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete branch');
    }
  }

  // Dashboard Stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard/stats'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data']; // Extract data object
      } else {
        throw Exception(data['error'] ?? 'Failed to load dashboard stats');
      }
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  // Health Check
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await http.get(Uri.parse('$baseUrl/health'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Health check failed');
    }
  }
}

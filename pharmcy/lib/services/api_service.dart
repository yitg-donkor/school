import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Helper method for handling responses
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  static List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<dynamic>.from(data is List ? data : [data]);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Health Check
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Health check failed: $e');
    }
  }

  // Dashboard Stats
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard/stats'));
      final data = _handleResponse(response);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to load dashboard stats');
      }
    } catch (e) {
      throw Exception('Failed to load dashboard stats: $e');
    }
  }

  // PHARMACY METHODS
  static Future<List<dynamic>> getPharmacies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pharmacies'));
      return _handleListResponse(response);
    } catch (e) {
      throw Exception('Failed to load pharmacies: $e');
    }
  }

  static Future<Map<String, dynamic>> addPharmacy(
    Map<String, dynamic> pharmacy,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pharmacies'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pharmacy),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to add pharmacy: $e');
    }
  }

  static Future<Map<String, dynamic>> updatePharmacy(
    int id,
    Map<String, dynamic> pharmacy,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pharmacies/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pharmacy),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update pharmacy: $e');
    }
  }

  static Future<Map<String, dynamic>> deletePharmacy(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/pharmacies/$id'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete pharmacy: $e');
    }
  }

  // BRANCH METHODS
  static Future<List<dynamic>> getBranches() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/branches'));
      return _handleListResponse(response);
    } catch (e) {
      throw Exception('Failed to load branches: $e');
    }
  }

  static Future<Map<String, dynamic>> addBranch(
    Map<String, dynamic> branch,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/branches'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(branch),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to add branch: $e');
    }
  }

  static Future<Map<String, dynamic>> updateBranch(
    int id,
    Map<String, dynamic> branch,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/branches/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(branch),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update branch: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteBranch(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/branches/$id'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete branch: $e');
    }
  }

  // EMPLOYEE METHODS
  static Future<List<dynamic>> getEmployees() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/employees'));
      return _handleListResponse(response);
    } catch (e) {
      throw Exception('Failed to load employees: $e');
    }
  }

  static Future<Map<String, dynamic>> addEmployee(
    Map<String, dynamic> employee,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employees'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(employee),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to add employee: $e');
    }
  }

  static Future<Map<String, dynamic>> updateEmployee(
    int id,
    Map<String, dynamic> employee,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/employees/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(employee),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteEmployee(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/employees/$id'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }

  // PRODUCT METHODS
  static Future<List<dynamic>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      return _handleListResponse(response);
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  static Future<Map<String, dynamic>> addProduct(
    Map<String, dynamic> product,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProduct(
    int id,
    Map<String, dynamic> product,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // SUPPLIER METHODS
  static Future<List<dynamic>> getSuppliers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/suppliers'));
      return _handleListResponse(response);
    } catch (e) {
      throw Exception('Failed to load suppliers: $e');
    }
  }

  static Future<Map<String, dynamic>> addSupplier(
    Map<String, dynamic> supplier,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/suppliers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(supplier),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to add supplier: $e');
    }
  }

  static Future<Map<String, dynamic>> updateSupplier(
    int id,
    Map<String, dynamic> supplier,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/suppliers/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(supplier),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update supplier: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteSupplier(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/suppliers/$id'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete supplier: $e');
    }
  }

  // CUSTOMER METHODS
  static Future<List<dynamic>> getCustomers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/customers'));
      return _handleListResponse(response);
    } catch (e) {
      throw Exception('Failed to load customers: $e');
    }
  }

  static Future<Map<String, dynamic>> addCustomer(
    Map<String, dynamic> customer,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(customer),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to add customer: $e');
    }
  }

  static Future<Map<String, dynamic>> updateCustomer(
    int id,
    Map<String, dynamic> customer,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/customers/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(customer),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteCustomer(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/customers/$id'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  // SALES METHODS
  static Future<List<dynamic>> getSales() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sales'));
      return _handleListResponse(response);
    } catch (e) {
      throw Exception('Failed to load sales: $e');
    }
  }

  static Future<Map<String, dynamic>> addSale(Map<String, dynamic> sale) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sales'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(sale),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to add sale: $e');
    }
  }

  // RECEIPT METHODS
  static Future<List<dynamic>> getReceipts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/receipts'));
      return _handleListResponse(response);
    } catch (e) {
      throw Exception('Failed to load receipts: $e');
    }
  }

  static Future<Map<String, dynamic>> addReceipt(
    Map<String, dynamic> receipt,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/receipts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(receipt),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to add receipt: $e');
    }
  }

  static Future<Map<String, dynamic>> updateReceipt(
    String id,
    Map<String, dynamic> receipt,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/receipts/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(receipt),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update receipt: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteReceipt(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/receipts/$id'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete receipt: $e');
    }
  }

  // ATTENDANCE METHODS
  static Future<List<dynamic>> getAttendance() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/attendance'));
      return _handleListResponse(response);
    } catch (e) {
      throw Exception('Failed to load attendance: $e');
    }
  }

  static Future<Map<String, dynamic>> addAttendance(
    Map<String, dynamic> attendance,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(attendance),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to add attendance: $e');
    }
  }

  static Future<Map<String, dynamic>> updateAttendance(
    int id,
    Map<String, dynamic> attendance,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/attendance/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(attendance),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update attendance: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteAttendance(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/attendance/$id'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete attendance: $e');
    }
  }

  // SUPPLIER PRODUCT METHODS
  static Future<List<dynamic>> getSupplierProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/supplier-products'));
      return _handleListResponse(response);
    } catch (e) {
      throw Exception('Failed to load supplier products: $e');
    }
  }

  static Future<Map<String, dynamic>> addSupplierProduct(
    Map<String, dynamic> supplierProduct,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/supplier-products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(supplierProduct),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to add supplier product: $e');
    }
  }

  static Future<Map<String, dynamic>> updateSupplierProduct(
    int id,
    Map<String, dynamic> supplierProduct,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/supplier-products/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(supplierProduct),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update supplier product: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteSupplierProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/supplier-products/$id'),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete supplier product: $e');
    }
  }

  // AUTHENTICATION (if you want to add login functionality later)
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = _handleResponse(response);
      if (data['success']) {
        return data['data'] ?? data;
      } else {
        throw Exception(data['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // UTILITY METHODS
  static Future<bool> testConnection() async {
    try {
      final response = await healthCheck();
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Batch operations for better performance
  static Future<Map<String, dynamic>> getBatchData() async {
    try {
      final futures = await Future.wait([
        getPharmacies(),
        getBranches(),
        getEmployees(),
        getProducts(),
        getSuppliers(),
        getCustomers(),
      ]);

      return {
        'pharmacies': futures[0],
        'branches': futures[1],
        'employees': futures[2],
        'products': futures[3],
        'suppliers': futures[4],
        'customers': futures[5],
      };
    } catch (e) {
      throw Exception('Failed to load batch data: $e');
    }
  }
}

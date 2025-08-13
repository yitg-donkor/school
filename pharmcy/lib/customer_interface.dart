import 'package:flutter/material.dart';

class CustomerHomePage extends StatefulWidget {
  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _currentIndex = 0;
  List<CartItem> cartItems = [];
  Customer currentCustomer = Customer(
    id: 'CUST001',
    name: 'John Doe',
    contact: '+1234567890',
    createdAt: DateTime.now(),
  );

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomePage(onAddToCart: _addToCart, customer: currentCustomer),
      ProductSearchPage(onAddToCart: _addToCart),
      CartPage(
        cartItems: cartItems,
        onUpdateCart: _updateCart,
        customer: currentCustomer,
      ),
      CustomerProfilePage(customer: currentCustomer),
    ]);
  }

  void _addToCart(Product product, String pharmacyId) {
    setState(() {
      final existingIndex = cartItems.indexWhere(
        (item) =>
            item.product.id == product.id && item.pharmacyId == pharmacyId,
      );
      if (existingIndex >= 0) {
        cartItems[existingIndex].quantity++;
      } else {
        cartItems.add(
          CartItem(product: product, quantity: 1, pharmacyId: pharmacyId),
        );
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${product.name} added to cart')));
  }

  void _updateCart(List<CartItem> updatedItems) {
    setState(() {
      cartItems = updatedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Products'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text(
                        '${cartItems.length}',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Function(Product, String) onAddToCart;
  final Customer customer;

  HomePage({required this.onAddToCart, required this.customer});

  final List<Pharmacy> nearbyPharmacies = [
    Pharmacy(
      id: 'PH001',
      name: 'Central Pharmacy',
      address: '123 Main St',
      contact: '+1234567890',
    ),
    Pharmacy(
      id: 'PH002',
      name: 'City Medical Store',
      address: '456 Oak Ave',
      contact: '+1234567891',
    ),
    Pharmacy(
      id: 'PH003',
      name: 'HealthCare Plus',
      address: '789 Pine Rd',
      contact: '+1234567892',
    ),
  ];

  final List<Product> featuredProducts = [
    Product(
      id: 'PROD001',
      name: 'Paracetamol 500mg',
      unitPrice: 5.99,
      quantity: 150,
      supplierId: 'SUP001',
      latestExpiryDate: DateTime.now().add(Duration(days: 365)),
      createdAt: DateTime.now(),
    ),
    Product(
      id: 'PROD002',
      name: 'Vitamin C 1000mg',
      unitPrice: 12.99,
      quantity: 200,
      supplierId: 'SUP002',
      latestExpiryDate: DateTime.now().add(Duration(days: 730)),
      createdAt: DateTime.now(),
    ),
    Product(
      id: 'PROD003',
      name: 'Cough Syrup',
      unitPrice: 8.50,
      quantity: 85,
      supplierId: 'SUP003',
      latestExpiryDate: DateTime.now().add(Duration(days: 365)),
      createdAt: DateTime.now(),
    ),
    Product(
      id: 'PROD004',
      name: 'Antiseptic Cream',
      unitPrice: 6.99,
      quantity: 120,
      supplierId: 'SUP001',
      latestExpiryDate: DateTime.now().add(Duration(days: 540)),
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pharmacy Network'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: Icon(Icons.location_on), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              height: 200,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade300, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome, ${customer.name}!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Find medicines from trusted pharmacies',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'Find Nearby Pharmacies',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nearby Pharmacies
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearby Pharmacies',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(child: Text('View All'), onPressed: () {}),
                ],
              ),
            ),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: nearbyPharmacies.length,
                itemBuilder: (context, index) {
                  return PharmacyCard(pharmacy: nearbyPharmacies[index]);
                },
              ),
            ),

            SizedBox(height: 24),

            // Featured Products
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(child: Text('View All'), onPressed: () {}),
                ],
              ),
            ),
            Container(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: featuredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: featuredProducts[index],
                    pharmacyId:
                        nearbyPharmacies[0].id, // Default to first pharmacy
                    onAddToCart: onAddToCart,
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ProductSearchPage extends StatefulWidget {
  final Function(Product, String) onAddToCart;

  ProductSearchPage({required this.onAddToCart});

  @override
  _ProductSearchPageState createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  TextEditingController _searchController = TextEditingController();
  String selectedPharmacy = 'All Pharmacies';

  final List<Pharmacy> pharmacies = [
    Pharmacy(
      id: 'PH001',
      name: 'Central Pharmacy',
      address: '123 Main St',
      contact: '+1234567890',
    ),
    Pharmacy(
      id: 'PH002',
      name: 'City Medical Store',
      address: '456 Oak Ave',
      contact: '+1234567891',
    ),
    Pharmacy(
      id: 'PH003',
      name: 'HealthCare Plus',
      address: '789 Pine Rd',
      contact: '+1234567892',
    ),
  ];

  List<Product> allProducts = [
    Product(
      id: 'PROD001',
      name: 'Paracetamol 500mg',
      unitPrice: 5.99,
      quantity: 150,
      supplierId: 'SUP001',
      latestExpiryDate: DateTime.now().add(Duration(days: 365)),
      createdAt: DateTime.now(),
    ),
    Product(
      id: 'PROD002',
      name: 'Ibuprofen 200mg',
      unitPrice: 7.99,
      quantity: 75,
      supplierId: 'SUP002',
      latestExpiryDate: DateTime.now().add(Duration(days: 400)),
      createdAt: DateTime.now(),
    ),
    Product(
      id: 'PROD003',
      name: 'Vitamin C 1000mg',
      unitPrice: 12.99,
      quantity: 200,
      supplierId: 'SUP002',
      latestExpiryDate: DateTime.now().add(Duration(days: 730)),
      createdAt: DateTime.now(),
    ),
    Product(
      id: 'PROD004',
      name: 'Vitamin D3',
      unitPrice: 15.50,
      quantity: 0,
      supplierId: 'SUP003',
      latestExpiryDate: DateTime.now().add(Duration(days: 600)),
      createdAt: DateTime.now(),
    ),
    Product(
      id: 'PROD005',
      name: 'Cough Syrup',
      unitPrice: 8.50,
      quantity: 85,
      supplierId: 'SUP003',
      latestExpiryDate: DateTime.now().add(Duration(days: 365)),
      createdAt: DateTime.now(),
    ),
  ];

  List<Product> get filteredProducts {
    return allProducts.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Products'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedPharmacy,
                  decoration: InputDecoration(
                    labelText: 'Select Pharmacy',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'All Pharmacies',
                      child: Text('All Pharmacies'),
                    ),
                    ...pharmacies.map(
                      (pharmacy) => DropdownMenuItem(
                        value: pharmacy.id,
                        child: Text(pharmacy.name),
                      ),
                    ),
                  ],
                  onChanged:
                      (value) => setState(() => selectedPharmacy = value!),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductListTile(
                  product: filteredProducts[index],
                  pharmacyId: pharmacies[0].id, // Default pharmacy
                  onAddToCart: widget.onAddToCart,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(List<CartItem>) onUpdateCart;
  final Customer customer;

  CartPage({
    required this.cartItems,
    required this.onUpdateCart,
    required this.customer,
  });

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get totalAmount {
    return widget.cartItems.fold(
      0,
      (sum, item) => sum + (item.product.unitPrice * item.quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
        backgroundColor: Colors.green,
      ),
      body:
          widget.cartItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    Text(
                      'Add some products to get started',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        return CartItemWidget(
                          cartItem: widget.cartItems[index],
                          onQuantityChanged: (newQuantity) {
                            setState(() {
                              if (newQuantity <= 0) {
                                widget.cartItems.removeAt(index);
                              } else {
                                widget.cartItems[index].quantity = newQuantity;
                              }
                            });
                            widget.onUpdateCart(widget.cartItems);
                          },
                          onRemove: () {
                            setState(() {
                              widget.cartItems.removeAt(index);
                            });
                            widget.onUpdateCart(widget.cartItems);
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                widget.cartItems.isNotEmpty
                                    ? _proceedToCheckout
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: Text(
                              'Complete Purchase',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  void _proceedToCheckout() {
    // Create a new sale record
    final sale = Sale(
      id: 'SALE_${DateTime.now().millisecondsSinceEpoch}',
      employeeId: 'EMP001', // This would be the pharmacist processing the order
      customerId: widget.customer.id,
      productId:
          widget
              .cartItems
              .first
              .product
              .id, // In real app, handle multiple products
      quantity: widget.cartItems.fold(0, (sum, item) => sum + item.quantity),
      totalCost: totalAmount,
      status: 'pending',
      paymentMethod: 'card',
      receiptNum: 'REC_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Order Confirmation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sale ID: ${sale.id}'),
                Text('Customer: ${widget.customer.name}'),
                Text('Items: ${widget.cartItems.length}'),
                Text('Total: \$${totalAmount.toStringAsFixed(2)}'),
                SizedBox(height: 12),
                Text(
                  'Your order will be processed and ready for pickup shortly.',
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text('Confirm Order'),
                onPressed: () {
                  // Clear cart after successful order
                  widget.onUpdateCart([]);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Order placed successfully! Receipt: ${sale.receiptNum}',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
    );
  }
}

class CustomerProfilePage extends StatelessWidget {
  final Customer customer;

  CustomerProfilePage({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Profile'), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.green.shade100,
                      child: Text(
                        customer.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Customer ID: ${customer.id}',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Contact: ${customer.contact}',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Member since: ${_formatDate(customer.createdAt)}',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            _buildProfileOption(Icons.history, 'Purchase History', () {}),
            _buildProfileOption(Icons.receipt, 'Receipts', () {}),
            _buildProfileOption(
              Icons.local_pharmacy,
              'Favorite Pharmacies',
              () {},
            ),
            _buildProfileOption(Icons.location_on, 'Saved Addresses', () {}),
            _buildProfileOption(Icons.payment, 'Payment Methods', () {}),
            _buildProfileOption(Icons.notifications, 'Notifications', () {}),
            _buildProfileOption(Icons.help, 'Help & Support', () {}),
            _buildProfileOption(Icons.settings, 'Account Settings', () {}),
            _buildProfileOption(
              Icons.logout,
              'Logout',
              () {},
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildProfileOption(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.green),
        title: Text(
          title,
          style: TextStyle(color: isDestructive ? Colors.red : null),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// Data Models matching the ERD
class Customer {
  final String id;
  final String name;
  final String contact;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.contact,
    required this.createdAt,
  });
}

class Product {
  final String id;
  final String name;
  final double unitPrice;
  final int quantity;
  final String supplierId;
  final DateTime latestExpiryDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.supplierId,
    required this.latestExpiryDate,
    required this.createdAt,
    this.updatedAt,
  });
}

class Pharmacy {
  final String id;
  final String name;
  final String address;
  final String contact;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
  });
}

class Sale {
  final String id;
  final String employeeId;
  final String customerId;
  final String productId;
  final int quantity;
  final double totalCost;
  final String status;
  final String paymentMethod;
  final String receiptNum;
  final DateTime createdAt;

  Sale({
    required this.id,
    required this.employeeId,
    required this.customerId,
    required this.productId,
    required this.quantity,
    required this.totalCost,
    required this.status,
    required this.paymentMethod,
    required this.receiptNum,
    required this.createdAt,
  });
}

class CartItem {
  final Product product;
  int quantity;
  final String pharmacyId;

  CartItem({
    required this.product,
    required this.quantity,
    required this.pharmacyId,
  });
}

// Widget Components
class PharmacyCard extends StatelessWidget {
  final Pharmacy pharmacy;

  PharmacyCard({required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_pharmacy, color: Colors.green, size: 24),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pharmacy.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                pharmacy.address,
                style: TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                pharmacy.contact,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final String pharmacyId;
  final Function(Product, String) onAddToCart;

  ProductCard({
    required this.product,
    required this.pharmacyId,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isInStock = product.quantity > 0;
    final isExpiringSoon =
        product.latestExpiryDate.difference(DateTime.now()).inDays < 30;

    return Container(
      width: 180,
      margin: EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product icon/image placeholder
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.medication, size: 32, color: Colors.green),
                ),
              ),
              SizedBox(height: 8),
              Text(
                product.name,
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                'Stock: ${product.quantity}',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              if (isExpiringSoon)
                Text(
                  'Expires soon!',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              SizedBox(height: 8),
              Text(
                '\$${product.unitPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              if (!isInStock)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Out of Stock',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onAddToCart(product, pharmacyId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductListTile extends StatelessWidget {
  final Product product;
  final String pharmacyId;
  final Function(Product, String) onAddToCart;

  ProductListTile({
    required this.product,
    required this.pharmacyId,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isInStock = product.quantity > 0;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.medication, color: Colors.green),
        ),
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stock: ${product.quantity}'),
            Row(
              children: [
                Text(
                  '\$${product.unitPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isInStock) ...[
                  SizedBox(width: 8),
                  Text(
                    'Out of Stock',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing:
            isInStock
                ? ElevatedButton(
                  onPressed: () => onAddToCart(product, pharmacyId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Add', style: TextStyle(color: Colors.white)),
                )
                : null,
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  CartItemWidget({
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.medication, color: Colors.green),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\${cartItem.product.unitPrice.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.green),
                  ),
                  Text(
                    'Subtotal: \${(cartItem.product.unitPrice * cartItem.quantity).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => onQuantityChanged(cartItem.quantity - 1),
                  icon: Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '${cartItem.quantity}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => onQuantityChanged(cartItem.quantity + 1),
                  icon: Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

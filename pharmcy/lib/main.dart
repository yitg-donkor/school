import 'package:flutter/material.dart';
import 'package:pharmcy/customer_interface.dart';
import 'package:pharmcy/pharmacist_interface.dart';
import 'package:pharmcy/screens/admin_dashboard.dart';

void main() {
  runApp(PharmacyCustomerApp());
}

class PharmacyCustomerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCare Pharmacy',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AdminDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';

import 'package:pharmcy/pharmacist_interface.dart';


void main() {
  runApp(PharmacyCustomerApp());
}

class PharmacyCustomerApp extends StatelessWidget {
  const PharmacyCustomerApp({super.key});

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

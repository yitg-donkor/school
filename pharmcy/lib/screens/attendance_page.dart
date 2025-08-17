import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Map<String, dynamic>> attendanceRecords = [];
  List<Map<String, dynamic>> employees = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch attendance records and employees in parallel
      final attendanceResponse = await http.get(
        Uri.parse('http://localhost:3000/api/attendance'),
      );
      final employeesResponse = await http.get(
        Uri.parse('http://localhost:3000/api/employees'),
      );

      if (attendanceResponse.statusCode == 200 &&
          employeesResponse.statusCode == 200) {
        final attendanceData = json.decode(attendanceResponse.body);
        final employeesData = json.decode(employeesResponse.body);

        setState(() {
          attendanceRecords = List<Map<String, dynamic>>.from(
            attendanceData is List ? attendanceData : [attendanceData],
          );
          employees = List<Map<String, dynamic>>.from(
            employeesData is List ? employeesData : [employeesData],
          );
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    }
  }

  String getEmployeeName(int empId) {
    final employee = employees.firstWhere(
      (emp) => emp['employee_id'] == empId,
      orElse: () => {'name': 'Unknown Employee'},
    );
    return employee['name'] ?? 'Unknown Employee';
  }

  String calculateHoursWorked(String? checkIn, String? checkOut) {
    if (checkIn == null ||
        checkOut == null ||
        checkIn.isEmpty ||
        checkOut.isEmpty) {
      return 'N/A';
    }

    try {
      // Parse time strings (assuming format HH:MM:SS)
      final checkInTime = TimeOfDay(
        hour: int.parse(checkIn.split(':')[0]),
        minute: int.parse(checkIn.split(':')[1]),
      );
      final checkOutTime = TimeOfDay(
        hour: int.parse(checkOut.split(':')[0]),
        minute: int.parse(checkOut.split(':')[1]),
      );

      // Convert to minutes for easier calculation
      final checkInMinutes = checkInTime.hour * 60 + checkInTime.minute;
      final checkOutMinutes = checkOutTime.hour * 60 + checkOutTime.minute;

      // Calculate difference
      int diffMinutes = checkOutMinutes - checkInMinutes;

      // Handle overnight shifts (if check out is next day)
      if (diffMinutes < 0) {
        diffMinutes += 24 * 60; // Add 24 hours worth of minutes
      }

      final hours = diffMinutes ~/ 60;
      final minutes = diffMinutes % 60;

      return '${hours}h ${minutes}m';
    } catch (e) {
      return 'Invalid';
    }
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return 'Not set';

    try {
      // If time includes seconds, remove them for display
      if (time.contains(':') && time.split(':').length == 3) {
        return time.substring(0, 5); // Take only HH:MM
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  List<Map<String, dynamic>> get filteredRecords {
    if (searchQuery.isEmpty) return attendanceRecords;
    return attendanceRecords.where((record) {
      final employeeName = getEmployeeName(record['emp_id']);
      return employeeName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          record['date'].toString().contains(searchQuery) ||
          record['emp_id'].toString().contains(searchQuery);
    }).toList();
  }

  deleteAttendance(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/attendance/$id'),
      );
      if (response.statusCode == 200) {
        fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance record deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        throw Exception('Failed to delete attendance record');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting record: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gridColumns =
        size.width < 1200
            ? 1
            : size.width < 1600
            ? 2
            : 3;

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
                        color: Colors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.access_time,
                        color: Colors.cyan,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Records',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2c3e50),
                          ),
                        ),
                        Text(
                          'Track employee attendance and working hours.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAttendanceDialog(context, {}),
                      icon: Icon(Icons.add),
                      label: Text('Add Attendance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
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
                      hintText: 'Search by employee name, date, or ID...',
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                    ),
                    SizedBox(height: 16),
                    Text('Loading attendance records...'),
                  ],
                ),
              )
              : Padding(
                padding: EdgeInsets.all(24),
                child:
                    filteredRecords.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                searchQuery.isEmpty
                                    ? 'No attendance records found'
                                    : 'No results found for "$searchQuery"',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                        : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridColumns,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.4,
                              ),
                          itemCount: filteredRecords.length,
                          itemBuilder: (context, index) {
                            final record = filteredRecords[index];
                            return _buildAttendanceCard(record);
                          },
                        ),
              ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    final employeeName = getEmployeeName(record['emp_id']);
    final hoursWorked = calculateHoursWorked(
      record['check_in_time'],
      record['check_out_time'],
    );
    final checkOutTime = formatTime(record['check_out_time']);
    final checkInTime = formatTime(record['check_in_time']);

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
          onTap: () => _showAttendanceDialog(context, record),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person, color: Colors.cyan, size: 20),
                    ),
                    Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showAttendanceDialog(context, record);
                        } else if (value == 'delete') {
                          _showDeleteDialog(record);
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

                // Employee Name
                Text(
                  employeeName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),

                // Date
                Text(
                  'Date: ${record['date'] ?? 'Not set'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),

                // Time Information Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check In',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            checkInTime,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 20, width: 1, color: Colors.grey[300]),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Check Out',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            checkOutTime,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  checkOutTime == 'Not set'
                                      ? Colors.orange[700]
                                      : Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Spacer(),

                // Hours Worked and Employee ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            hoursWorked == 'N/A' || hoursWorked == 'Invalid'
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Hours: $hoursWorked',
                        style: TextStyle(
                          color:
                              hoursWorked == 'N/A' || hoursWorked == 'Invalid'
                                  ? Colors.orange[700]
                                  : Colors.cyan[700],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'ID: ${record['emp_id']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete this attendance record for ${getEmployeeName(record['emp_id'])}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  deleteAttendance(record['attnd_id']);
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
        fetchData(); // Refresh the data
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

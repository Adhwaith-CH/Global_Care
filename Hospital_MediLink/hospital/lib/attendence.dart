import 'package:flutter/material.dart';

class StaffAttendancePage extends StatefulWidget {
  const StaffAttendancePage({super.key});

  @override
  _StaffAttendancePageState createState() => _StaffAttendancePageState();
}

class _StaffAttendancePageState extends State<StaffAttendancePage> {
  // Sample list of staff members (In a real app, this could be fetched from a backend)
  List<Map<String, String>> _staffMembers = [
    {'name': 'Dr. John Doe', 'position': 'Doctor'},
    {'name': 'Nurse Jane Smith', 'position': 'Nurse'},
    {'name': 'Admin Lisa Brown', 'position': 'Administrator'},
    {'name': 'Dr. Emily White', 'position': 'Doctor'},
    {'name': 'Nurse Michael Davis', 'position': 'Nurse'},
  ];

  // Attendance state (can be expanded to store actual attendance data)
  Map<String, String> _attendanceState = {};

  // Search controller
  TextEditingController _searchController = TextEditingController();

  // Filtered staff list based on search query
  List<Map<String, String>> _filteredStaffMembers = [];

  @override
  void initState() {
    super.initState();
    _filteredStaffMembers = _staffMembers;
    _searchController.addListener(_filterStaffList);
  }

  // Filter staff list based on search query
  void _filterStaffList() {
    setState(() {
      _filteredStaffMembers = _staffMembers
          .where((staff) =>
              staff['name']!.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  // Mark attendance function (can be extended to integrate with a backend)
  void _markAttendance(String staffName, String status) {
    setState(() {
      _attendanceState[staffName] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Staff Attendance", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search staff...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),

            // List of staff members with attendance options
            Expanded(
              child: ListView.builder(
                itemCount: _filteredStaffMembers.length,
                itemBuilder: (context, index) {
                  final staff = _filteredStaffMembers[index];
                  String staffName = staff['name']!;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      title: Text(
                        staffName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(staff['position']!, style: TextStyle(color: Colors.grey)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Present button
                          TextButton(
                            onPressed: () {
                              _markAttendance(staffName, 'Present');
                            },
                            child: Text(
                              'Present',
                              style: TextStyle(
                                color: _attendanceState[staffName] == 'Present'
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                          ),
                          // Absent button
                          TextButton(
                            onPressed: () {
                              _markAttendance(staffName, 'Absent');
                            },
                            child: Text(
                              'Absent',
                              style: TextStyle(
                                color: _attendanceState[staffName] == 'Absent'
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ),
                          ),
                          // Leave button
                          TextButton(
                            onPressed: () {
                              _markAttendance(staffName, 'Leave');
                            },
                            child: Text(
                              'Leave',
                              style: TextStyle(
                                color: _attendanceState[staffName] == 'Leave'
                                    ? Colors.orange
                                    : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

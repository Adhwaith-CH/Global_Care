import 'package:flutter/material.dart';
import 'package:hospital/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffAttendancePage extends StatefulWidget {
  const StaffAttendancePage({super.key});

  @override
  _StaffAttendancePageState createState() => _StaffAttendancePageState();
}

class _StaffAttendancePageState extends State<StaffAttendancePage> {
  final supabase = Supabase.instance.client;

  // Attendance state (can be expanded to store actual attendance data)
  final Map<String, String> _attendanceState = {};

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Filtered staff list based on search query
  List<Map<String, String>> _filteredStaffMembers = [];
  List<Map<String, dynamic>> doctorlist = [];
  List<Map<String, dynamic>> _filteredDoctorList = [];
  int status = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterDoctorList);
    fetchDoctor(); // Fetch doctors from database
  }

  // Filter staff list based on search query
  void _filterDoctorList() {
    setState(() {
      _filteredDoctorList = doctorlist
          .where((doctor) => doctor['doctor_name']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  // Mark attendance function (can be extended to integrate with a backend)
  void _markAttendance(String staffName, String status) {
    setState(() {
      _attendanceState[staffName] = status;
    });
  }

  Future<void> fetchDoctor() async {
    try {
      final response = await supabase.from('tbl_doctor').select(
          "*, tbl_hospitaldepartment(*, tbl_department(*)), tbl_place(*, tbl_district(*))");
      print("Doctor: $response");

      setState(() {
        doctorlist = response;
        _filterDoctorList(); // Update search results
      });
    } catch (e) {
      debugPrint('Error fetching doctors: $e');
    }
  }

  Future<void> attendence(String id, int status) async {
    try {
      await supabase.from('tbl_attendence').insert({
        'attendence_status': status,
        'doctor_id': id,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Present')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error:$e")));

      print('Operation failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor Attendance",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                labelText: "Search Doctor...",
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),

            // List of staff members with attendance options
            Expanded(
              child: ListView.builder(
                itemCount: _filteredDoctorList.length,
                itemBuilder: (context, index) {
                  final staff = _filteredDoctorList[index];
                  print("Staff: $staff");
                  final doctor = staff['doctor_name'];
                  final department = staff['tbl_hospitaldepartment']
                      ['tbl_department']['department_name'];
                  final id = staff['doctor_id'];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      title: Text(
                        doctor,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(department,
                          style: TextStyle(color: Colors.grey)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Present button
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _attendanceState[id] =
                                    'Present'; // Mark as Present
                              });
                              status = 1;
                              attendence(id, status);
                            },
                            child: Text(
                              'Present',
                              style: TextStyle(
                                color: _attendanceState[id] == 'Present'
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                          ),
                          // Absent button
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _attendanceState[id] =
                                    'Absent'; // Mark as Absent
                              });
                              status = 2;
                              attendence(id, status);
                            },
                            child: Text(
                              'Absent',
                              style: TextStyle(
                                color: _attendanceState[id] == 'Absent'
                                    ? Colors.red
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

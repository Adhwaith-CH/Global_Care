import 'package:flutter/material.dart';
import 'package:hospital/appointment_report.dart';
import 'package:hospital/departmentselection.dart';
import 'package:hospital/main.dart';

class CounterStaffDashboard extends StatefulWidget {
  const CounterStaffDashboard({super.key});

  @override
  _CounterStaffDashboardState createState() => _CounterStaffDashboardState();
}

class _CounterStaffDashboardState extends State<CounterStaffDashboard> {
  Map<String, int> _doctorTokens = {};
  List<Map<String, dynamic>> _appointments = [];
  String _selectedDoctorFilter = "All";
  Map<String, dynamic> _userDetails = {};

  @override
  void initState() {
    super.initState();
    fetchDoctors();
    fetchAppointments();
    fetchUsers();
  }

  Future<void> fetchAppointments() async {
    try {
      final response = await supabase
    .from('tbl_appointment')
    .select('*, tbl_availability(*, tbl_doctor(*))')
    // .eq('appointment_status', 1)
    .eq('appointment_type', 'ON'); 
  print(response);

      setState(() {
        _appointments = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    }
  }

  Future<void> fetchDoctors() async {
  try {
    final response = await supabase
        .from('tbl_doctor')
        .select('doctor_name, doctor_gid, doctor_id');

    setState(() {
      _doctorTokens = {
        for (var doctor in response)
          "Dr. ${doctor['doctor_name'] ?? 'Unknown'} (${doctor['doctor_gid'] ?? 'Unknown'})": 0
      };
    });
  } catch (e) {
    debugPrint('Error fetching doctors: $e');
  }
}


  Future<void> fetchUsers() async {
  try {
    final response = await supabase
        .from('tbl_user')
        .select('user_id, user_name, user_contact');
    setState(() {
      _userDetails = {
        for (var user in response)
          user['user_id']: {
            'user_name': user['user_name'] ?? 'Unknown',
            'user_contact': user['user_contact'] ?? 'N/A'
          }
      };
    });
  } catch (e) {
    debugPrint('Error fetching users: $e');
  }
}


  List<Map<String, dynamic>> _getFilteredAppointments() {
  return _appointments.where((appointment) {
    final availability = appointment['tbl_availability'];
    final doctor = availability != null ? availability['tbl_doctor'] : null;

    final doctorName = doctor != null ? doctor['doctor_name'] ?? 'Unknown' : 'Unknown';
    final doctorGID = doctor != null ? doctor['doctor_gid'] ?? 'Unknown' : 'Unknown';

    final doctorFilter = _selectedDoctorFilter == "All" ||
        "Dr. $doctorName ($doctorGID)" == _selectedDoctorFilter;
    return doctorFilter;
  }).toList();
}


  @override
  Widget build(BuildContext context) {
    final filteredAppointments = _getFilteredAppointments();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Online Appointments Dashboard",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent),
        ),
        actions: [
          OutlinedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentReportPage(),));
          }, child: Text("Get Report"))
        ],
        backgroundColor: Color.fromARGB(255, 254, 255, 255),
        centerTitle: true,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60), // Reduced height since no tabs
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDoctorFilter,
                      items: ["All", ..._doctorTokens.keys].map((doctor) {
                        return DropdownMenuItem<String>(
                          value: doctor,
                          child: Text(
                            doctor,
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() {
                        _selectedDoctorFilter = value!;
                      }),
                      isExpanded: true,
                      icon:
                          Icon(Icons.arrow_drop_down, color: Color(0xFF0277BD)),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: filteredAppointments.isEmpty
                  ? Center(child: Text("No online appointments available."))
                  : ListView.builder(
                      itemCount: filteredAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = filteredAppointments[index];
                        final user = _userDetails[appointment['user_id']] ?? {};
                        final doctor =
                            appointment['tbl_availability']['tbl_doctor'];
                        final status =
                            "Confirmed (Token: ${appointment['appointment_token']})";
                        print("Filtered List: $appointment");
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                                "Patient: ${user['user_name'] ?? 'Unknown'}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Doctor: Dr. ${doctor['doctor_name']} (${doctor['doctor_gid']})"),
                                Text(
                                    "Date: ${appointment['appointment_date']}"),
                                Text(
                                    "Time: ${appointment['tbl_availability']['availability_time']}"),
                                Text(
                                    "Contact: ${user['user_contact'] ?? 'N/A'}"),
                                Text("Mode: Online"),
                              ],
                            ),
                            trailing: Text(
                              status,
                              style: TextStyle(color: Colors.green),
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

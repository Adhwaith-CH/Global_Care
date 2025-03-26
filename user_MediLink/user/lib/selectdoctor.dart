import 'package:flutter/material.dart';
import 'package:user/booking.dart';
import 'package:user/main.dart';

class DoctorBooking extends StatefulWidget {
  final int deptid;
  const DoctorBooking({super.key, required this.deptid});

  @override
  State<DoctorBooking> createState() => _DoctorBookingState();
}

class _DoctorBookingState extends State<DoctorBooking> {
  List<Map<String, dynamic>> doctorsList = [];
  List<Map<String, dynamic>> filteredDoctorsList = [];
  TextEditingController searchController = TextEditingController();

  Future<void> fetchdoctors() async {
    try {
      final response = await supabase
          .from('tbl_doctor')
          .select('*, tbl_hospitaldepartment(*,tbl_department(*))')
          .eq("hospitaldepartment_id", widget.deptid);
      
      setState(() {
        doctorsList = List<Map<String, dynamic>>.from(response);
        filteredDoctorsList = doctorsList; // Initialize with full list
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  void _filterDoctors(String query) {
    setState(() {
      filteredDoctorsList = doctorsList.where((doctor) {
        final doctorName = (doctor['doctor_name'] ?? '').toLowerCase();
        final departmentName = (doctor['tbl_hospitaldepartment']['tbl_department']['department_name'] ?? '').toLowerCase();
        final searchLower = query.toLowerCase();

        return doctorName.contains(searchLower) || departmentName.contains(searchLower);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchdoctors();
    searchController.addListener(() {
      _filterDoctors(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 247, 243, 243), const Color.fromARGB(255, 218, 228, 238)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Search Bar Container
                Padding(
                  padding: const EdgeInsets.only(top: 29),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by doctor or department...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color.fromARGB(255, 25, 83, 112),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Doctor List Vertical Card Design
                for (var doctor in filteredDoctorsList)
                  Container(
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey[200], // Optional light background
                              backgroundImage: (doctor['doctor_photo']?.isNotEmpty ?? false)
                                  ? NetworkImage(doctor['doctor_photo']!)
                                  : null,
                              child: (doctor['doctor_photo']?.isNotEmpty ?? false)
                                  ? null
                                  : const Icon(Icons.local_hospital, size: 30, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              doctor['doctor_name'] ?? 'Unknown Doctor',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 25, 83, 112),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              doctor['tbl_hospitaldepartment']['tbl_department']['department_name'] ?? 'Not specified',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 129, 143, 150),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AppointmentBookingPage(doctor: doctor),
                                  ),
                                );
                              },
                              child: const Text(
                                "Book Appointment",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 25, 83, 112),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

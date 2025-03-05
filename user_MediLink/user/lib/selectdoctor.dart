import 'package:flutter/material.dart';
import 'package:user/main.dart';

class DoctorBooking extends StatefulWidget {
  final int deptid;
  const DoctorBooking({super.key, required this.deptid});

  @override
  State<DoctorBooking> createState() => _DoctorBookingState();
}

class _DoctorBookingState extends State<DoctorBooking> {
List<Map<String, dynamic>> doctorsList = [];



   Future<void> fetchdoctors() async {
    try {

      final response = await supabase
          .from('tbl_doctor')
          .select('*, tbl_hospitaldepartment(*,tbl_department(*))')
          .eq("hospitaldepartment_id", widget.deptid);
    print(response);
      setState(() {
        doctorsList = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdoctors();
  }


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
             colors: [Colors.blueGrey.shade50, Colors.blueGrey.shade200],
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
                            decoration: InputDecoration(
                              hintText: 'Search doctors...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color:  Color.fromARGB(255, 0, 0, 0),
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
                for (var doctor in doctorsList)
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
                              radius: 50,
                              backgroundColor:  Color.fromARGB(255, 0, 0, 0),
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              doctor['doctor_name'] ?? 'Unknown Doctor',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color:  Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              doctor['tbl_hospitaldepartment']['tbl_department']['department_name'] ?? 'Not specified',
                              style: const TextStyle(
                                fontSize: 16,
                                color:  Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                // Booking functionality here
                              },
                              child: const Text(
                                "Book Appointment",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:  Color.fromARGB(255, 0, 0, 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ),
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

// Dummy Data for Doctors
// final List<Map<String, String>> _doctorsList = [
//   {'name': 'Dr. Aditi Sharma', 'specialization': 'Cardiologist'},
//   {'name': 'Dr. Rajesh Kumar', 'specialization': 'Dermatologist'},
//   {'name': 'Dr. Priya Menon', 'specialization': 'Pediatrician'},
//   {'name': 'Dr. Sameer Verma', 'specialization': 'Orthopedic Surgeon'},
// ];
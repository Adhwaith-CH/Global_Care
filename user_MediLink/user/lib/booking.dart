import 'package:flutter/material.dart';
import 'package:user/departmentselection.dart';
import 'package:user/main.dart';
import 'package:user/selectdoctor.dart';

class HospitalBooking extends StatefulWidget {
  const HospitalBooking({super.key});

  @override
  State<HospitalBooking> createState() => _HospitalBookingState();
}

class _HospitalBookingState extends State<HospitalBooking> {
   List<Map<String, dynamic>> hospitalList = [];
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchHospitalDepartments();
  }
   
  Future<void> fetchHospitalDepartments() async {
    try {
      

      final response = await supabase
          .from('tbl_hospital')
          .select('*');

      setState(() {
        hospitalList = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
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
                              hintText: 'Search hospitals...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color.fromARGB(255, 0, 0, 0),
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

                // Hospital List Container
                for (var hospital in hospitalList)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: double.infinity,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 40,
                          backgroundColor: Color.fromARGB(255, 0, 0, 0),
                          child: Icon(
                            Icons.local_hospital,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          hospital['hospital_name'] ?? 'Unknown Hospital',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        // subtitle: Text(
                        //   hospital['hospital_location'] ?? 'Location not specified',
                        //   style: const TextStyle(
                        //     fontSize: 16,
                        //     color: Color.fromARGB(255, 0, 0, 0),
                        //   ),
                        // ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DepartmentSelection(
                                        hospital_id:hospital['hospital_id']
                                      )),
                                );
                          },
                          child: const Text(
                            "Book",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 0, 0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
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

// Dummy Data for Hospitals
final List<Map<String, String>> _hospitalsList = [
  {'name': 'City Hospital', 'location': 'Downtown'},
  {'name': 'Sunrise Medical Center', 'location': 'West End'},
  {'name': 'Green Valley Hospital', 'location': 'East Side'},
  {'name': 'Grand Care Hospital', 'location': 'North District'},
];
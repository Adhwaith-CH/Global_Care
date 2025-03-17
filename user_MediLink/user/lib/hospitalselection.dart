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
  List<Map<String, dynamic>> filteredHospitalList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchHospitalDepartments();
    searchController.addListener(_filterHospitals);
  }

  Future<void> fetchHospitalDepartments() async {
    try {
      final response = await supabase
          .from('tbl_hospital')
          .select('*,tbl_place(*,tbl_district(*))');
      print(response);
      setState(() {
        hospitalList = response;
        filteredHospitalList = List.from(hospitalList); // Initially all hospitals
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  void _filterHospitals() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredHospitalList = hospitalList
          .where((hospital) =>
              hospital['hospital_name'].toLowerCase().contains(query) ||
              hospital['tbl_place']['place_name'].toLowerCase().contains(query) ||
              hospital['tbl_place']['tbl_district']['district_name']
                  .toLowerCase()
                  .contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 247, 243, 243),
              const Color.fromARGB(255, 218, 228, 238)
            ],
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
                for (var hospital in filteredHospitalList)
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
                          radius: 35,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              (hospital['hospital_photo']?.isNotEmpty ?? false)
                                  ? NetworkImage(hospital['hospital_photo']!)
                                  : null,
                          child:
                              (hospital['hospital_photo']?.isNotEmpty ?? false)
                                  ? null
                                  : const Icon(Icons.local_hospital,
                                      size: 30, color: Colors.grey),
                        ),
                        title: Text(
                          hospital['hospital_name'] ?? 'Unknown Hospital',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 15, 67, 94),
                          ),
                        ),
                        subtitle: Text(
                          "${hospital['tbl_place']['place_name']}, ${hospital['tbl_place']['tbl_district']['district_name']}" ??
                              'Location not specified',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DepartmentSelection(
                                      hospital_id: hospital['hospital_id'])),
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
                            backgroundColor: Color.fromARGB(255, 15, 67, 94),
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

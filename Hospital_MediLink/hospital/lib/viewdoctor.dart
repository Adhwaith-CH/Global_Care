import 'package:flutter/material.dart';
import 'package:hospital/adddoctor.dart';
import 'package:hospital/doctorprofile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewDoctor extends StatefulWidget {
  const ViewDoctor({super.key});

  @override
  State<ViewDoctor> createState() => _ViewDoctorState();
}

class _ViewDoctorState extends State<ViewDoctor> {
  final supabase = Supabase.instance.client;

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Doctor List
  List<Map<String, dynamic>> doctorlist = [];
  // Filtered doctor list based on search query
  List<Map<String, dynamic>> _filteredDoctorList = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterDoctorList);
    fetchDoctor(); // Fetch doctors from database
  }

  // Function to filter doctors based on search query
  void _filterDoctorList() {
    setState(() {
      _filteredDoctorList = doctorlist
          .where((doctor) => doctor['doctor_name']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  // Function to fetch doctors from Supabase
  Future<void> fetchDoctor() async {
    try {
      final response = await supabase.from('tbl_doctor').select(
          "*, tbl_hospitaldepartment(*, tbl_department(*)), tbl_place(*, tbl_district(*))");
      print(response);

      // Process response and map required data
      List<Map<String, dynamic>> tempList = response;

      setState(() {
        doctorlist = tempList;
        _filterDoctorList(); // Update search results
      });
    } catch (e) {
      debugPrint('Error fetching doctors: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Widget to build the doctor list card
  Widget _buildDetailCard(String name, String department, String photo) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(photo),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        title: Text(
          name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(department, style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0277BD),
        title: Text(
          "View Doctor",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 6,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search doctor...",
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),

            // List of Doctors
            Expanded(
              child: _filteredDoctorList.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredDoctorList.length,
                      itemBuilder: (context, index) {
                        final doctor = _filteredDoctorList[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DoctorProfilePage(
                                        doctor: doctor,
                                      )),
                            );
                          },
                          child: _buildDetailCard(
                              doctor['doctor_name'],
                              doctor['tbl_hospitaldepartment']['tbl_department']
                                  ['department_name'],
                              doctor['doctor_photo']),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No doctors found",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0277BD),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Adddoctor(),
              ));
        },
      ),
    );
  }
}

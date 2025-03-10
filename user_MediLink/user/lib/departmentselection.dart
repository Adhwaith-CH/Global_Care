import 'package:flutter/material.dart';
import 'package:user/main.dart';
import 'package:user/selectdoctor.dart';

class DepartmentSelection extends StatefulWidget {
  String hospital_id;
   DepartmentSelection({super.key, required this.hospital_id});

  @override
  State<DepartmentSelection> createState() => _DepartmentSelectionState();
}

class _DepartmentSelectionState extends State<DepartmentSelection> {
  List<Map<String, dynamic>> hospitalDepartmentList = [];

@override
  void initState() {
    super.initState();
    
    fetchHospitalDepartments();
  }
  
  Future<void> fetchHospitalDepartments() async {
    try {

      final response = await supabase
          .from('tbl_hospitaldepartment')
          .select('*, tbl_department(*)')
          .eq("hospital_id", widget.hospital_id);
    print(response);
      setState(() {
        hospitalDepartmentList = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Department"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade50, const Color.fromARGB(255, 93, 133, 153)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            itemCount: hospitalDepartmentList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, // Two columns
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8, // Controls card height
            ),
            itemBuilder: (context, index) {
              final department = hospitalDepartmentList[index];
              // Retrieve the department icon stored as an integer (codePoint)
              String? iconString =
                  department['tbl_department']['department_icon'];
              int? iconCode = int.tryParse(iconString ?? "0"); // Convert to int

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorBooking(deptid: department['hospitaldepartment_id'],)),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Selected: ${department['name']}")),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     iconCode != null && iconCode > 0
                                  ? Icon(
                                      IconData(iconCode,
                                          fontFamily: 'MaterialIcons'),
                                      size: 30,
                                      color: const Color.fromARGB(255, 3, 3, 3),
                                    )
                                  : const Icon(Icons.help_outline,
                                      size: 30, color: Color.fromARGB(255, 9, 13, 16)),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          department['tbl_department']['department_name'] ??
                              "Unknown",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
      ),
    );
  }
}

// Dummy Data for Departments
// final List<Map<String, dynamic>> _departmentsList = [
//   {'name': 'Cardiology', 'icon': Icons.favorite},
//   {'name': 'Dermatology', 'icon': Icons.spa},
//   {'name': 'Neurology', 'icon': Icons.psychology},
//   {'name': 'Orthopedics', 'icon': Icons.accessibility_new},
//   {'name': 'Pediatrics', 'icon': Icons.child_care},
//   {'name': 'Radiology', 'icon': Icons.spoke},
//   {'name': 'General Surgery', 'icon': Icons.local_hospital},
//   {'name': 'ENT', 'icon': Icons.hearing},
// ];

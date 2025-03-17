import 'package:flutter/material.dart';
import 'package:hospital/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DepartmentSelection extends StatefulWidget {
  const DepartmentSelection({super.key});

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
          .eq("hospital_id", supabase.auth.currentUser!.id);

      print("Fetched Departments: $response");

      setState(() {
        hospitalDepartmentList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching hospital departments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Department"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade50, const Color(0xFF5D8599)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            itemCount: hospitalDepartmentList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 Columns
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              final department = hospitalDepartmentList[index];
              final departmentName =
                  department['tbl_department']['department_name'] ?? "Unknown";

              // Safely fetch department_icon
              final iconString =
                  department['tbl_department']['department_icon'] as String?;
              final int? iconCode = iconString != null
                  ? int.tryParse(iconString)
                  : null; // Convert to int safely

              return GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   // MaterialPageRoute(
                  //   //   builder: (context) => DoctorBooking(
                  //   //       deptid: department['hospitaldepartment_id']),
                  //   // ),
                  // );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Selected: $departmentName")),
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
                      iconCode != null
                          ? Icon(
                              IconData(iconCode,
                                  fontFamily: 'MaterialIcons'),
                              size: 40,
                              color: Colors.black87,
                            )
                          : const Icon(Icons.help_outline,
                              size: 40, color: Colors.black54),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          departmentName,
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

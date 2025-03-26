import 'package:flutter/material.dart';
import 'package:hospital/doctorselection.dart';
import 'package:hospital/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DepartmentSelection extends StatefulWidget {
  const DepartmentSelection({super.key});

  @override
  State<DepartmentSelection> createState() => _DepartmentSelectionState();
}

class _DepartmentSelectionState extends State<DepartmentSelection> {
  List<Map<String, dynamic>> hospitalDepartmentList = [];
  List<Map<String, dynamic>> filteredDepartmentList = [];
  TextEditingController searchController = TextEditingController();

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
        filteredDepartmentList =
            hospitalDepartmentList; // Initialize filtered list
      });
    } catch (e) {
      debugPrint('Error fetching hospital departments: $e');
    }
  }

  // Function to filter departments based on search
  void filterDepartments(String query) {
    setState(() {
      filteredDepartmentList = hospitalDepartmentList
          .where((dept) => dept['tbl_department']['department_name']
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Department",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 3,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterDepartments, // Trigger filtering
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.blueGrey),
                  hintText: "Search departments...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Department Grid View
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey.shade50, Colors.blueGrey.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: filteredDepartmentList.isEmpty
                    ? Center(
                        child: Text(
                          "No departments found",
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      )
                    : GridView.builder(
                        itemCount: filteredDepartmentList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 columns for a compact look
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.2, // Adjust for better card size
                        ),
                        itemBuilder: (context, index) {
                          final department = filteredDepartmentList[index];
                          final departmentName = department['tbl_department']
                                  ['department_name'] ??
                              "Unknown";

                          // Fetch and convert department_icon safely
                          final iconString = department['tbl_department']
                              ['department_icon'] as String?;
                          final int? iconCode = iconString != null
                              ? int.tryParse(iconString)
                              : null;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorSelection(
                                    departmentId: department['tbl_department']
                                            ['department_id']
                                        .toString(),
                                    departmentName: department['tbl_department']
                                        ['department_name'],
                                  ),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: Offset(2, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  iconCode != null
                                      ? Icon(
                                          IconData(iconCode,
                                              fontFamily: 'MaterialIcons'),
                                          size: 35,
                                          color: Colors.blueGrey.shade700,
                                        )
                                      : Icon(Icons.help_outline,
                                          size: 35,
                                          color: Colors.blueGrey.shade500),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      departmentName,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
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
          ),
        ],
      ),
    );
  }
}

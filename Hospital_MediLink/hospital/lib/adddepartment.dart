import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddDepartment extends StatefulWidget {
  const AddDepartment({super.key});

  @override
  State<AddDepartment> createState() => _AddDepartmentState();
}

class _AddDepartmentState extends State<AddDepartment> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> departmentList = [];
  List<Map<String, dynamic>> hospitalDepartmentList = [];
  String? selectedDepartment;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
    fetchHospitalDepartments();
  }

  Future<void> fetchDepartments() async {
    try {
      final response = await supabase.from('tbl_department').select();
      setState(() {
        departmentList = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  Future<void> fetchHospitalDepartments() async {
    try {
      final hospitalId = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('tbl_hospitaldepartment')
          .select('*, tbl_department(*)')
          .eq("hospital_id", hospitalId);

      setState(() {
        hospitalDepartmentList = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  Future<void> addHospitalDept() async {
    try {
      final hospitalId = supabase.auth.currentUser!.id;

      final existingRecords = await supabase
          .from("tbl_hospitaldepartment")
          .select("department_id")
          .eq("department_id", selectedDepartment.toString())
          .eq("hospital_id", hospitalId);

      if (existingRecords.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Department already added!")),
        );
        return;
      }

      await supabase.from("tbl_hospitaldepartment").insert({
        'department_id': selectedDepartment,
        'hospital_id': hospitalId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Department added successfully!")),
      );
      setState(() {
        selectedDepartment = null;
      });
      fetchHospitalDepartments(); // Refresh list after adding
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add department")),
      );
    }
  }

  Future<void> deleteDepartment(int did) async {
    try {
      await supabase
          .from('tbl_hospitaldepartment')
          .delete()
          .eq('hospitaldepartment_id', did);
      fetchHospitalDepartments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted successfully')),
      );
    } catch (e) {
      print("Error Deleting: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0277BD),
        title: const Text(
          "Add Department",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter Department Details",
                  style: TextStyle(
                    color: Color(0xFF0277BD),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 100,
                  height: 3,
                  color: const Color(0xFF0277BD),
                ),
                const SizedBox(height: 30),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    hintText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedDepartment,
                  hint: const Text("Select the department"),
                  onChanged: (newValue) {
                    setState(() {
                      selectedDepartment = newValue;
                    });
                  },
                  items: departmentList.map((department) {
                    return DropdownMenuItem<String>(
                      value: department['department_id'].toString(),
                      child: Text(department['department_name']),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                Center(
                  child: ElevatedButton(
                    onPressed: addHospitalDept,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 15),
                      backgroundColor: const Color(0xFF0277BD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Back to Previous Page",
                      style: TextStyle(
                        color: Color(0xFF0277BD),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Display the list of added hospital departments
                hospitalDepartmentList.isEmpty
                    ? const Center(child: Text("No departments added yet"))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: hospitalDepartmentList.length,
                        itemBuilder: (context, index) {
                          final department = hospitalDepartmentList[index];

                          // Retrieve the department icon stored as an integer (codePoint)
                          String? iconString =
                              department['tbl_department']['department_icon'];
                          int? iconCode =
                              int.tryParse(iconString ?? "0"); // Convert to int
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: iconCode != null && iconCode > 0
                                  ? Icon(
                                      IconData(iconCode,
                                          fontFamily: 'MaterialIcons'),
                                      size: 30,
                                      color: Colors.blue,
                                    )
                                  : const Icon(Icons.help_outline,
                                      size: 30, color: Colors.blue),
                              title: Text(department['tbl_department']
                                      ['department_name'] ??
                                  "Unknown"),
                              trailing: IconButton(
                                onPressed: () {
                                  deleteDepartment(
                                      department['hospitaldepartment_id']);
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

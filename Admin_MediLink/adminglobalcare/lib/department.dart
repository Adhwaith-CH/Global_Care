import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Department extends StatefulWidget {
  const Department({super.key});

  @override
  State<Department> createState() => _DepartmentState();
}

class _DepartmentState extends State<Department> {
  final supabase = Supabase.instance.client;
  TextEditingController departmentController = TextEditingController();
  List<Map<String, dynamic>> _category = [];
  int eid = 0;
  IconData? selectedIcon;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  // Fetch departments from database
  Future<void> fetchDepartments() async {
    try {
      final response = await supabase
          .from('tbl_department')
          .select()
          .order('department_name', ascending: true);
      setState(() {
        _category = response;
      });
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  // Insert a new department
  Future<void> insertDepartment() async {
    try {
      print("Inserting");
      final existingDepartment = await supabase
          .from('tbl_department')
          .select('department_name')
          .eq('department_name', departmentController.text.toUpperCase())
          .maybeSingle();

      if (existingDepartment != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Department already exists!')),
        );
      } else {
        await supabase.from('tbl_department').insert({
          'department_name': departmentController.text.toUpperCase(),
          'department_icon': selectedIcon?.codePoint.toString(), // Store icon as string
        });
        fetchDepartments();
        departmentController.clear();
        selectedIcon = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inserted successfully')),
        );
      }
    } catch (e) {
      print('Insert error: $e');
    }
  }

  // Edit department
  Future<void> editDepartment() async {
    try {
      print("Editing");
      await supabase.from('tbl_department').update({
        'department_name': departmentController.text.toUpperCase(),
        'department_icon': selectedIcon?.codePoint.toString(), // Update icon as well
      }).eq('department_id', eid);
      fetchDepartments();
      departmentController.clear();
      setState(() {
        selectedIcon = null;
        eid=0;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated successfully')),
      );
    } catch (e) {
      print('Update error: $e');
    }
  }

  // Delete department
  Future<void> deleteDepartment(int did) async {
    try {
      await supabase.from('tbl_department').delete().eq('department_id', did);
      fetchDepartments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted successfully')),
      );
    } catch (e) {
      print("Error Deleting: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    eid = 0;
                    departmentController.clear();
                    selectedIcon = null;
                  });
                  _dialogBuilder(context);
                },
                label: Text("Add Department",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                icon: Icon(Icons.add, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Table
          DataTable(
            headingRowColor: WidgetStatePropertyAll(Colors.teal.shade100),
            columns: [
              DataColumn(label: Text('Sl.No',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800]))),
              DataColumn(label: Text('Department Name',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800]),)),
              DataColumn(label: Text('Icon',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800]),)),
              DataColumn(label: Text('Actions',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800]),)),
            ],
            
            rows: _category.asMap().entries.map((entry) {
              String department = entry.value['department_name'];
              IconData? iconData = entry.value['department_icon'] != null
                  ? IconData(int.parse(entry.value['department_icon']),
                      fontFamily: 'MaterialIcons')
                  : null;

              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            return entry.key.isEven ? Colors.white : Colors.teal.shade50;
                          },
                        ),
                cells: [
                  DataCell(Text((entry.key + 1).toString())),
                  DataCell(Text(department)),
                  DataCell(iconData != null
                      ? Icon(iconData, color: Colors.teal)
                      : Text('No Icon')),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteDepartment(entry.value['department_id']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            setState(() {
                              eid = entry.value['department_id'];
                              departmentController.text = department;
                              selectedIcon = iconData;
                            });
                            _dialogBuilder(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
  List<IconData> medicalIcons = [
    Icons.local_hospital,
    Icons.medical_services,
    Icons.health_and_safety,
    Icons.healing,
    Icons.biotech,
    Icons.bloodtype,
    Icons.coronavirus,
    Icons.sanitizer,
    Icons.vaccines,
    Icons.monitor_heart,
    Icons.local_hospital,
    Icons.healing,
    Icons.favorite,
    Icons.psychology,
    Icons.accessibility_new,
    Icons.child_care,
    Icons.pregnant_woman,
    Icons.face,
    Icons.visibility,
    Icons.hearing,
    Icons.wc,
    Icons.lunch_dining,
    Icons.water_drop,
    Icons.air,
    Icons.science,
    Icons.biotech,
    Icons.sports_handball,
    Icons.local_hospital,
    Icons.health_and_safety,
    Icons.psychology,
    Icons.face_retouching_natural,
    Icons.favorite_border,
    Icons.bloodtype,
    Icons.remove_red_eye,
    Icons.hearing,
    Icons.wc,
    Icons.pregnant_woman,
    Icons.restaurant,
    Icons.medical_services,
    Icons.local_hospital,
    Icons.spa,
    Icons.psychology,
    Icons.directions_walk,
    Icons.record_voice_over,
    Icons.lunch_dining,
    Icons.broken_image,
    Icons.science,
    Icons.local_pharmacy,
    Icons.bloodtype,
    Icons.local_hospital,
    Icons.local_taxi,
    Icons.article,
    Icons.clean_hands,
    Icons.people,
    Icons.biotech,
    Icons.science,
    Icons.emoji_nature,
    Icons.radio

  ];

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(eid == 0 ? 'Add Department' : 'Edit Department'),
            content: SizedBox(
                height: 800,
            width: 600,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: departmentController,
                      decoration: InputDecoration(labelText: 'Department Name'),
                    ),
                    SizedBox(height: 16),
                    Text("Select an Icon", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                          
                    // **Fix for GridView inside AlertDialog**
                    GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: medicalIcons.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIcon = medicalIcons[index];
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedIcon == medicalIcons[index]
                                  ? Colors.teal.withOpacity(0.3)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selectedIcon == medicalIcons[index]
                                    ? Colors.teal
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(medicalIcons[index], size: 32, color: Colors.teal),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              TextButton(
                onPressed: () async {
                  if (selectedIcon == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select an icon")),
                    );
                    return;
                  }
                  if(eid==0){
                    await insertDepartment();
                  }
                  else{
                    await editDepartment();
                  }
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

}

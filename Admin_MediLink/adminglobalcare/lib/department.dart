import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Department extends StatefulWidget {
  const Department({super.key});

  @override
  State<Department> createState() => _DepartmentState();
}

class _DepartmentState extends State<Department> {
  final supabase = Supabase.instance
      .client; //oru collection off datayee oru variableeku set cheyunuuu
  TextEditingController departmentController =
      TextEditingController(); //variable initilize cheyunuuu
  List<Map<String, dynamic>> _category = []; //database ill ninuu value edukunuu
  int id = 0;
  final _formKey = GlobalKey<FormState>();

// To manage form visibility
// Animation duration

  int eid = 0;

  @override
  void initState() {
    super.initState();
    fetchcat();
  }

//SELECT CHEYAN ULLA CODE

  Future<void> fetchcat() async {
    try {
      final response = await supabase
          .from('tbl_department')
          .select() .order('department_name', ascending: true); // Sort alphabetically
 //Tbl_category ill ninuu valuee select cheythuu edukunuu
      // Response leeku store cheyunuu
      setState(() {
        _category =
            response; //response ill ulla value _category leeku store cheyunuu
      });
    } catch (e) {
      print(
          'Exception during fetch: $e'); //Enteelum reason karanum error varuvanekil / work aavunillagil entanu error ennu print aakan veedi ullathuu annu ith
    } // Message illagilum kozhapam illa terminal ill ninuu error ulla line identify cheyan annu msg(Exception during fetch:) kodukunathuu
  }

//INSERT CHEYAN ULLA CODE

  Future<void> insertcategory() async {
  try {
    // Check if the department already exists
    final existingDepartment = await supabase
        .from('tbl_department')
        .select('department_name')
        .eq('department_name', departmentController.text.toUpperCase())
        .single(); // .single() ensures we only get one result

    if (existingDepartment != null ) {
      // Department already exists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Department already exists!')),
      );
    } else {
      // Insert the new department
      await supabase.from('tbl_department').insert({
        'department_name': departmentController.text.toUpperCase(),
      });
      fetchcat(); // Refresh the data
      departmentController.clear(); // Clear the input field

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserted successfully')),
      );
    }
  } catch (e) {
    print('Insert error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error occurred during insertion')),
    );
  }
}

  Future<void> editdepartment() async {
    try {
      await supabase.from('tbl_department').update({
        'department_name': departmentController.text.toUpperCase(),
      }).eq('department_id', eid);
      fetchcat();
      departmentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update  successfully')),
      );
    } catch (e) {
      print(' update error: $e');
    }
  }


Future<void> deletecat(int did) async {
    try {
      await supabase.from('tbl_department').delete().eq('department_id',
          did); //Tbl_category ill ninuu value dalete cheyan ulla code
      fetchcat(); ////database ill ninuu  appol thanee delete cheyunaa value remove cheyan annu ith use cheyunayhuu

      //DELETE aayi ennu message kanikkan ulla code
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Deleted  successfully')), //ALERT message kanikkanam ulla code
      );
    } catch (e) {
      print(
          "Error Deleting: $e"); //Enteelum reason karanum error varuvanekil / work aavunillagil entanu error ennu print aakan veedi ullathuu annu ith
    } // Message illagilum kozhapam illa terminal ill ninuu error ulla line identify cheyan annu msg(Exception during fetch:) kodukunathuu
  }

  @override
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(16), // Add padding inside the container
    margin: EdgeInsets.all(16),  // Add padding inside the container
    decoration: BoxDecoration(
      color: Colors.white, // Background color for the container
      borderRadius: BorderRadius.circular(16), // Rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.black26, // Subtle shadow color
          blurRadius: 8, // Blur effect for shadow
          offset: Offset(0, 4), // Vertical offset for shadow
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 1020),
              child: ElevatedButton.icon(
                onPressed: () {
                  _dialogBuilder(context);
                },
                label: Text("Add Department", style: TextStyle(fontSize: 16, color: Colors.white)),
                icon: Icon(Icons.add, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 16),

        // Fixed header with scrollable content
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.teal), // Border around table
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Fixed table header
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                color: Colors.teal.shade100, // Header background color
                child: Row(
                 // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sl.No', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                    SizedBox(width: 250),
                    Text('Department Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                    SizedBox(width: 500),
                    Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                  ],
                ),
              ),
              // Scrollable table rows
              SizedBox(
                height: 500, // Set a fixed height for scrolling
                width: double.infinity,
                child: Expanded(
                  
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: [
                        DataColumn(label: Container()), // Empty to match header
                        DataColumn(label: Container()),
                        DataColumn(label: Container()),
                      ],
                      rows: _category.asMap().entries.map((entry) {
                        String department = entry.value['department_name'] as String;
                  
                        return DataRow(
                    
                          color: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                              return entry.key.isEven ? Colors.teal.shade50 : Colors.white;
                            },
                          ),
                          cells: [
                            DataCell(Text((entry.key + 1).toString(), style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(department)),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      deletecat(entry.value['department_id']);
                                    },
                                    tooltip: 'Delete Department',
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      setState(() {
                                        eid = entry.value['department_id'];
                                        departmentController.text = entry.value['department_name'];
                                        _dialogBuilder(context);
                                      });
                                    },
                                    tooltip: 'Edit Department',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            eid == 0 ? 'Add Department' : 'Edit Department',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: departmentController,
                  validator: (value) {
                    if (value == "" || value!.isEmpty) {
                      return "Enter the department name";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Department Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.teal),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                'Add',
                style: TextStyle(color: Colors.teal),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (eid == 0) {
                    await insertcategory();
                  } else {
                    await editdepartment();
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  
}

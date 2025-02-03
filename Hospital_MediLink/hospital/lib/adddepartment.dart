import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Adddepartment extends StatefulWidget {
  const Adddepartment({super.key});

  @override
  State<Adddepartment> createState() => _AdddepartmentState();
}

class _AdddepartmentState extends State<Adddepartment> {
final _formKey = GlobalKey<FormState>();
  TextEditingController _departmentNameController = TextEditingController();
  TextEditingController _departmentDescriptionController = TextEditingController();
  TextEditingController _staffCountController = TextEditingController();

  List<Map<String, dynamic>> departmentlist = [];
   String? selectdepartment;
 final supabase = Supabase.instance.client;

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdistrict();
  }


  Future<void> fetchdistrict() async {
    try {
      final response = await supabase
          .from('tbl_department')
          .select(); //database ill ninuu district enna table ill insert cheythaa value select cheyunuu
      
      setState(() {
        departmentlist =
            response; //select cheythaa response "districtlist"leeku kodukunuu
      });
    } catch (e) {
      print('Exception during fetch:$e');
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0277BD),
        title: Text("Add Department", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
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
                // Title with an elegant line
                Text(
                  "Enter Department Details",
                  style: TextStyle(
                    color: Color(0xFF0277BD),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: 100,
                  height: 3,
                  color: Color(0xFF0277BD),
                ),
                SizedBox(height: 30),

                // Create a row layout for the first two input fields
                DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  hintText: 'Department',
                                  border: OutlineInputBorder(),
                                ),
                                 value: selectdepartment, //initilizee cheyunuu
                                hint: Text("select the department"),
                                onChanged: (newValue) {
                                  //button click cheyubool text box ill select cheythaa valuee"newValue"leeku store cheyunuu
                                  setState(() {
                                    selectdepartment =newValue; //"newValue" ill ulla value "selectedDistrict"leeku store cheyunuu
                                  });
                                },
                                items: departmentlist.map((department) {
                                  return DropdownMenuItem<String>(
                                    value: department['department_id'].toString(),
                                    child: Text(department['department_name']),
                                  );
                                }).toList(),
                              ),
                                    SizedBox(width: 15),
                SizedBox(height: 20),

                // Second row for the description field
                _buildInputField(_departmentDescriptionController, 'Description', Icons.description),
                SizedBox(height: 40),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitDepartmentDetails,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      backgroundColor: Color(0xFF0277BD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Back Button to navigate back to previous page
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Back to Previous Page",
                      style: TextStyle(
                        color: Color(0xFF0277BD),
                        fontSize: 16,
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

  // Function to submit department details
  void _submitDepartmentDetails() {
    if (_formKey.currentState?.validate() ?? false) {
      // Perform your submit logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Department Added Successfully!')),
      );
    }
  }

  // Custom Input Field Widget with elegant design
  Widget _buildInputField(
    TextEditingController controller,
    String hintText,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF0277BD)),
        hintText: hintText,
        filled: true,
        fillColor: Color(0xFFF1F1F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF0277BD), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$hintText is required';
        }
        return null;
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Adddepartment(),
  ));
}
 
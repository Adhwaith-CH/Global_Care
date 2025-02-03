import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class District extends StatefulWidget {
  const District({super.key});

  @override
  State<District> createState() => _DistrictState();
}







class _DistrictState extends State<District> {


 final supabase = Supabase.instance.client;
  TextEditingController districtcontroller = TextEditingController();

   List<Map<String, dynamic>> _district = [];

  final _formKey = GlobalKey<FormState>();


Future<void> fetchcat() async {
    try {
      final response = await supabase.from('tbl_district').select().order('district_name', ascending: true); //Tbl_category ill ninuu valuee select cheythuu edukunuu
      // Response leeku store cheyunuu
      setState(() {
        _district=response;
        
      });
    } catch (e) {
      print(
          'Exception during fetch: $e'); //Enteelum reason karanum error varuvanekil / work aavunillagil entanu error ennu print aakan veedi ullathuu annu ith
    } // Message illagilum kozhapam illa terminal ill ninuu error ulla line identify cheyan annu msg(Exception during fetch:) kodukunathuu
  }

Future<void> insertDistrict(BuildContext context) async {
  if (districtcontroller.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a district name')),
    );
    return;
  }

  try {
    final existingDistrict = await supabase
        .from('tbl_district')
        .select('district_name')
        .eq('district_name', districtcontroller.text.trim().toUpperCase())
        .maybeSingle();

    if (existingDistrict != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('District already exists!')),
      );
    } else {
      await supabase.from('tbl_district').insert({
        'district_name': districtcontroller.text.trim().toUpperCase(),
      });

      fetchcat(); // Refresh the list after insertion
      districtcontroller.clear(); // Clear input field

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserted successfully')),
      );
    }
  } catch (error) {
    print('Insert error: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${error.toString()}')),
    );
  }
}


 Future<void> deletedistrict(int did) async {
    try {
      await supabase.from('tbl_district').delete().eq('district_id', did); //tbl_district ill ninuu value dalete cheyan ulla code
      fetchcat(); ////database ill ninuu  appol thanee delete cheyunaa value remove cheyan annu ith use cheyunayhuu

      //DELETE aayi ennu message kanikkan ulla code
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted  successfully')), //ALERT message kanikkanam ulla code
      );
    } catch (e) {
      print(
          "Error Deleting: $e"); //Enteelum reason karanum error varuvanekil / work aavunillagil entanu error ennu print aakan veedi ullathuu annu ith
    } // Message illagilum kozhapam illa terminal ill ninuu error ulla line identify cheyan annu msg(Exception during fetch:) kodukunathuu
  }


Future<void> editdistrict() async {
    try {
      await supabase.from('tbl_district').update({
        'district_name': districtcontroller.text.toUpperCase(),
      }).eq('district_id', eid);
      fetchcat();
      districtcontroller.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update  successfully')),
      );
    } catch (e) {
      print(' update error: $e');
    }
  }



  int eid=0;






  @override
  void initState() {
    super.initState();
    fetchcat();
  }
  @override
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(16), // Add padding inside the container
    margin: EdgeInsets.all(16), // Add padding inside the container
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
                label: Text("Add District", style: TextStyle(fontSize: 16, color: Colors.white)),
                icon: Icon(Icons.add, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16), // Spacing between button and table

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
                  children: [
                    Text('Sl.No', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                    SizedBox(width: 320),
                    Text('District Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                    SizedBox(width: 400),
                    Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                  ],
                ),
              ),
              // Scrollable table rows
              SizedBox(
                height: 500, // Set a fixed height for scrolling
                width: double.infinity,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns:  [
                      DataColumn(label: Container()), // Empty to match header
                      DataColumn(label: Container()),
                      DataColumn(label: Container()),
                    ],
                    rows: _district.asMap().entries.map((entry) {
                      String districtname = entry.value['district_name'] as String;

                      return DataRow(
                        color: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            return entry.key.isEven ? Colors.teal.shade50 : Colors.white;
                          },
                        ),
                        cells: [
                          DataCell(Text((entry.key + 1).toString(), style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(districtname)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    deletedistrict(entry.value['district_id']);
                                  },
                                  tooltip: 'Delete District',
                                ),
                                SizedBox(width: 8), // Spacing between buttons
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      eid = entry.value['district_id'];
                                      districtcontroller.text = entry.value['district_name'];
                                      _dialogBuilder(context);
                                    });
                                  },
                                  tooltip: 'Edit District',
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
          title:  Text(
            eid == 0 ? 'Add District' : 'Edit District',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content:Form(
            key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: districtcontroller,
                  validator: (value) {
                    if (value == "" || value!.isEmpty) {
                      return "Enter the district name";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "District Name",
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
      ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Add'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (eid == 0) {
                    await insertDistrict(context);
                  } else {
                    await editdistrict();
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
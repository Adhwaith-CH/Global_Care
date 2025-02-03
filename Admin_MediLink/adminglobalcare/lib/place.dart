import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Place extends StatefulWidget {
  const Place({super.key});

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  final supabase = Supabase.instance.client;
  String? selectedDistrict;

  TextEditingController place_name = TextEditingController();

  List<Map<String, dynamic>> districtlist = [];
  List<Map<String, dynamic>> placelist = [];

final _formKey = GlobalKey<FormState>();
  int eid = 0;

  @override
  void initState() {
    super.initState();
    fetchdistrict();
    fetchplace();
  
  }

  Future<void> fetchdistrict() async {
    try {
      final response = await supabase
          .from('tbl_district')
          .select(); //database ill ninuu district enna table ill insert cheythaa value select cheyunuu
      setState(() {
        districtlist =
            response; //select cheythaa response "districtlist"leeku kodukunuu
      });
    } catch (e) {
      print('Exception during fetch:$e');
    }
  }

  Future<void> fetchplace() async {
    try {
      final response = await supabase.from('tbl_place').select(
          '*,tbl_district(*)'); //database ill ninuu district enna table ill insert cheythaa value select cheyunuu
      // print(response);
      // ellam select cheyan  annu * use cheyunathuu,
      //tbl_place ill foreign key varunud ath ethuu table ill ninuu annun ennum kodukanum athinanuu "tbl_district(*)" ith kodukunathuu
      //(*) enganee koduthaal ellam select aakum,('place_id','place_name');- enganeem kodukkamm
      setState(() {
        placelist =
            response; //select cheythaa response "districtlist"leeku kodukunuu
      });
      fetchplace();
    } catch (e) {
      print('Exception during fetch:$e');
    }
  }

  Future<void> insertPlace(BuildContext context) async {
  if (place_name.text.trim().isEmpty || selectedDistrict == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a place and select a district')),
    );
    return;
  }

  try {
    // Check if the place already exists in the selected district
    final existingPlace = await supabase
        .from('tbl_place')
        .select('place_name')
        .eq('place_name', place_name.text.trim().toUpperCase())
        .eq('district_id', selectedDistrict!)
        .maybeSingle(); // Use maybeSingle to avoid exceptions

    if (existingPlace != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Place already exists in this district!')),
      );
    } else {
      // Insert the new place
      await supabase.from('tbl_place').insert({
        'place_name': place_name.text.trim().toUpperCase(),
        'district_id': selectedDistrict,
      });

      // Clear fields after successful insertion
      place_name.clear();
      selectedDistrict = null;

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


  Future<void> deleteplace(int did) async {
    try {
      await supabase.from('tbl_place').delete().eq('place_id',
          did); //Tbl_category ill ninuu value dalete cheyan ulla code
      fetchplace(); ////database ill ninuu  appol thanee delete cheyunaa value remove cheyan annu ith use cheyunayhuu

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

  Future<void> editplace(int eid) async {
    try {
      await supabase.from('tbl_place').update({
        'place_name': place_name.text.toUpperCase(),
        'district_id': selectedDistrict
      }).eq('place_id', eid);
      fetchplace();
      place_name.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update  successfully')),
      );
    } catch (e) {
      print(' update error: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(16), // Padding inside the container
    margin: EdgeInsets.all(16), // Margin around the container
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
        // Add Place Button (Styled similarly to Add Department button)
        Row(
          mainAxisAlignment: MainAxisAlignment.end, // Align button to the right
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _dialogBuilder(context); // Open dialog for adding place
              },
              label: Text("Add Place", style: TextStyle(fontSize: 16, color: Colors.white)),
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
                    SizedBox(width: 220),
                    Text('Place Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                    SizedBox(width: 260),
                    Text('District Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                    SizedBox(width: 250),
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
                      DataColumn(label: Container()),
                    ],
                    rows: placelist.asMap().entries.map((entry) {
                      String placename = entry.value['place_name'] as String;
                      String districtname = entry.value['tbl_district']['district_name'] as String;

                      return DataRow(
                        color: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            return entry.key.isEven ? Colors.teal.shade50 : Colors.white; // Alternate row color
                          },
                        ),
                        cells: [
                          DataCell(Text((entry.key + 1).toString(), style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(placename)),
                          DataCell(Text(districtname)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    deleteplace(entry.value['place_id']);
                                  },
                                  tooltip: 'Delete Place',
                                ),
                                SizedBox(width: 8), // Spacing between buttons
                                // Edit Button
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      eid = entry.value['place_id'];
                                      place_name.text = entry.value['place_name'];
                                      selectedDistrict = entry.value['district_id'].toString();
                                      _dialogBuilder(context);
                                    });
                                  },
                                  tooltip: 'Edit Place',
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


  @override
  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(
            eid == 0 ? 'Add Place' : 'Edit Place',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: _formKey,
          
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                            children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    hintText: 'District',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedDistrict, //initilizee cheyunuu
                  validator: (value) {
                    if (value == "" || value!.isEmpty) {
                      return "Enter the district name";
                    }
                    return null;
                  },
                  hint: Text("select the district"),
                  onChanged: (newValue) {
                    //button click cheyubool text box ill select cheythaa valuee"newValue"leeku store cheyunuu
                    setState(() {
                      selectedDistrict =
                          newValue; //"newValue" ill ulla value "selectedDistrict"leeku store cheyunuu
                    });
                  },
                  items: districtlist.map((district) {
                    return DropdownMenuItem<String>(
                      value: district['district_id'].toString(),
                      child: Text(district['district_name']),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20,),

                
                TextFormField(
                  controller: place_name,
                  validator: (value) {
                    if (value == "" || value!.isEmpty) {
                      return "Enter the Place name";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter the place",
                    border: OutlineInputBorder(),
                  ),
                ),
                            ],
                          ),
              )),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                eid=0;
                place_name.clear();
                selectedDistrict=null;
                });
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
                    await insertPlace(context);
                  } else {
                    await editplace(eid);
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

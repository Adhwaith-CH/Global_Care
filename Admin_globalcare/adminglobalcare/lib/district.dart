import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class District extends StatefulWidget {
  const District({super.key});

  @override
  State<District> createState() => _DistrictState();
}







class _DistrictState extends State<District> {


 final supabase = Supabase.instance.client;
  TextEditingController district_name = TextEditingController();

   List<Map<String, dynamic>> _district = [];




Future<void> fetchcat() async {
    try {
      final response = await supabase.from('tbl_district').select(); //Tbl_category ill ninuu valuee select cheythuu edukunuu
      // Response leeku store cheyunuu
      setState(() {
        _district=response;
        
      });
    } catch (e) {
      print(
          'Exception during fetch: $e'); //Enteelum reason karanum error varuvanekil / work aavunillagil entanu error ennu print aakan veedi ullathuu annu ith
    } // Message illagilum kozhapam illa terminal ill ninuu error ulla line identify cheyan annu msg(Exception during fetch:) kodukunathuu
  }

Future<void> insertdistrict() async {
    try {
      await supabase.from('tbl_district').insert({
        'district_name': district_name.text,
      });
      fetchcat();
      district_name.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserted  successfully')),
      );
    } catch (e) {
      print(' insert error: $e');
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


Future<void> editdistrict(int eid) async {
    try {
      await supabase.from('tbl_district').update({
        'district_name': district_name.text,
      }).eq('district_id', eid);
      fetchcat();
      district_name.clear();

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
  Widget build(BuildContext context) {
    return  Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("District"),
              ElevatedButton.icon(onPressed: (){
                _dialogBuilder(context);
              }, label: Text("Add District"), icon: Icon(Icons.add),)
            ],
          ),
           DataTable(
                      columns: const [
                        DataColumn(label: Text('Sl.No')),
                        DataColumn(label: Text('District Name')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _district.asMap().entries.map((entry) {
                        // int district_id = entry.value['id'];
                       print(entry);
                        String districtname =
                            entry.value['district_name'] as String;
                            // print(entry.value['did']);
    
                        return DataRow(cells: [
                          DataCell(Text((entry.key + 1).toString())),
                          DataCell(Text(districtname)),
                          DataCell(
                            Row(
                              children: [
                                // Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed:() {
                                    deletedistrict(entry.value['district_id']);
                                  },
                                ),
                                // Edit Button (optional)
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                   setState(() {
                                    eid=entry.value['district_id'];
                                    district_name.text=entry.value['district_name'];
                                  _dialogBuilder(context);
                                     
                                   });

                                  
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
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
          title: const Text('Add District'),
          content:Form(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [
            TextFormField(
              controller: district_name,
              decoration: InputDecoration(
                  hintText: "Enter District Name",
                  border: OutlineInputBorder()),
            ),
          ]),
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
                if(eid==null)
                {

                await insertdistrict();
                Navigator.of(context).pop();
                }
                else
                {
                  await editdistrict(eid);
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
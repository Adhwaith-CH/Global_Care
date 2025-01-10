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

  int eid=0;


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
      final response = await supabase.from('tbl_place').select('*,tbl_district(*)'); //database ill ninuu district enna table ill insert cheythaa value select cheyunuu
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

  Future<void> insertplace() async {
    try {
      await supabase.from('tbl_place').insert({
        //tbl_place leeku value insert cheyan ulla query
        'place_name': place_name.text,
        'district_id':
            selectedDistrict, //'place_name'ill ninuu type cheyunaa valuee edukunuu
      });

      //database leeku appol thanee enter cheyunaa value add cheyan annu ith use cheyunayhuu,name ent veenelum kodukkam
      place_name
          .clear(); //refresh cheyubool textfield clear aayi varran annuu ith use cheyunathu
      selectedDistrict = null;
      //INSERT aayi ennu message kanikkan ulla code
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserted  successfully')),
      );
    } catch (e) {
      print(
          ' insert error: $e'); //Enteelum reason karanum error varuvanekil / work aavunillagil entanu error ennu print aakan veedi ullathuu annu ith
    } //Message illagilum kozhapam illa terminal ill ninuu error ulla line identify cheyan annu msg(Exception during fetch:) kodukunathuu
  }

  Future<void> deleteplace(int did) async {
    try {
      await supabase
          .from('tbl_place')
          .delete()
          .eq('place_id', did); //Tbl_category ill ninuu value dalete cheyan ulla code
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
        'place_name': place_name.text,
        'district_id':selectedDistrict
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










  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Place"),
              ElevatedButton.icon(
                onPressed: () {
                  _dialogBuilder(context);
                },
                label: Text("Add Place"),
                icon: Icon(Icons.add),
              )
            ],
          ),
          DataTable(
            columns: const [
              DataColumn(label: Text('Sl.No')),
              DataColumn(label: Text('Place Name')),
              DataColumn(label: Text('District id')),
              DataColumn(label: Text('Actions')),
            ],
            rows: placelist.asMap().entries.map((entry) {
              
              String placename = entry.value['place_name'] as String;
              String district_name = entry.value['tbl_district']['district_name'] as String;
              return DataRow(cells: [
                DataCell(Text((entry.key + 1).toString())),
                DataCell(Text(placename)),
                DataCell(Text(district_name)),
                DataCell(
                  Row(
                    children: [
                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:() {
                           deleteplace(entry.value['place_id']);
                         },
                      ),
                      // Edit Button (optional)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                                    eid=entry.value['place_id'];
                                    place_name.text=entry.value['place_name'];
                                    selectedDistrict=entry.value['district_id'].toString();
                                  _dialogBuilder(context);
                                   }
                          );
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

  @override
  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add District'),
          content: Form(
              child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: 'District',
                  border: OutlineInputBorder(),
                ),
                value: selectedDistrict, //initilizee cheyunuu
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
              TextFormField(
                controller: place_name,
                decoration: InputDecoration(
                  hintText: "Enter the place",
                  border: OutlineInputBorder(),
                ),
              ),
              
            ],
          )),
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

                await insertplace();
                Navigator.of(context).pop();
                }
                else
                {
                  await editplace(eid);
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




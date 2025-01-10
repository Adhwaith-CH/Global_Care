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
  TextEditingController category_name =
      TextEditingController(); //variable initilize cheyunuuu
  TextEditingController _deptNameController = TextEditingController();
  List<Map<String, dynamic>> _category = []; //database ill ninuu value edukunuu
  int id = 0;
  String? _addDept;
  final _formKey = GlobalKey<FormState>();

  bool _isFormVisible = false; // To manage form visibility
  final Duration _animationDuration =
      const Duration(milliseconds: 300); // Animation duration


    int eid=0;


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
          .select(); //Tbl_category ill ninuu valuee select cheythuu edukunuu
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
      await supabase.from('tbl_department').insert({
        //tbl_category leeku value insert cheyan ulla query
        'department_name': category_name
            .text, //'category_name'ill ninuu type cheyunaa valuee edukunuu
      });
      fetchcat(); //database leeku appol thanee enter cheyunaa value add cheyan annu ith use cheyunayhuu
      category_name
          .clear(); //refresh cheyubool textfield clear aayi varran annuu ith use cheyunathu

      //INSERT aayi ennu message kanikkan ulla code
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserted  successfully')),
      );
    } catch (e) {
      print(
          ' insert error: $e'); //Enteelum reason karanum error varuvanekil / work aavunillagil entanu error ennu print aakan veedi ullathuu annu ith
    } //Message illagilum kozhapam illa terminal ill ninuu error ulla line identify cheyan annu msg(Exception during fetch:) kodukunathuu
  }



Future<void> editdepartment() async {
    try {
      await supabase.from('tbl_department').update({
        'department_name': category_name.text,
      }).eq('department_id', eid);
      fetchcat();
      category_name.clear();

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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Manage Departemnt"),
              ElevatedButton.icon(onPressed: (){
                _dialogBuilder(context);
              }, label: Text("Add Department"), icon: Icon(Icons.add),)
            ],
          ),
           DataTable(
                      columns: const [
                        DataColumn(label: Text('Sl.No')),
                        DataColumn(label: Text('Department Name')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _category.asMap().entries.map((entry) {
                        // String courseId = entry.value['id'];
                        String department =
                            entry.value['department_name'] as String;

                        return DataRow(cells: [
                          DataCell(Text((entry.key + 1).toString())),
                          DataCell(Text(department)),
                          DataCell(
                            Row(
                              children: [
                                // Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed:() {
                                    deletecat(entry.value['department_id']);
                                  },
                                ),
                                // Edit Button (optional)
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                   setState(() {
                                    eid=entry.value['department_id'];
                                    category_name.text=entry.value['department_name'];
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

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Basic dialog title'),
          content:Form(child: TextFormField(
            controller: category_name,
            decoration: InputDecoration(hintText: "Department Name"),
          )),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Disable'),
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

                await insertcategory();
                Navigator.of(context).pop();
                }
                else
                {
                  await editdepartment();
                   Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  

  Future<void> deletecat(int did) async {
    try {
      await supabase
          .from('tbl_department')
          .delete()
          .eq('department_id', did); //Tbl_category ill ninuu value dalete cheyan ulla code
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
}

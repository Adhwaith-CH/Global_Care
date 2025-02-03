import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Hospitallist extends StatefulWidget {
  const Hospitallist({super.key});

  @override
  State<Hospitallist> createState() => _HospitallistState();
}

class _HospitallistState extends State<Hospitallist> {
  final supabase = Supabase.instance
      .client; //oru collection off datayee oru variableeku set cheyunuuu
  TextEditingController hospitalController =
      TextEditingController(); //variable initilize cheyunuuu
  List<Map<String, dynamic>> _hospital = []; //database ill ninuu value edukunuu
  int id = 0;
  final _formKey = GlobalKey<FormState>();

  int eid = 0;

  @override
  void initState() {
    super.initState();
    fetchhospital();
  }
  //SELECT CHEYAN ULLA CODE

  Future<void> fetchhospital() async {
    try {
      final response = await supabase
          .from('tbl_hospital')
          .select(); //Tbl_category ill ninuu valuee select cheythuu edukunuu
      // Response leeku store cheyunuu
      setState(() {
        _hospital =
            response; //response ill ulla value _category leeku store cheyunuu
      });
    } catch (e) {
      print(
          'Exception during fetch: $e'); //Enteelum reason karanum error varuvanekil / work aavunillagil entanu error ennu print aakan veedi ullathuu annu ith
    } // Message illagilum kozhapam illa terminal ill ninuu error ulla line identify cheyan annu msg(Exception during fetch:) kodukunathuu
  }

  Future<void> verifyhospital(String did) async {
    try {
      await supabase.from('tbl_hospital').update({'hospital_status': 1}).eq(
          'hospital_id',
          did); //Tbl_category ill ninuu value dalete cheyan ulla code
      fetchhospital(); ////database ill ninuu  appol thanee delete cheyunaa value remove cheyan annu ith use cheyunayhuu

      //DELETE aayi ennu message kanikkan ulla code
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'verified  successfully')), //ALERT message kanikkanam ulla code
      );
    } catch (e) {
      print(
          "Error Deleting: $e"); //Enteelum reason karanum error varuvanekil / work aavunillagil entanu error ennu print aakan veedi ullathuu annu ith
    } // Message illagilum kozhapam illa terminal ill ninuu error ulla line identify cheyan annu msg(Exception during fetch:) kodukunathuu
  }

   Future<void> closehospital(String did) async {
    try {
      await supabase.from('tbl_hospital').update({'hospital_status': 2}).eq(
          'hospital_id',
          did); //Tbl_category ill ninuu value dalete cheyan ulla code
      fetchhospital(); ////database ill ninuu  appol thanee delete cheyunaa value remove cheyan annu ith use cheyunayhuu

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
          // Add Hospital Button (Styled similarly to Add Department button)
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end, // Align button to the right
            children: [
             
            ],
          ),
          SizedBox(height: 16), // Spacing between button and table

          // DataTable for Hospitals
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
                      Text('Sl.No',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800])),
                      SizedBox(width: 110),
                      Text('Hospital Name',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800])),
                      SizedBox(width: 110),
                      Text('Hospital Email',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800])),
                      SizedBox(width: 150),
                      Text('Hospital Contact',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800])),
                      SizedBox(width: 140),
                      Text('Status',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800])),
                      SizedBox(width: 150),
                      Text('Actions',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800])),
                    ],
                  ),
                ),
                // Scrollable table rows
                SizedBox(
                  height: 500, // Set a fixed height for scrolling
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: [
                        DataColumn(label: Container()), // Empty to match header
                        DataColumn(label: Container()),
                        DataColumn(label: Container()),
                        DataColumn(label: Container()),
                        DataColumn(label: Container()),
                        DataColumn(label: Container()),
                      ],
                      rows: _hospital.asMap().entries.map((entry) {
                        String hospital =
                            entry.value['hospital_name'] as String;
                        String email =
                            entry.value['hospital_email']?.toString() ?? 'N/A';
                        String contact =
                            entry.value['hospital_contact']?.toString() ??
                                'N/A';
                        int status = int.tryParse(
                                entry.value['hospital_status']?.toString() ??
                                    '0') ??
                            0;

                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              return entry.key.isEven
                                  ? Colors.teal.shade50
                                  : Colors.white;
                            },
                          ),
                          cells: [
                            DataCell(Text((entry.key + 1).toString(),
                                style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(hospital)),
                            DataCell(Text(email)),
                            DataCell(Text(contact)),
                            DataCell(
                              Text(
                                status == 0
                                    ? 'Pending'
                                    : status == 1
                                        ? 'Active Account'
                                        : status == 2
                                            ? 'Closed Account'
                                            : 'Unknown Status', // Fallback for unexpected values
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: status == 0
                                      ? Colors.orange
                                      : status == 1
                                          ? Colors.green
                                          : status == 2
                                              ? Colors.red
                                              : Colors.grey, // Fallback color
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () {
                                      closehospital(
                                          entry.value['hospital_id']);
                                    },
                                    tooltip: 'Deactive Hospital',
                                  ),
                                  SizedBox(width: 8), // Spacing between buttons
                                  IconButton(
                                    icon: const Icon(Icons.done,
                                        color: Color.fromARGB(255, 3, 137, 28)),
                                    onPressed: () {
                                      verifyhospital(
                                          entry.value['hospital_id']);
                                    },
                                    tooltip: 'Activate Hospital ',
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

  
}

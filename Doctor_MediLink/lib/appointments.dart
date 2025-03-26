import 'package:flutter/material.dart';
import 'package:loginpage/main.dart';
import 'package:loginpage/sumarry.dart';

class TodayAppointmentsPage extends StatefulWidget {
  @override
  State<TodayAppointmentsPage> createState() => _TodayAppointmentsPageState();
}

class _TodayAppointmentsPageState extends State<TodayAppointmentsPage> {
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchappointments();
  }

  Future<void> fetchappointments() async {
    try {
      final response =
          await supabase.from('tbl_appointment').select('*, tbl_user(*)').eq('appointment_status', 0);
      print(response);
      setState(() {
        appointments = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Appointments"),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        elevation: 5,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final patient = appointments[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[200], // Optional light background
                backgroundImage:
                    (patient["tbl_user"]['user_photo']?.isNotEmpty ?? false)
                        ? NetworkImage(patient["tbl_user"]['user_photo']!)
                        : null,
                child: (patient["tbl_user"]['user_photo']?.isNotEmpty ?? false)
                    ? null
                    : const Icon(Icons.person, size: 30, color: Colors.grey),
              ),
              title: Text(patient["tbl_user"]["user_name"] ?? "Unknown",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text("Global ID: ${patient["tbl_user"]["user_gid"]}",
                  style: TextStyle(color: Colors.grey[700])),
              trailing: ElevatedButton(
                onPressed: () {
                  _startConsulting(
                      context, patient["tbl_user"]["user_name"]!, patient["tbl_user"]["user_gid"]!,patient['appointment_id'],patient["tbl_user"]["user_photo"]);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 25, 83, 112),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Start",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _startConsulting(
      BuildContext context, String patientName, String globalId, int appId, String image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Start Consultation"),
        content:
            Text("Are you sure you want to start consulting $patientName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Color.fromARGB(255, 25, 83, 112)),),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog first
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConsultationSummaryPage(
                    image: image,
                    appId: appId,
                    patientName: patientName,
                    globalId: globalId,
                  ),
                ),
              );
            },
            child: Text("Start", style: TextStyle(color: Color.fromARGB(255, 25, 83, 112)),),
          ),
        ],
      ),
    );
  }
}

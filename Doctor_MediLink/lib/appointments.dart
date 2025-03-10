import 'package:flutter/material.dart';
import 'package:loginpage/sumarry.dart';

class TodayAppointmentsPage extends StatefulWidget {
  @override
  State<TodayAppointmentsPage> createState() => _TodayAppointmentsPageState();
}

class _TodayAppointmentsPageState extends State<TodayAppointmentsPage> {
  final List<Map<String, String>> appointments = [
    {"name": "John Doe", "globalId": "MEDI123456"},
    {"name": "Jane Smith", "globalId": "MEDI654321"},
    {"name": "Michael Johnson", "globalId": "MEDI987654"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Appointments"),
        backgroundColor: Color.fromARGB(255, 37, 99, 160),
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
  leading: Icon(Icons.person, color: Color.fromARGB(255, 37, 99, 160)),
  title: Text(patient["name"] ?? "Unknown",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  subtitle: Text("Global ID: ${patient["globalId"]}",
      style: TextStyle(color: Colors.grey[700])),
  trailing: ElevatedButton(
    onPressed: () {
      _startConsulting(context, patient["name"]!, patient["globalId"]!);
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 37, 99, 160),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: Text("Start",style: TextStyle(color: Colors.white),),
  ),
),

          );
        },
      ),
    );
  }

  void _startConsulting(BuildContext context, String patientName, String globalId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Start Consultation"),
      content: Text("Are you sure you want to start consulting $patientName?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog first
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConsultationSummaryPage(
                  patientName: patientName,
                  globalId: globalId,
                ),
              ),
            );
          },
          child: Text("Start"),
        ),
      ],
    ),
  );
}
}
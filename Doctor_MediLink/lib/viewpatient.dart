import 'package:flutter/material.dart';

class ConsultedPatientsListPage extends StatefulWidget {
  @override
  State<ConsultedPatientsListPage> createState() => _ConsultedPatientsListPageState();
}

class _ConsultedPatientsListPageState extends State<ConsultedPatientsListPage> {
  final List<Map<String, String>> patients = [
    {"name": "John Doe", "globalId": "MEDI123456", "date": "2025-03-08"},
    {"name": "Jane Smith", "globalId": "MEDI654321", "date": "2025-03-07"},
    {"name": "Michael Johnson", "globalId": "MEDI987654", "date": "2025-03-06"},
    {"name": "Emily Brown", "globalId": "MEDI567890", "date": "2025-03-05"},
  ];

  @override
  Widget build(BuildContext context) {
    // Sort patients by date (latest first)
    patients.sort((a, b) => b["date"]!.compareTo(a["date"]!));

    return Scaffold(
      appBar: AppBar(
        title: Text("Consulted Patients"),
        backgroundColor: Color.fromARGB(255, 37, 99, 160),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Patient Info Section
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 37, 99, 160),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient["name"]!,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Global ID: ${patient["globalId"]}",
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            Text(
                              "Date: ${patient["date"]}",
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Summary Button
                    ElevatedButton(
                      onPressed: () {
                        _viewSummary(context, patient["name"]!, patient["globalId"]!, patient["date"]!);
                      },
                      child: Text("Summary",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 37, 99, 160),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Function to Navigate to Summary Page
  void _viewSummary(BuildContext context, String name, String globalId, String date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientSummaryPage(name: name, globalId: globalId, date: date),
      ),
    );
  }
}

// Summary Page (To be Connected with DB in Future)
class PatientSummaryPage extends StatelessWidget {
  final String name;
  final String globalId;
  final String date;

  PatientSummaryPage({required this.name, required this.globalId, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consultation Summary"),
        backgroundColor: Color.fromARGB(255, 37, 99, 160),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info
            Text(
              "Patient: $name",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("Global ID: $globalId"),
            const SizedBox(height: 10),
            Text("Consultation Date: $date", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            
            const SizedBox(height: 20),

            // Summary Section
            Text(
              "Consultation Summary:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Detailed summary will be fetched from database...",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),

            const SizedBox(height: 30),

            // Button to Go Back
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Back to List",style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 37, 99, 160),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

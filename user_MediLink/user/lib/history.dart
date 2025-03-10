import 'package:flutter/material.dart';

class PatientHealthHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Patient Health History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 247, 243, 243), const Color.fromARGB(255, 218, 228, 238)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildPatientInfo(),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildSection(
                        'Medical History', _buildMedicalHistoryList()),
                    _buildSection(
                        'Previous Appointments', _buildAppointmentList()),
                    _buildSection('Health Reports', _buildReportList()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 50,
          backgroundColor: Color.fromARGB(255, 15, 67, 94),
          child: Icon(
            Icons.person,
            size: 50,
            color: Colors.white,
          ),
        ),
        title: Text(
          'John Doe',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Age: 32 | ID: #12345'),
        trailing: Icon(Icons.info_outline, color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        children: [Padding(padding: EdgeInsets.all(12), child: content)],
      ),
    );
  }

  Widget _buildMedicalHistoryList() {
    List<String> conditions = ['Diabetes', 'Hypertension', 'Asthma'];
    return Column(
      children:
          conditions.map((condition) => _buildListTile(condition)).toList(),
    );
  }

  Widget _buildAppointmentList() {
    List<Map<String, String>> appointments = [
      {'date': '2025-02-20', 'doctor': 'Dr. Smith', 'diagnosis': 'Flu'},
      {'date': '2025-01-15', 'doctor': 'Dr. Brown', 'diagnosis': 'Migraine'},
    ];
    return Column(
      children: appointments
          .map((appt) => _buildListTile(
              '${appt['date']} - ${appt['doctor']} - ${appt['diagnosis']}'))
          .toList(),
    );
  }

  Widget _buildReportList() {
    List<String> reports = ['Blood Test - Jan 2025', 'X-ray - Dec 2024'];
    return Column(
      children: reports.map((report) => _buildListTile(report)).toList(),
    );
  }

  Widget _buildListTile(String text) {
    return ListTile(
      title: Text(text),
      trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
    );
  }
}

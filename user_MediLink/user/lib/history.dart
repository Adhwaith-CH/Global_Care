import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user/main.dart';
import 'package:user/pdfviewer.dart';

class PatientHealthHistoryPage extends StatefulWidget {
  @override
  State<PatientHealthHistoryPage> createState() =>
      _PatientHealthHistoryPageState();
}

class _PatientHealthHistoryPageState extends State<PatientHealthHistoryPage> {
  List<Map<String, dynamic>> historyList = [];

  @override
  void initState() {
    super.initState();
    fetchhistory();
  }

  Future<void> fetchhistory() async {
    try {
      final response = await supabase.from('tbl_summary').select(
          '*, tbl_appointment(*, tbl_availability(*, tbl_doctor(*, tbl_hospitaldepartment(*, tbl_department(*)))))');

      debugPrint('Fetched History Data: ${response.toString()}'); // Debugging

      setState(() {
        historyList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching history: ${e.toString()}');
    }
  }

  void _viewDocument(String fileUrl) async {
    if (fileUrl.isEmpty || !fileUrl.startsWith('http')) {
      debugPrint('⚠️ Invalid File URL: $fileUrl');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid file URL'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint('📂 Attempting to open: $fileUrl'); // Debugging log

    Uri uri = Uri.parse(fileUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.externalApplication); // Opens in external browser
    } else {
      debugPrint('❌ Could not open file: $fileUrl');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
            colors: [
              const Color.fromARGB(255, 247, 243, 243),
              const Color.fromARGB(255, 218, 228, 238)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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

  /// ✅ Modified `_buildMedicalHistoryList()` to display `summary_title` & expand to show `summary_description`
  Widget _buildMedicalHistoryList() {
    if (historyList.isEmpty) {
      return Center(child: Text("No medical history available"));
    }

    return Column(
      children: historyList.map((history) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ExpansionTile(
            title: Text(
              history['summary_title'] ?? 'No Title',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  history['summary_description'] ?? 'No Description Available',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppointmentList() {
    return Column(
      children: historyList.map((appt) {
        return ListTile(
          title: Text(
              '${appt['tbl_appointment']['appointment_date']} - ${appt['tbl_appointment']['tbl_availability']['tbl_doctor']['doctor_name']} - ${appt['tbl_appointment']['tbl_availability']['tbl_doctor']['tbl_hospitaldepartment']['tbl_department']['department_name']}'),
          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        );
      }).toList(),
    );
  }

  Widget _buildReportList() {
    return Column(
      children: historyList.map((report) {
        List<String> documentUrls = [];

        if (report['summary_document'] is String) {
          try {
            String rawData = report['summary_document'].trim();

            // ✅ Remove { } if it's wrapped in them
            if (rawData.startsWith('{') && rawData.endsWith('}')) {
              rawData = rawData.substring(1, rawData.length - 1);
            }

            // ✅ Extract URLs properly
            List<String> extractedUrls = rawData
                .replaceAll('"', '') // Remove quotes
                .split(',')
                .map((e) => e.trim()) // Trim spaces
                .where((e) => e.startsWith('http')) // Keep only valid URLs
                .toList();

            documentUrls = extractedUrls;
          } catch (e) {
            debugPrint('❌ Error parsing summary_document: $e');
          }
        } else if (report['summary_document'] is List) {
          documentUrls = List<String>.from(report['summary_document']);
        }

        debugPrint("✅ Extracted File URLs: $documentUrls"); // Debugging

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text(
                '${report['summary_file'] ?? 'Unknown File'} - ${report['tbl_appointment']['appointment_date'] ?? 'No Date'}'),
            trailing: documentUrls.isNotEmpty
                ? PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (String url) {
                      showReport(url, context);
                    },
                    itemBuilder: (BuildContext context) {
                      return documentUrls.map((String url) {
                        return PopupMenuItem<String>(
                          value: url,
                          child: Row(
                            children: [
                              Icon(Icons.visibility, color: Colors.blue),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  Uri.decodeComponent(url
                                      .split('/')
                                      .last), // ✅ Decode for readable names
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                  )
                : null, // Hide menu if no documents
          ),
        );
      }).toList(),
    );
  }

 void showReport(String fileUrl, BuildContext context) {
  if (fileUrl.toLowerCase().endsWith('.pdf')) {
    // ✅ Open PDF in a new screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PdfViewerPage(pdfUrl: fileUrl)),
    );
  } else {
    // ✅ Show Image in a Dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Image.network(
              fileUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    "⚠️ Could not load image",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}


}

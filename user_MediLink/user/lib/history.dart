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
  List<Map<String, dynamic>> filteredHistoryList = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    fetchhistory();
    searchController.addListener(() {
      _filterHistory(searchController.text);
    });
  }

  void showReport(String fileUrl, BuildContext context) {
    if (fileUrl.toLowerCase().endsWith('.pdf')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PdfViewerPage(pdfUrl: fileUrl)),
      );
    } else {
      _showImageDialog(context, fileUrl);
    }
  }

  Future<void> fetchhistory() async {
  try {
    setState(() {
      isLoading = true;
    });

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    // Fetch summary details with appointment and department data for the current user
    final response = await supabase
        .from('tbl_summary')
        .select(
            'summary_title, summary_description, summary_documents, tbl_appointment!inner(user_id, appointment_date, tbl_availability(tbl_doctor(*, tbl_hospitaldepartment(tbl_department(department_name), tbl_hospital(hospital_name)))))')
        .eq('tbl_appointment.user_id', userId);

    debugPrint('Fetched Summary Data: ${response.toString()}');

    setState(() {
      historyList = List<Map<String, dynamic>>.from(response);
      filteredHistoryList = historyList;
      isLoading = false;
    });
  } catch (e) {
    debugPrint('Error fetching summary: ${e.toString()}');
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error fetching summary: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  void _filterHistory(String query) {
    setState(() {
      filteredHistoryList = historyList.where((history) {
        final title = (history['summary_title'] ?? '').toLowerCase();
        final description =
            (history['summary_description'] ?? '').toLowerCase();
        final doctorName = (history['tbl_appointment']?['tbl_availability']
                    ?['tbl_doctor']?['doctor_name'] ??
                '')
            .toLowerCase();
        final departmentName = (history['tbl_appointment']?['tbl_availability']
                        ?['tbl_doctor']?['tbl_hospitaldepartment']
                    ?['tbl_department']?['department_name'] ??
                '')
            .toLowerCase();
        final appointmentDate =
            (history['tbl_appointment']?['appointment_date'] ?? '')
                .toLowerCase();

        final searchLower = query.toLowerCase();

        return title.contains(searchLower) ||
            description.contains(searchLower) ||
            doctorName.contains(searchLower) ||
            departmentName.contains(searchLower) ||
            appointmentDate.contains(searchLower);
      }).toList();
    });
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
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search by title, doctor, department...",
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildSection(
                        'Medical History', _buildMedicalHistoryList()),
                    _buildSection(
                        'Previous Appointments', _buildAppointmentList()),
                    
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

  Widget _buildMedicalHistoryList() {
    if (filteredHistoryList.isEmpty) {
      return Center(child: Text("No medical history available"));
    }

    return Column(
      children: filteredHistoryList.map((history) {
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ExpansionTile(
            title: Text(history['summary_title'] ?? 'No Title'),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(history['tbl_appointment']?['tbl_availability']
                            ?['tbl_doctor']?['doctor_name'] ??
                        'No Doctor'),
                    Text(history['tbl_appointment']?['tbl_availability']
                            ?['tbl_doctor']?['doctor_gid'] ??
                        'No GID'),
                    Text(
                        history['tbl_appointment']?['tbl_availability']
                                    ?['tbl_doctor']?['tbl_hospitaldepartment']
                                ?['tbl_hospital']?['hospital_name'] ??
                            'No Hospital'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(history['summary_description'] ??
                    'No Description Available'),
              ),
              _buildSummary(history['summary_documents'] ?? []),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummary(List summary) {
    return ListView.builder(
      itemCount: summary.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        String url = summary[index].toString();
        bool isImage = url.toLowerCase().endsWith('.jpg') ||
            url.toLowerCase().endsWith('.jpeg') ||
            url.toLowerCase().endsWith('.png');
        bool isPdf = url.toLowerCase().endsWith('.pdf');

        return ListTile(
          title: Text(
            Uri.decodeComponent(url.split('/').last),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              if (isImage)
                ElevatedButton(
                  onPressed: () => _showImageDialog(context, url),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image),
                      SizedBox(width: 8),
                      Text('View Image'),
                    ],
                  ),
                )
              else if (isPdf)
                ElevatedButton(
                  onPressed: () => _launchURL(url),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.picture_as_pdf),
                      SizedBox(width: 8),
                      Text('View PDF'),
                    ],
                  ),
                )
              else
                Text('Unsupported file format'),
            ],
          ),
        );
      },
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 700,
            width: 700,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                boundaryMargin: EdgeInsets.all(20.0),
                minScale: 0.1,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(height: 8),
                        Text('Error loading image'),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching PDF: $e')),
      );
    }
  }

 Widget _buildAppointmentList() {
  if (filteredHistoryList.isEmpty) {
    return Center(child: Text("No previous appointments available"));
  }

  return Column(
    children: filteredHistoryList.map((appt) {
      final appointment = appt['tbl_appointment'] ?? {};
      final availability = appointment['tbl_availability'] ?? {};
      final doctor = availability['tbl_doctor'] ?? {};
      final hospitalDept = doctor['tbl_hospitaldepartment'] ?? {};
      final department = hospitalDept['tbl_department'] ?? {};

      return ListTile(
        title: Text(
          '${appointment['appointment_date'] ?? 'No Date'} - ${doctor['doctor_name'] ?? 'No Doctor'} - ${department['department_name'] ?? 'No Department'}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }).toList(),
  );
}
}
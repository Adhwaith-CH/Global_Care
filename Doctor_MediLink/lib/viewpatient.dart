import 'package:flutter/material.dart';
import 'package:loginpage/main.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class ConsultedPatientsListPage extends StatefulWidget {
  const ConsultedPatientsListPage({super.key});

  @override
  State<ConsultedPatientsListPage> createState() =>
      _ConsultedPatientsListPageState();
}

class _ConsultedPatientsListPageState extends State<ConsultedPatientsListPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchappointments();
  }

  List<Map<String, dynamic>> appointments = [];
  Future<void> fetchappointments() async {
    try {
      final response = await supabase
          .from('tbl_appointment')
          .select('*, tbl_user(*)')
          .eq('appointment_status', 1);
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
    // Sort patients by date (latest first)
    appointments.sort(
        (a, b) => b["appointment_date"]!.compareTo(a["appointment_date"]!));

    return Scaffold(
      appBar: AppBar(
        title: Text("Consulted Patients"),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: (appointment != null &&
                                  appointment.isNotEmpty &&
                                  appointment["tbl_user"]['user_photo'] !=
                                      null &&
                                  appointment["tbl_user"]['user_photo']
                                      .isNotEmpty)
                              ? NetworkImage(
                                  appointment["tbl_user"]['user_photo'])
                              : null,
                          child: (appointment == null ||
                                  appointment.isEmpty ||
                                  appointment["tbl_user"]['user_photo'] ==
                                      null ||
                                  appointment["tbl_user"]['user_photo'].isEmpty)
                              ? const Icon(Icons.person,
                                  size: 30, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment["tbl_user"]["user_name"]!,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Global ID: ${appointment["tbl_user"]["user_gid"]}",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                            Text(
                              "Date: ${appointment["appointment_date"]}",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Summary Button
                    ElevatedButton(
                      onPressed: () {
                        _viewSummary(
                          context,
                          appointment["tbl_user"]["user_name"]!,
                          appointment["tbl_user"]["user_gid"]!,
                          appointment["appointment_date"]!,
                          appointment["appointment_id"]!,
                        );
                      },
                      child: Text(
                        "Summary",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 25, 83, 112),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
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
  void _viewSummary(
      BuildContext context, String name, String globalId, String date, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientSummaryPage(
          name: name,
          globalId: globalId,
          date: date,
          id: id,
        ),
      ),
    );
  }
}

// Summary Page (To be Connected with DB in Future)
class PatientSummaryPage extends StatefulWidget {
  final String name;
  final String globalId;
  final String date;
  final int id;

  const PatientSummaryPage(
      {super.key,
      required this.name,
      required this.globalId,
      required this.date,
      required this.id});

  @override
  State<PatientSummaryPage> createState() => _PatientSummaryPageState();
}

class _PatientSummaryPageState extends State<PatientSummaryPage> {
  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Map<String, dynamic> appointment = {};
  List<String> fileUrls = []; // List to store multiple files

  Future<void> fetchAppointments() async {
    try {
      final response = await supabase
          .from('tbl_summary')
          .select()
          .eq('appointment_id', widget.id)
          .maybeSingle();

      setState(() {
        appointment = response ?? {};

        if (appointment["summary_documents"] != null) {
          if (appointment["summary_documents"] is String) {
            fileUrls = [appointment["summary_documents"].trim()];
          } else if (appointment["summary_documents"] is List) {
            fileUrls = (appointment["summary_documents"] as List)
                .map((item) => item.toString().trim())
                .where((url) => url.startsWith("http"))
                .toList();
          } else {
            fileUrls = [];
          }
        } else {
          fileUrls = [];
        }
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  bool isImage(String url) {
    return url.endsWith(".jpg") ||
        url.endsWith(".jpeg") ||
        url.endsWith(".png") ||
        url.endsWith(".gif");
  }

  bool isPDF(String url) {
    return url.endsWith(".pdf");
  }

  Future<void> _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consultation Summary"),
        backgroundColor: Color.fromARGB(255, 25, 83, 112),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Patient: ${widget.name}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text("Global ID: ${widget.globalId}"),
              SizedBox(height: 10),
              Text("Consultation Date: ${widget.date}",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              SizedBox(height: 20),
              Text(
                "Consultation Summary:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Disease: ${appointment["summary_title"] ?? "N/A"}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Summary: ${appointment["summary_description"] ?? "No summary available"}",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 8),
                    fileUrls.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Documents:",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              SizedBox(height: 8),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Set number of columns
                                  crossAxisSpacing: 10, // Space between columns
                                  mainAxisSpacing: 10, // Space between rows
                                  childAspectRatio: 0.7, // Adjust as needed
                                ),
                                itemCount: fileUrls.length,
                                itemBuilder: (context, index) {
                                  final url = fileUrls[index];
                                  if (isImage(url)) {
                                    return GestureDetector(
                                      onTap: () {
                                        showImage(context, url);
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          url,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              height: 200,
                                              color: Colors.grey[200],
                                              child: Icon(Icons.broken_image,
                                                  color: Colors.grey),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  } else if (isPDF(url)) {
                                    return GestureDetector(
                                      onTap: () {
                                        launchUrl(Uri.parse(url));
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            height: 200,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                            ),
                                            child: PdfDocumentLoader.openFile(
                                              url,
                                              pageNumber: 1,
                                              pageBuilder: (context,
                                                      textureBuilder,
                                                      pageSize) =>
                                                  textureBuilder(),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 5,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.picture_as_pdf,
                                              size: 40,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return ListTile(
                                      leading: Icon(Icons.insert_drive_file,
                                          color: Colors.blue),
                                      title: Text("Document ${index + 1}"),
                                      onTap: () => launchUrl(Uri.parse(url)),
                                    );
                                  }
                                },
                              ),
                            ],
                          )
                        : Text(
                            "No documents available",
                            style: TextStyle(fontSize: 16),
                          ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 25, 83, 112),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Back to List",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: 400,
            height: 600,
            child: PhotoView(
              imageProvider: NetworkImage(url),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        );
      },
    );
  }
}

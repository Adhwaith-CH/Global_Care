import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:loginpage/appointments.dart';
import 'package:loginpage/main.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConsultationSummaryPage extends StatefulWidget {
  final String patientName;
  final String globalId;
  final String image;
  final int appId;

  const ConsultationSummaryPage(
      {super.key,
      required this.patientName,
      required this.globalId,
      required this.appId,
      required this.image});

  @override
  _ConsultationSummaryPageState createState() =>
      _ConsultationSummaryPageState();
}

class _ConsultationSummaryPageState extends State<ConsultationSummaryPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController documentNameController = TextEditingController();

  List<File> _selectedFiles = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> insertsummary() async {
    try {
      final supabase = Supabase.instance.client;

      if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Please fill in all fields'),
              backgroundColor: Colors.red),
        );
        return;
      }

      if (_selectedFiles.isNotEmpty && documentNameController.text.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Please enter a document name before uploading'),
              backgroundColor: Colors.red),
        );
        return;
      }

      List<String> fileUrls = [];

      // Upload each selected file to Supabase Storage
      for (File file in _selectedFiles) {
        final fileBytes = await file.readAsBytes();
        final fileName =
            'consultation_docs/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

        try {
          await supabase.storage
              .from('documents')
              .uploadBinary(fileName, fileBytes);
          final publicUrl =
              supabase.storage.from('documents').getPublicUrl(fileName);
          fileUrls.add(publicUrl);
        } catch (e) {
          throw Exception('File upload failed: $e');
        }
      }

      // Insert data into Supabase
      await supabase.from('tbl_summary').insert({
        'summary_title': titleController.text,
        'summary_description': descriptionController.text,
        'summary_documents':
            fileUrls, // ✅ Converts to correct PostgreSQL array format
        'appointment_id': widget.appId,
        'summary_file': documentNameController.text,
      });
      await supabase
          .from('tbl_appointment')
          .update({'appointment_status': 1}).eq('appointment_id',
              widget.appId); // Make sure to use the correct condition

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Details successfully entered'),
            backgroundColor: Colors.green),
      );

      // Navigate only if everything is successful
      if (fileUrls.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TodayAppointmentsPage(),
          ),
        );
      }
    } catch (e) {
      print('Insert summary failed: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consultation Summary"),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Patient Information"),
            _buildInfoCard(),

            const SizedBox(height: 20),

            _buildSectionTitle("Disease/Issue Name"),
            _buildInputCard(titleController, "Enter disease or issue..."),

            const SizedBox(height: 20),

            _buildSectionTitle("Consultation Summary"),
            _buildInputCard(descriptionController, "Enter detailed summary...",
                maxLines: 5),

            const SizedBox(height: 20),

            _buildSectionTitle("Attach Documents"),
            _buildDocumentUploadField(), // Attach Documents Field in Date Picker Style

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          insertsummary();
        },
        label: Text("Save Summary", style: TextStyle(color: Colors.white)),
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        backgroundColor: Color.fromARGB(255, 25, 83, 112),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Section Title Styling
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  // Patient Info Card
  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          radius: 35,
          backgroundColor: Colors.grey[200], // Optional light background
          backgroundImage: (widget.image?.isNotEmpty ?? false)
              ? NetworkImage(widget.image!)
              : null,
          child: (widget.image?.isNotEmpty ?? false)
              ? null
              : const Icon(Icons.local_hospital, size: 30, color: Colors.grey),
        ),
        title: Text(
          widget.patientName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Global ID: ${widget.globalId}"),
      ),
    );
  }

  // Input Field Card
  Widget _buildInputCard(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // Date Picker

  // Attach Documents Section (Same Layout as Date Picker)
  Widget _buildDocumentUploadField() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        children: [
          // Document Name Input Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: documentNameController,
              decoration: InputDecoration(
                hintText: "Enter document name",
                labelText: "Document Name",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // File Upload Section
          ListTile(
            leading: Icon(Icons.attach_file,
                color: Color.fromARGB(255, 25, 83, 112)),
            title: _selectedFiles.isEmpty
                ? Text("No files selected")
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _selectedFiles
                        .map((file) => Text(
                              file.path.split('/').last,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ))
                        .toList(),
                  ),
            trailing: ElevatedButton(
              onPressed: _pickDocuments,
              child: Text(
                "Attach",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 25, 83, 112),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to Pick Documents
  Future<void> _pickDocuments() async {
    if (documentNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a document name before attaching files'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  // Function to Pick Date
}

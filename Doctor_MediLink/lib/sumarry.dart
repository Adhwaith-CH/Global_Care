import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ConsultationSummaryPage extends StatefulWidget {
  final String patientName;
  final String globalId;

  ConsultationSummaryPage({required this.patientName, required this.globalId});

  @override
  _ConsultationSummaryPageState createState() =>
      _ConsultationSummaryPageState();
}

class _ConsultationSummaryPageState extends State<ConsultationSummaryPage> {
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<File> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consultation Summary"),
        backgroundColor: Color.fromARGB(255, 37, 99, 160),
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
            _buildInputCard(_diseaseController, "Enter disease or issue..."),

            const SizedBox(height: 20),

            _buildSectionTitle("Consultation Summary"),
            _buildInputCard(_summaryController, "Enter detailed summary...", maxLines: 5),

            const SizedBox(height: 20),

            _buildSectionTitle("Date of Consultation"),
            _buildDatePicker(),

            const SizedBox(height: 20),

            _buildSectionTitle("Attach Documents"),
            _buildDocumentUploadField(), // Attach Documents Field in Date Picker Style

            const SizedBox(height: 80),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveSummary,
        label: Text("Save Summary",style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.save,color: Colors.white,),
        backgroundColor: Color.fromARGB(255, 37, 99, 160),
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
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
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
          backgroundColor: Color.fromARGB(255, 37, 99, 160),
          child: Icon(Icons.person, color: Colors.white),
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
  Widget _buildInputCard(TextEditingController controller, String hint, {int maxLines = 1}) {
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
  Widget _buildDatePicker() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: Color.fromARGB(255, 37, 99, 160)),
        title: Text("Selected Date: ${_selectedDate.toLocal()}".split(' ')[0]),
        trailing: ElevatedButton(
          onPressed: _pickDate,
          child: Text("Pick Date",style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 37, 99, 160),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  // Attach Documents Section (Same Layout as Date Picker)
  Widget _buildDocumentUploadField() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Icon(Icons.attach_file, color: Color.fromARGB(255, 37, 99, 160)),
        title: _selectedFiles.isEmpty
            ? Text("No files selected")
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _selectedFiles.map((file) => Text(
                      file.path.split('/').last,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    )).toList(),
              ),
        trailing: ElevatedButton(
          onPressed: _pickDocuments,
          child: Text("Attach",style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 37, 99, 160),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  // Function to Pick Documents
  Future<void> _pickDocuments() async {
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
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Function to Save Consultation Summary
  void _saveSummary() {
    String diseaseName = _diseaseController.text.trim();
    String summary = _summaryController.text.trim();
    String date = _selectedDate.toLocal().toString().split(' ')[0];

    if (diseaseName.isEmpty || summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    List<String> fileNames = _selectedFiles.map((file) => file.path.split('/').last).toList();

    print("Saved: $diseaseName, $summary, $date, Files: $fileNames");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Consultation Summary Saved"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}

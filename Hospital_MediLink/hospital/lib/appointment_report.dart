import 'dart:convert';
import 'dart:html' as html; // For web-specific functionality
import 'package:flutter/material.dart';
import 'package:hospital/main.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class AppointmentReportPage extends StatefulWidget {
  const AppointmentReportPage({super.key});

  @override
  _AppointmentReportPageState createState() => _AppointmentReportPageState();
}

class _AppointmentReportPageState extends State<AppointmentReportPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Map<String, dynamic>> _appointments = [];
  Map<String, dynamic> _userDetails = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await supabase.from('tbl_user').select('user_id, user_name, user_contact');
      setState(() {
        _userDetails = {for (var user in response) user['user_id']: user};
      });
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  Future<void> _fetchAppointments() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('tbl_appointment')
          .select('*, tbl_availability(*, tbl_doctor(*))')
          .eq('appointment_status', 1)
          .gte('appointment_date', _startDate!.toIso8601String().split('T')[0])
          .lte('appointment_date', _endDate!.toIso8601String().split('T')[0]);

      setState(() {
        _appointments = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching appointments: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _generateAndDownloadPdf() async {
    if (_appointments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No appointments to generate report')),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('yyyy-MM-dd');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Appointment Report (${dateFormat.format(_startDate!)} to ${dateFormat.format(_endDate!)})',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Patient', 'Doctor', 'Date', 'Time', 'Mode', 'Status', 'Token'],
              data: _appointments.map((appointment) {
                final user = _userDetails[appointment['user_id']] ?? {};
                final doctor = appointment['tbl_availability']?['tbl_doctor'] ?? {};
                return [
                  user['user_name']?.toString() ?? 'Unknown',
                  'Dr. ${doctor['doctor_name'] ?? 'N/A'} (${doctor['doctor_gid'] ?? 'N/A'})',
                  appointment['appointment_date']?.toString() ?? 'N/A',
                  appointment['tbl_availability']?['availability_time']?.toString() ?? 'N/A',
                  appointment['appointment_type'] == 'ON' ? 'Online' : 'Offline',
                  appointment['appointment_status'] == 1 ? 'Confirmed' : 'Pending',
                  appointment['appointment_token']?.toString() ?? 'N/A',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(5),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total Appointments: ${_appointments.length}',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          ],
        ),
      );

      // Generate PDF bytes
      final pdfBytes = await pdf.save();

      // Create a blob and trigger download on web
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'appointment_report_${dateFormat.format(_startDate!)}_to_${dateFormat.format(_endDate!)}.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF downloaded successfully')),
      );
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointment Report Generator',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.blueAccent),
        ),
        backgroundColor: const Color.fromARGB(255, 254, 255, 255),
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(_startDate == null
                        ? 'Select Start Date'
                        : 'Start: ${dateFormat.format(_startDate!)}'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(_endDate == null
                        ? 'Select End Date'
                        : 'End: ${dateFormat.format(_endDate!)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _fetchAppointments,
                  child: const Text('Generate Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0277BD),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: _generateAndDownloadPdf,
                  child: const Text('Download PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _appointments.isEmpty
                      ? const Center(child: Text('No appointments found for selected date range'))
                      : ListView.builder(
                          itemCount: _appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = _appointments[index];
                            final user = _userDetails[appointment['user_id']] ?? {};
                            final doctor = appointment['tbl_availability']?['tbl_doctor'] ?? {};

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text("Patient: ${user['user_name'] ?? 'Unknown'}"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Doctor: Dr. ${doctor['doctor_name'] ?? 'N/A'} (${doctor['doctor_gid'] ?? 'N/A'})"),
                                    Text("Date: ${appointment['appointment_date'] ?? 'N/A'}"),
                                    Text("Time: ${appointment['tbl_availability']?['availability_time'] ?? 'N/A'}"),
                                    Text("Mode: ${appointment['appointment_type'] == 'ON' ? 'Online' : 'Offline'}"),
                                    Text("Token: ${appointment['appointment_token']?.toString() ?? 'N/A'}"),
                                  ],
                                ),
                                trailing: Text(
                                  appointment['appointment_status'] == 1 ? 'Confirmed' : 'Pending',
                                  style: TextStyle(
                                    color: appointment['appointment_status'] == 1
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
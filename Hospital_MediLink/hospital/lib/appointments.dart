import 'package:flutter/material.dart';

class CounterStaffDashboard extends StatefulWidget {
  const CounterStaffDashboard({super.key});

  @override
  _CounterStaffDashboardState createState() => _CounterStaffDashboardState();
}

class _CounterStaffDashboardState extends State<CounterStaffDashboard> {
  final Map<String, int> _doctorTokens = {
    "Dr. Smith (DOC001)": 0,
    "Dr. Johnson (DOC002)": 0,
    "Dr. Lee (DOC003)": 0,
  };

  final List<Map<String, String>> _appointments = [
    {
      "patientName": "John Doe",
      "doctor": "Dr. Smith (DOC001)",
      "date": "2025-01-20",
      "time": "10:30 AM",
      "contact": "1234567890",
      "reason": "Regular Checkup",
      "status": "Pending",
      "mode": "Online"
    },
    {
      "patientName": "Jane Roe",
      "doctor": "Dr. Johnson (DOC002)",
      "date": "2025-01-20",
      "time": "11:00 AM",
      "contact": "9876543210",
      "reason": "Fever and Cough",
      "status": "Pending",
      "mode": "Offline"
    },
  ];

  String _selectedDoctorFilter = "All";
  String _selectedMode = "Online";

  void _confirmAppointment(int index) {
    final selectedDoctor = _appointments[index]["doctor"];
    if (selectedDoctor != null) {
      setState(() {
        _doctorTokens[selectedDoctor] = (_doctorTokens[selectedDoctor] ?? 0) + 1;
        final token = "${selectedDoctor.split(' ').last}-${_doctorTokens[selectedDoctor]!.toString().padLeft(3, '0')}";
        _appointments[index]["status"] = "Confirmed (Token: $token)";
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Token generated successfully for ${_appointments[index]['patientName']}"),
        backgroundColor: Colors.green,
      ));
    }
  }

  void _filterAppointments(String doctor) {
    setState(() {
      _selectedDoctorFilter = doctor;
    });
  }

  List<Map<String, String>> _getFilteredAppointments() {
    final filteredByDoctor = _selectedDoctorFilter == "All"
        ? _appointments
        : _appointments.where((appointment) => appointment["doctor"] == _selectedDoctorFilter).toList();

    return filteredByDoctor.where((appointment) => appointment["mode"] == _selectedMode).toList();
  }

  void _addAppointment() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController nameController = TextEditingController();
        final TextEditingController doctorController = TextEditingController();
        final TextEditingController dateController = TextEditingController();
        final TextEditingController timeController = TextEditingController();
        final TextEditingController contactController = TextEditingController();
        final TextEditingController reasonController = TextEditingController();
        String mode = "Online";

        return AlertDialog(
          title: Text("Add Appointment"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Patient Name"),
                ),
                TextField(
                  controller: doctorController,
                  decoration: InputDecoration(labelText: "Doctor"),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: "Date (YYYY-MM-DD)"),
                ),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(labelText: "Time (HH:MM AM/PM)"),
                ),
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(labelText: "Contact Number"),
                ),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(labelText: "Reason"),
                ),
                DropdownButton<String>(
                  value: mode,
                  items: ["Online", "Offline"].map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(m),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => mode = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Add"),
              onPressed: () {
                setState(() {
                  _appointments.add({
                    "patientName": nameController.text,
                    "doctor": doctorController.text,
                    "date": dateController.text,
                    "time": timeController.text,
                    "contact": contactController.text,
                    "reason": reasonController.text,
                    "status": "Pending",
                    "mode": mode,
                  });
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAppointments = _getFilteredAppointments();

    return DefaultTabController(
      length: 2, // Two tabs: Online and Offline
      child: Scaffold(
        appBar: AppBar(
          title: Text("Hospital Counter Dashboard"),
          backgroundColor: Color(0xFF0277BD),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: "Online"),
              Tab(text: "Offline"),
            ],
            onTap: (index) {
              setState(() {
                _selectedMode = index == 0 ? "Online" : "Offline";
              });
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButton<String>(
                value: _selectedDoctorFilter,
                items: ["All", ..._doctorTokens.keys].map((doctor) {
                  return DropdownMenuItem<String>(
                    value: doctor,
                    child: Text(doctor),
                  );
                }).toList(),
                onChanged: (value) => _filterAppointments(value!),
              ),
              Expanded(
                child: filteredAppointments.isEmpty
                    ? Center(child: Text("No appointments available."))
                    : ListView.builder(
                        itemCount: filteredAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = filteredAppointments[index];
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text("Patient: ${appointment['patientName']}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Doctor: ${appointment['doctor']}"),
                                  Text("Date: ${appointment['date']}"),
                                  Text("Time: ${appointment['time']}"),
                                  Text("Contact: ${appointment['contact']}"),
                                  Text("Reason: ${appointment['reason']}"),
                                ],
                              ),
                              trailing: Text(
                                appointment['status']!,
                                style: TextStyle(
                                    color: appointment['status']!.contains("Confirmed")
                                        ? Colors.green
                                        : Colors.red),
                              ),
                              onTap: appointment['status'] == "Pending"
                                  ? () => _confirmAppointment(index)
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF0277BD),
          onPressed: _addAppointment,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

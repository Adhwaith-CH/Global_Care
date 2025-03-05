import 'package:flutter/material.dart';
import 'package:hospital/main.dart';

class DoctorSchedulePage extends StatefulWidget {
  final String doctorId;
  const DoctorSchedulePage({super.key, required this.doctorId});

  @override
  _DoctorSchedulePageState createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  final List<String> _days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  String? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _countController = TextEditingController();

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final int hour = time.hourOfPeriod;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  String getFormattedSchedule(TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime == null || endTime == null) return "Not Available";
    return "${formatTimeOfDay(startTime)} - ${formatTimeOfDay(endTime)}";
  }

  Future<void> adddoctoravilability() async {
    try {
      String selectedtime = getFormattedSchedule(_startTime, _endTime);
      await supabase.from("tbl_availability").insert({
        'availability_day': _selectedDay,
        'availability_time': selectedtime,
        'availability_count': _countController.text,
        'doctor_id':widget.doctorId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Department added successfully!")),
      );
      setState(() {});
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add availability")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0277BD),
      appBar: AppBar(
        title: Text("Doctor Work Slot"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDay,
                decoration: InputDecoration(labelText: "Select Day"),
                items: _days.map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDay = value;
                  });
                },
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => _selectTime(context, true),
                    child: Text(_startTime == null
                        ? "Start Time"
                        : _startTime!.format(context)),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectTime(context, false),
                    child: Text(_endTime == null
                        ? "End Time"
                        : _endTime!.format(context)),
                  ),
                ],
              ),
              SizedBox(height: 15),
              TextField(
                controller: _countController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Number of Patients",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  adddoctoravilability();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text("Save Schedule"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

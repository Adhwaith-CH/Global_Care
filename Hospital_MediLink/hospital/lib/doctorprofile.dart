import 'package:flutter/material.dart';
import 'package:hospital/main.dart';

class DoctorProfilePage extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const DoctorProfilePage({super.key, required this.doctor});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  @override
  void initState() {
    super.initState();
    fetchAvailability();
  }

  Map<String, Map<String, dynamic>> availabilityData = {};

  final List<String> weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  List<Map<String, dynamic>> availability = [];

  Future<void> fetchAvailability() async {
    try {
      final response = await supabase.from('tbl_availability').select();
      Map<String, Map<String, dynamic>> tempAvailability = {};

      for (var entry in response) {
        String day = entry['availability_day']; // e.g., Monday, Tuesday
        String time = entry['availability_time']; // e.g., 9:50 AM - 9:50 PM
        int count = entry['availability_count']; // e.g., 8

        tempAvailability[day] = {"time": time, "count": count};
      }

      setState(() {
        availabilityData = tempAvailability;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  void _editAvailability(String day) {
    int selectedCount = availabilityData[day]?['count'] ?? 0;

    TimeOfDay? startTime;
    TimeOfDay? endTime;

    Future<void> selectTime(BuildContext context, bool isStartTime) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        setState(() {
          if (isStartTime) {
            startTime = picked;
          } else {
            endTime = picked;
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, top: 20),
          child: Container(
            height: 350,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Availability for $day",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                /// **Time Picker**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => selectTime(context, true),
                      child: Text(startTime == null
                          ? "Start Time"
                          : startTime!.format(context)),
                    ),
                    ElevatedButton(
                      onPressed: () => selectTime(context, false),
                      child: Text(endTime == null
                          ? "End Time"
                          : endTime!.format(context)),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                /// **Max Count Input**
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Max Patient Count",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    selectedCount = int.tryParse(value) ?? 0;
                  },
                ),

                SizedBox(height: 20),

                /// **Save Button**
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final response = await supabase
                          .from('tbl_availability')
                          .select()
                          .eq('doctor_id', widget.doctor['doctor_id'])
                          .eq('availability_day', day)
                          .maybeSingle();
                      String selectedtime =
                          getFormattedSchedule(startTime, endTime);

                      if (response == null) {
                        await supabase.from('tbl_availability').insert({
                          'doctor_id': widget.doctor['doctor_id'],
                          'availability_day': day,
                          'availability_time': selectedtime,
                          'availability_count': selectedCount
                        });
                      } else {
                        await supabase
                            .from('tbl_availability')
                            .update({
                              'availability_time': selectedtime,
                              'availability_count': selectedCount
                            })
                            .eq('doctor_id', widget.doctor['doctor_id'])
                            .eq('availability_day', day);
                      }

                      setState(() {
                        availabilityData[day] = {
                          "time": selectedtime,
                          "count": selectedCount
                        };
                      });
                    } catch (e) {
                      print("Error: $e");
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                  ),
                  child: Text("Save Changes"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text('Doctor Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Doctor Photo
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.doctor['doctor_photo'],
                    width: 250,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Professional Proof:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.doctor['doctor_proof'],
                          width: 200,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Doctor Name and Specialization
              Center(
                child: Column(
                  children: [
                    Text(
                      widget.doctor['doctor_name'] ?? "",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.doctor['tbl_hospitaldepartment']['tbl_department']
                              ['department_name'] ??
                          "",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Contact Information Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContactRow(
                          icon: Icons.phone,
                          text: widget.doctor['doctor_contact'].toString()),
                      Divider(),
                      ContactRow(
                          icon: Icons.email,
                          text: widget.doctor['doctor_email'].toString()),
                      Divider(),
                      ContactRow(
                          icon: Icons.location_on,
                          text: widget.doctor['tbl_place']['tbl_district']
                                  ['district_name']
                              .toString()),
                      Divider(),
                      ContactRow(
                          icon: Icons.place,
                          text: widget.doctor['tbl_place']['place_name']
                              .toString()),
                      Divider(),
                      ContactRow(
                          icon: Icons.cake,
                          text: widget.doctor['doctor_dob'].toString()),
                      Divider(),
                      ContactRow(
                          icon: Icons.accessibility,
                          text: widget.doctor['doctor_gender'].toString()),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Professional Proof & Schedule Button (Side by Side)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Proof Section

                  SizedBox(width: 15),

                  // Schedule Button
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Schedule',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),

                            // Display availability details if available
                            if (availability.isNotEmpty)
                              Row(
                                children: availability.map((entry) {
                                  return Container(
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Day: ${entry['availability_day'] ?? 'N/A'}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "Time: ${entry['availability_time']}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "Total Appointments: ${entry['availability_count'] ?? 0}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),

                                        Divider(), // Add a divider if multiple schedules exist
                                        SizedBox(
                                          width: 20,
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                              )
                            else
                              Text(
                                "No schedule available",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),

                            SizedBox(height: 10),

                            // Buttons: View & Change Schedule
                            SingleChildScrollView(
                              scrollDirection:
                                  Axis.horizontal, // Horizontal scrolling
                              child: Row(
                                children: weekDays.map((day) {
                                  bool isAvailable =
                                      availabilityData.containsKey(day);
                                  return GestureDetector(
                                    onTap: () {
                                      _editAvailability(day);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(8),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isAvailable
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            day,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          isAvailable
                                              ? Column(
                                                  children: [
                                                    Text(
                                                      "${availabilityData[day]?['time']}",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.person),
                                                        Text(
                                                          "${availabilityData[day]?['count']}",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  "Not Available",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ContactRow Widget for better structure
class ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: Colors.blueAccent, size: 22),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

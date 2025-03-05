import 'package:flutter/material.dart';
import 'package:hospital/main.dart';

class DoctorProfilePage extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const DoctorProfilePage({super.key, required this.doctor});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
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

  @override
  void initState() {
    super.initState();
    fetchAvailability();
  }

  Future<void> fetchAvailability() async {
    try {
      final response = await supabase
          .from('tbl_availability')
          .select()
          .eq('doctor_id', widget.doctor['doctor_id']);

      setState(() {
        availabilityData = {
          for (var entry in response)
            entry['availability_day']: {
              "time": entry['availability_time'],
              "count": entry['availability_count']
            }
        };
      });
    } catch (e) {
      print('Error fetching availability: $e');
    }
  }

  void _editAvailability(String day) {
    TimeOfDay selectedTime = TimeOfDay.now();
    int selectedCount = availabilityData[day]?['count'] ?? 0;

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
                GestureDetector(
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (pickedTime != null) {
                      setState(() => selectedTime = pickedTime);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "Select Time: ${selectedTime.format(context)}",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
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
                    await supabase.from('tbl_availability').upsert({
                      'doctor_id': widget.doctor['doctor_id'],
                      'availability_day': day,
                      'availability_time': selectedTime.format(context),
                      'availability_count': selectedCount
                    });

                    setState(() {
                      availabilityData[day] = {
                        "time": selectedTime.format(context),
                        "count": selectedCount
                      };
                    });

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
        title: Text('Doctor Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Doctor Availability",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            /// **Day Selector**
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: weekDays.map((day) {
                  bool isAvailable = availabilityData.containsKey(day);
                  return GestureDetector(
                    onTap: () => _editAvailability(day),
                    child: Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isAvailable ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          isAvailable
                              ? Column(
                                  children: [
                                    Text(
                                      "Time: ${availabilityData[day]?['time']}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      "Count: ${availabilityData[day]?['count']}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                )
                              : Text("Not Available",
                                  style: TextStyle(color: Colors.white)),
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
    );
  }
}

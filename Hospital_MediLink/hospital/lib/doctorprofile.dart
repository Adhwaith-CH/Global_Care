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
  List<Map<String, dynamic>> availability = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAvailability();
  }

  Future<void> fetchAvailability() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('tbl_availability')
          .select()
          .eq('doctor_id', widget.doctor['doctor_id']);

      List<Map<String, dynamic>> tempAvailabilityList = [];
      Map<String, Map<String, dynamic>> tempAvailabilityMap = {};

      for (var entry in response) {
        tempAvailabilityList.add({
          'availability_day': entry['availability_day'],
          'availability_time': entry['availability_time'],
          'availability_count': entry['availability_count'],
        });
        tempAvailabilityMap[entry['availability_day']] = {
          "time": entry['availability_time'],
          "count": entry['availability_count']
        };
      }

      setState(() {
        availability = tempAvailabilityList;
        availabilityData = tempAvailabilityMap;
      });
    } catch (e) {
      print('Exception during fetch: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load availability: $e')),
      );
    } finally {
      setState(() => isLoading = false);
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
          if (isStartTime)
            startTime = picked;
          else
            endTime = picked;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edit Availability for $day",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => selectTime(context, true)
                              .then((_) => modalSetState(() {})),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(startTime == null
                              ? "Start Time"
                              : startTime!.format(context)),
                        ),
                        ElevatedButton(
                          onPressed: () => selectTime(context, false)
                              .then((_) => modalSetState(() {})),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(endTime == null
                              ? "End Time"
                              : endTime!.format(context)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Max Patient Count",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: (value) {
                        selectedCount = int.tryParse(value) ?? 0;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          if (startTime == null || endTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Select Time')));
                          } else if (selectedCount == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Enter Count')));
                          } else {
                            final String selectedTime =
                                getFormattedSchedule(startTime, endTime);
                            final response = await supabase
                                .from('tbl_availability')
                                .select()
                                .eq('doctor_id', widget.doctor['doctor_id'])
                                .eq('availability_day', day)
                                .maybeSingle();

                            if (response == null) {
                              await supabase.from('tbl_availability').insert({
                                'doctor_id': widget.doctor['doctor_id'],
                                'availability_day': day,
                                'availability_time': selectedTime,
                                'availability_count': selectedCount,
                              });
                            } else {
                              await supabase
                                  .from('tbl_availability')
                                  .update({
                                    'availability_time': selectedTime,
                                    'availability_count': selectedCount,
                                  })
                                  .eq('doctor_id', widget.doctor['doctor_id'])
                                  .eq('availability_day', day);
                            }

                            setState(() {
                              availabilityData[day] = {
                                "time": selectedTime,
                                "count": selectedCount
                              };
                              fetchAvailability();
                            });
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Save Changes"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text('Doctor Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main Content (No separate header now)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Details Card with Fixed Width
                  SizedBox(
                    width: 500, // Set your desired width here
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Doctor Profile Section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                      widget.doctor['doctor_photo'] ?? ''),
                                  onBackgroundImageError: (_, __) =>
                                      Icon(Icons.error, color: Colors.grey),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.doctor['doctor_name'] ??
                                            "Unknown Doctor",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "ID: ${widget.doctor['doctor_gid']?.toString() ?? 'N/A'}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        widget.doctor['tbl_hospitaldepartment']
                                                    ?['tbl_department']
                                                ?['department_name'] ??
                                            "No Department",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 25),
                            // Professional Proof
                            Text(
                              'Professional Proof',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 15),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                widget.doctor['doctor_proof'] ?? '',
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 180,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.error, color: Colors.grey),
                                ),
                              ),
                            ),
                            SizedBox(height: 25),
                            // Contact Information
                            Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 15),
                            ContactRow(
                              icon: Icons.phone,
                              text:
                                  widget.doctor['doctor_contact']?.toString() ??
                                      'N/A',
                            ),
                            Divider(),
                            ContactRow(
                              icon: Icons.email,
                              text: widget.doctor['doctor_email']?.toString() ??
                                  'N/A',
                            ),
                            Divider(),
                            ContactRow(
                              icon: Icons.location_on,
                              text: widget.doctor['tbl_place']?['tbl_district']
                                          ?['district_name']
                                      ?.toString() ??
                                  'N/A',
                            ),
                            Divider(),
                            ContactRow(
                              icon: Icons.place,
                              text: widget.doctor['tbl_place']?['place_name']
                                      ?.toString() ??
                                  'N/A',
                            ),
                            Divider(),
                            ContactRow(
                              icon: Icons.cake,
                              text: widget.doctor['doctor_dob']?.toString() ??
                                  'N/A',
                            ),
                            Divider(),
                            ContactRow(
                              icon: Icons.accessibility,
                              text:
                                  widget.doctor['doctor_gender']?.toString() ??
                                      'N/A',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  // Schedule Card
                  Container(
                    width: 600, // Set the desired width
                    height: 800,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Schedule',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.refresh, size: 20),
                                  onPressed: fetchAvailability,
                                  tooltip: 'Refresh Schedule',
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            isLoading
                                ? Center(child: CircularProgressIndicator())
                                : availability.isEmpty &&
                                        availabilityData.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: Text(
                                            "No schedule available",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: availability.map((entry) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 15),
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 10),
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.1),
                                                    blurRadius: 5,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        entry['availability_day'] ??
                                                            'N/A',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        entry['availability_time'] ??
                                                            'N/A',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Chip(
                                                    label: Text(
                                                      '${entry['availability_count'] ?? 0}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        Colors.blueAccent,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 90),
                  Container(
                    width: 200,
                    height: 800,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                          15), // Added padding for better spacing
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Align center
                        children: [
                          Center(
                            // Center the title
                            child: Text(
                              'Weekly Availability',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                          SizedBox(height: 20), // Consistent spacing
                          Expanded(
                            child: ListView.builder(
                              itemCount: weekDays.length,
                              itemBuilder: (context, index) {
                                String day = weekDays[index];
                                bool isAvailable =
                                    availabilityData.containsKey(day);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8), // Spacing between items
                                  child: Tooltip(
                                    message: isAvailable
                                        ? '${availabilityData[day]?['time']}\nPatients: ${availabilityData[day]?['count']}'
                                        : 'Not Available',
                                    child: GestureDetector(
                                      onTap: () => _editAvailability(day),
                                      child: Container(
                                        width: double
                                            .infinity, // Full width within Container
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isAvailable
                                              ? Colors.green[50]
                                              : Colors.red[50],
                                          border: Border.all(
                                            color: isAvailable
                                                ? Colors.green
                                                : Colors.red,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              blurRadius: 5,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              day, // Full text displayed
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isAvailable
                                                    ? Colors.green[800]
                                                    : Colors.red[800],
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              isAvailable
                                                  ? '${availabilityData[day]?['count'] ?? 0}'
                                                  : '-',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isAvailable
                                                    ? Colors.green[800]
                                                    : Colors.red[800],
                                              ),
                                            ),
                                          ],
                                        ),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const ContactRow({required this.icon, required this.text, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/main.dart';

class AppointmentBookingPage extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const AppointmentBookingPage({super.key, required this.doctor});

  @override
  _AppointmentBookingPageState createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  List<Map<String, dynamic>> availabilitytime = [];
  DateTime? selectedDate;
  String? selectedAvailability;
  String? tokenNumber;
  bool isBooked = false;

  @override
  void initState() {
    super.initState();
  }

  void fetchtime(String selectedDay) async {
    try {
      final response = await supabase
          .from('tbl_availability')
          .select()
          .eq("doctor_id", widget.doctor['doctor_id'])
          .eq("availability_day", selectedDay); // Filter by day

      setState(() {
        availabilitytime = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  Future<void> confirmBooking() async {
    if (selectedDate == null || selectedAvailability == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a date and time slot")),
      );
      return;
    }

    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

      final recentBooking = await supabase
          .from('tbl_appointment')
          .count()
          .eq('appointment_date', formattedDate)
          .eq('availability_id', selectedAvailability!);

      print(recentBooking);

      final availability = await supabase
          .from('tbl_availability')
          .select('availability_count')
          .eq('availability_id', selectedAvailability!)
          .single();
      print(availability['availability_count']);
      if (recentBooking >= availability['availability_count']) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Appointment Full")));
      } else {
        int token = recentBooking + 1;
        await supabase.from('tbl_appointment').insert({
          'appointment_date': formattedDate,
          'availability_id': selectedAvailability,
          'appointment_token': token
        });
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Appointment Confirmed! Token: $token")));
      }
      // final response =
      //     await Supabase.instance.client.from('tbl_appointment').insert({
      //   'doctor_id': widget.doctor['id'],
      //   'appointment_date': formattedDate,
      //   'availability_id': selectedAvailability,
      // }).select();

      // if (response.isNotEmpty) {
      //   setState(() {
      //     tokenNumber = response[0]['token_number']?.toString() ?? "N/A";
      //     isBooked = true;
      //   });

      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Appointment Confirmed! Token: $tokenNumber")),
      //   );
      // }
    } catch (e) {
      print("Error booking appointment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to book appointment. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Appointment",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 93, 133, 153),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Doctor: ${widget.doctor['doctor_name']}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.local_hospital,
                            color: const Color.fromARGB(255, 3, 3, 3)),
                        const SizedBox(width: 8),
                        Text(
                          "Department: ${widget.doctor['doctor_department'] ?? 'General'}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Date Picker
            Text("Select Date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 30)),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });

                  // Convert the selected date into weekday format (e.g., "Monday")
                  String selectedDay = DateFormat('EEEE').format(pickedDate);

                  // Fetch availability for the selected day
                  fetchtime(selectedDay);
                }
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                          : "Select Date",
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.calendar_today, color: Colors.black),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Time Slots
            Text("Select Time Slot",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (availabilitytime.isEmpty)
              Text("No available slots",
                  style: TextStyle(color: Colors.red, fontSize: 16))
            else
              Wrap(
                spacing: 8,
                children: availabilitytime.map((slot) {
                  String availableTime =
                      slot['availability_time']; // ✅ Extract correctly
                  String chipValue = slot['availability_id'].toString();
                  return ChoiceChip(
                    showCheckmark: false,
                    label: Text(availableTime),
                    selected: selectedAvailability == chipValue,
                    selectedColor: Colors.blueGrey.shade200.withOpacity(0.8),
                    labelStyle: TextStyle(
                      color: selectedAvailability == chipValue
                          ? Colors.white
                          : Colors.black,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        selectedAvailability = chipValue;
                      });
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            if (!isBooked)
              Center(
                child: ElevatedButton(
                  onPressed: confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:const Color.fromARGB(255, 93, 133, 153),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Confirm Booking",
                      style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 244, 242, 242))),
                ),
              ),

            const SizedBox(height: 20),

            if (isBooked)
              Card(
                elevation: 5,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Appointment Confirmed!",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_hospital,
                              color: const Color.fromARGB(255, 3, 3, 3)),
                          const SizedBox(width: 8),
                          Text(
                            widget.doctor['doctor_name'],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "Time: $selectedAvailability",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 3, 3, 3)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Token Number: $tokenNumber",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Viewappointment extends StatefulWidget {
  const Viewappointment({super.key});

  @override
  State<Viewappointment> createState() => _ViewappointmentState();
}

class _ViewappointmentState extends State<Viewappointment> {
  String? dropdownValue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 25, 83, 112)),
      body: Container(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 80,
              color: const Color(0xFFE3F2FD),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 170,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255,255),
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              Icons.search,
                              color: Colors.black54, // Customize icon color
                              size: 24, // Customize icon size
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border:
                                    InputBorder.none, // Remove default border
                                hintText: 'Search',
                                hintStyle: TextStyle(
                                    color: Colors
                                        .black54), // Customize hint text color
                                contentPadding: EdgeInsets.only(
                                    bottom: 3), // Adjust text alignment
                              ),
                              style: TextStyle(
                                  color: Colors.black), // Customize text style
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 13,
                    ),
                    Container(
                      width: 170,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255,255),
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16), // Add some padding
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: dropdownValue, // Initial selected value
                          hint: Text(
                            'Select Status', // Hint text
                            style: TextStyle(
                                color: Colors.black54), // Hint text style
                          ),
                          icon: Icon(Icons.arrow_drop_down,
                              color: Colors.black54), // Dropdown arrow icon
                          iconSize: 24,
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          dropdownColor: const Color.fromARGB(
                              255, 255, 255,255), // Dropdown background color
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue =
                                  newValue!; // Update the selected value
                            });
                          },
                          items: <String>['Accepted', 'Rejected']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 20),
                  child: Text(
                    " Today Appointments",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 102, 109, 108),
                    ),
                  ),
                ),
              ),
            ),
           Padding(
             padding: const EdgeInsets.only(top: 3),
             child: Container(
               width: double.infinity,
               height: 130,
               decoration: BoxDecoration(
                 color: Color.fromARGB(255, 25, 83, 112), // A solid teal shade for the container
                 //borderRadius: BorderRadius.circular(20),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black26,
                     blurRadius: 8,
                     offset: Offset(0, 4), // Subtle shadow effect
                   ),
                 ],
               ),
               child: Center(
                 child: ListTile(
                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   leading: CircleAvatar(
                     radius: 40,
                     backgroundColor: Colors.white, // White background for contrast
                     child: Icon(
                       Icons.person, // Default profile icon
                       size: 40,
                       color: Color.fromARGB(255, 25, 83, 112), // Matches container theme
                     ),
                   ),
                   title: Text(
                     "Adwaith",
                     style: TextStyle(
                       fontSize: 22,
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                     ),
                   ),
                   subtitle: Text(
                     "GBL00055",
                     style: TextStyle(
                       fontSize: 16,
                       color: Colors.white70,
                     ),
                   ),
                   trailing: Row(
                     mainAxisSize: MainAxisSize.min,
                    children: [
                   ElevatedButton(
                     onPressed: () {
                       // Handle accept action
                     },
                     style: ElevatedButton.styleFrom(
                       shape: CircleBorder(), // Makes the button circular
                       padding: EdgeInsets.all(10), // Adjust padding for button size
                       elevation: 2, // Subtle shadow effect
                     ),
                     child: Icon(
                       Icons.check,
                       color: Colors.green, // Icon color
                     ),
                   ),
                   SizedBox(width: 10), // Add spacing between buttons
                   ElevatedButton(
                     onPressed: () {
                       // Handle reject action
                     },
                     style: ElevatedButton.styleFrom(
                       shape: CircleBorder(),
                       padding: EdgeInsets.all(10),
                       elevation: 2,
                     ),
                     child: Icon(
                       Icons.close,
                       color: Colors.red, // Icon color
                     ),
                   ),
                 ],
                 
                   ),
                 ),
               ),
             ),
           ),

          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String selectedOption = ''; // Track the selected option

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        //title: Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 253, 253, 254),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedOption = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Color.fromARGB(255, 37, 99, 160)),
                    SizedBox(width: 10),
                    Text('Edit Profile'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history, color: Color.fromARGB(255, 37, 99, 160)),
                    SizedBox(width: 10),
                    Text('View History'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'password',
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Color.fromARGB(255, 37, 99, 160)),
                    SizedBox(width: 10),
                    Text('Change Password'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'Logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Color.fromARGB(255, 37, 99, 160)),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
        
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Section with profile photo, name, and ID
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 253, 253, 254),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 25,
                      offset: Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Color.fromARGB(255, 37, 99, 160),
                      child: Icon(Icons.person, size: 120, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 37, 99, 160),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Global ID: 1234567890',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 37, 99, 160),
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons Section with conditional rendering
              // if (selectedOption == 'edit') ...[
              //   _buildActionButton('Edit Profile', Icons.edit, Color.fromARGB(255, 37, 99, 160)),
              // ] else if (selectedOption == 'history') ...[
              //   _buildActionButton('History', Icons.history, Color.fromARGB(255, 37, 99, 160)),
              // ] else if (selectedOption == 'password') ...[
              //   _buildActionButton('Change Password', Icons.lock, Color.fromARGB(255, 37, 99, 160)),
              // ],

              // Divider for separating sections
              Divider(height: 40, thickness: 1, color: Colors.white30),

              // User Details Section with modern card style
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildDetailCard('Email', 'user@example.com', Icons.email),
                    _buildDetailCard('Contact', '+1 234 567 890', Icons.phone),
                    _buildDetailCard('Address', '123 Main Street, City, Country', Icons.location_on),
                    _buildDetailCard('Gender', 'Male', Icons.person),
                    _buildDetailCard('Date of Birth', '01 Jan 1990', Icons.cake),
                    _buildDetailCard('Place', 'Hometown', Icons.home),
                    _buildDetailCard('District', 'District Name', Icons.map),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action Button with elevated style and consistent design
  Widget _buildActionButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {
        // Action logic here
      },
      icon: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      label: Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.2),
        minimumSize: Size(180, 60),
      ),
    );
  }

  // Detail Card with a fresh modern look, clean lines, and rounded corners
  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Color.fromARGB(255, 37, 99, 160)),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 37, 99, 160)),
        ),
        subtitle: Text(
          value,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}

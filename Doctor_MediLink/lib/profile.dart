import 'package:flutter/material.dart';
import 'package:loginpage/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = true;
  String selectedOption = ''; // Track the selected option
  String Name = "";
   String Contact = "";
   String Address = "";
   String Gender = "";
   String Dob = "";
   String Place = "";
   String District = "";
  String Email = "";
  String doctorphoto ="";
  
   

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final doctor_id = supabase.auth.currentUser!.id;

      if (doctor_id == null) {
        print('User not logged in');
        return;
      }

      final response = await supabase
          .from('tbl_doctor') // Your Supabase table name
          .select('*,tbl_place("*",tbl_district(*))') // Columns to fetch
          .eq('doctor_id', doctor_id) // Fetch only the logged-in user’s data
          .single(); // Get only one record
      setState(() {
        Name = response['doctor_name'] ?? 'No Name';
        doctorphoto = response['doctor_photo'] ?? 'No Name';
        Email = response['doctor_email'] ?? 'No Name';
        Contact = response['doctor_contact'] ?? 'No Name';
        Address = response['doctor_address'] ?? 'No Name';
        Gender = response['doctor_gender'] ?? 'No Name';
        Dob = response['doctor_dob'] ?? 'No Name';
        Place = response['tbl_place']['place_name'] ?? 'No Name';
        District = response['tbl_place']['tbl_district']['district_name'] ?? 'No Name';
        isLoading=false;
      });
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
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
                    Icon(Icons.edit, color: Color.fromARGB(255, 25, 83, 112)),
                    SizedBox(width: 10),
                    Text('Edit Profile'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history,
                        color: Color.fromARGB(255, 25, 83, 112)),
                    SizedBox(width: 10),
                    Text('View History'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'password',
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Color.fromARGB(255, 25, 83, 112)),
                    SizedBox(width: 10),
                    Text('Change Password'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'Logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app,
                        color: Color.fromARGB(255, 25, 83, 112)),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body:
        isLoading ? Center(child: CircularProgressIndicator(),) :      
       Container(
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
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(50)),
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
                          backgroundColor:
                              Colors.grey[200], // Optional light background
                          backgroundImage:
                              (doctorphoto?.isNotEmpty ?? false)
                                  ? NetworkImage(doctorphoto!)
                                  : null,
                          child:
                              (doctorphoto?.isNotEmpty ?? false)
                                  ? null
                                  : const Icon(Icons.person,
                                      size: 30, color: Colors.grey),
                        ),
                    SizedBox(height: 20),
                    Text(
                      Name,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 25, 83, 112),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Global ID: 1234567890',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 25, 83, 112),
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons Section with conditional rendering
              // if (selectedOption == 'edit') ...[
              //   _buildActionButton('Edit Profile', Icons.edit, Color.fromARGB(255, 25, 83, 112)),
              // ] else if (selectedOption == 'history') ...[
              //   _buildActionButton('History', Icons.history, Color.fromARGB(255, 25, 83, 112)),
              // ] else if (selectedOption == 'password') ...[
              //   _buildActionButton('Change Password', Icons.lock, Color.fromARGB(255, 25, 83, 112)),
              // ],

              // Divider for separating sections
              Divider(height: 40, thickness: 1, color: Colors.white30),

              // User Details Section with modern card style
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildDetailCard('Email', Email, Icons.email),
                    _buildDetailCard('Contact',Contact, Icons.phone),
                    _buildDetailCard('Address',Address, Icons.location_on),
                    _buildDetailCard('Gender', Gender, Icons.person),
                    _buildDetailCard('Date of Birth', Dob, Icons.cake),
                    _buildDetailCard('Place', Place, Icons.home),
                    _buildDetailCard('District', District, Icons.map),
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
        leading: Icon(icon, color: Color.fromARGB(255, 25, 83, 112)),
        title: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 25, 83, 112)),
        ),
        subtitle: Text(
          value,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}

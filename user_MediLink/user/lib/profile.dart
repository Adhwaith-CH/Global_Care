import 'package:flutter/material.dart';
// import 'package:loginpage/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  Map<String,dynamic> userData={};
  bool isLoading = true;
  String selectedOption = '';
  
   

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProfileData();
  }

 Future<void> fetchProfileData() async {
  try {
    final user_id = supabase.auth.currentUser!.id;

    if (user_id == null) {
      print('User not logged in');
      return;
    }

    final response = await supabase
        .from('tbl_user') // Your Supabase table name
        .select('*, tbl_place(*, tbl_district(*))') // Fetch related data
        .eq('user_id', user_id) // Filter by user ID
        .maybeSingle(); // Use maybeSingle() to avoid errors

    if (response == null) {
      print('No user data found for user ID: ${user_id}');
      setState(() {
        isLoading = false; // Ensure UI updates even if no data is found
      });
      return;
    }

    // Debugging: Print the response to check if the data structure is correct
    print("User Data: $response");

    setState(() {
     userData=response;
      isLoading = false;
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
                    Icon(Icons.edit, color:  Color.fromARGB(255, 0, 0, 0)),
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
                        color:  Color.fromARGB(255, 0, 0, 0)),
                    SizedBox(width: 10),
                    Text('View History'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'password',
                child: Row(
                  children: [
                    Icon(Icons.lock, color:  Color.fromARGB(255, 0, 0, 0)),
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
                        color:  Color.fromARGB(255, 0, 0, 0)),
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
             colors: [Colors.blueGrey.shade50, Colors.blueGrey.shade200],
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
                              (userData['user_photo']?.isNotEmpty ?? false)
                                  ? NetworkImage(userData['user_photo']!)
                                  : null,
                          child:
                              (userData['user_photo']?.isNotEmpty ?? false)
                                  ? null
                                  : const Icon(Icons.person,
                                      size: 30, color: Colors.grey),
                        ),
                    SizedBox(height: 20),
                    Text(
                      userData['user_name'] ?? "Error loading",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color:  Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      userData['user_gid'] ?? "Error loading",
                      style: TextStyle(
                        fontSize: 20,
                        color:  Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons Section with conditional rendering
              // if (selectedOption == 'edit') ...[
              //   _buildActionButton('Edit Profile', Icons.edit,  Color.fromARGB(255, 0, 0, 0)),
              // ] else if (selectedOption == 'history') ...[
              //   _buildActionButton('History', Icons.history,  Color.fromARGB(255, 0, 0, 0)),
              // ] else if (selectedOption == 'password') ...[
              //   _buildActionButton('Change Password', Icons.lock,  Color.fromARGB(255, 0, 0, 0)),
              // ],

              // Divider for separating sections
              Divider(height: 40, thickness: 1, color: Colors.white30),

              // User Details Section with modern card style
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                   _buildDetailCard('Email',  userData['user_email'] ?? "Error loading", Icons.email),
                    _buildDetailCard('Contact', userData['user_contact'].toString() ?? "Error loading", Icons.phone),
                    _buildDetailCard('Address', userData['user_address'] ?? "Error loading", Icons.location_on),
                    _buildDetailCard('Gender',  userData['user_gender'] ?? "Error loading", Icons.person),
                    _buildDetailCard('Date of Birth',  userData['user_dob'] ?? "Error loading", Icons.cake),
                    _buildDetailCard('Place',  userData['tbl_place']['place_name'] ?? "Error loading", Icons.home),
                    _buildDetailCard('District',  userData['tbl_place']['tbl_district']['district_name'] ?? "Error loading", Icons.map),
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
        leading: Icon(icon, color:  Color.fromARGB(255, 0, 0, 0)),
        title: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color:  Color.fromARGB(255, 0, 0, 0)),
        ),
        subtitle: Text(
          value,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}

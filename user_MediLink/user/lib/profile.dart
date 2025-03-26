import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/changepassword.dart';
import 'package:user/editprofile.dart';
import 'package:user/login.dart';
import 'package:user/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String,dynamic> userData = {};
  bool isLoading = true;
  String selectedOption = '';
  
  @override
  void initState() {
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
          .from('tbl_user')
          .select('*, tbl_place(*, tbl_district(*))')
          .eq('user_id', user_id)
          .maybeSingle();

      if (response == null) {
        print('No user data found for user ID: ${user_id}');
        setState(() {
          isLoading = false;
        });
        return;
      }

      print("User Data: $response");

      setState(() {
        userData = response;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching profile data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 25, 83, 112),
          ),
        ),
      );

      await supabase.auth.signOut();

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Loginpage()), // Replace with your login page class
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 253, 253, 254),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditprofilePage()),
                );
                if (result == true) fetchProfileData(); // Refresh on successful edit
              } else if (value == 'history') {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ViewHistoryPage()),
                // );
              } else if (value == 'password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              } else if (value == 'Logout') {
                await _handleLogout();
              }
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
                    Icon(Icons.exit_to_app, color: Color.fromARGB(255, 25, 83, 112)),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator())
        : Container(
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
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            (userData['user_photo']?.isNotEmpty ?? false)
                                ? NetworkImage(userData['user_photo']!)
                                : null,
                        child: (userData['user_photo']?.isNotEmpty ?? false)
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
                          color: Color.fromARGB(255, 25, 83, 112),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        userData['user_gid'] ?? "Error loading",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 25, 83, 112),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 40, thickness: 1, color: Colors.white30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildDetailCard('Email', userData['user_email'] ?? "Error loading", Icons.email),
                      _buildDetailCard('Contact', userData['user_contact'].toString() ?? "Error loading", Icons.phone),
                      _buildDetailCard('Address', userData['user_address'] ?? "Error loading", Icons.location_on),
                      _buildDetailCard('Gender', userData['user_gender'] ?? "Error loading", Icons.person),
                      _buildDetailCard('Date of Birth', userData['user_dob'] ?? "Error loading", Icons.cake),
                      _buildDetailCard('Place', userData['tbl_place']['place_name'] ?? "Error loading", Icons.home),
                      _buildDetailCard('District', userData['tbl_place']['tbl_district']['district_name'] ?? "Error loading", Icons.map),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

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
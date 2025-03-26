import 'package:flutter/material.dart';
import 'package:loginpage/changepassword.dart';
import 'package:loginpage/editprofile.dart';
import 'package:loginpage/loginpage.dart';
import 'package:loginpage/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = true;
  Map<String, dynamic>? profileData;
  
  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final doctorId = supabase.auth.currentUser?.id;
      if (doctorId == null) {
        throw Exception('User not logged in');
      }

      final response = await supabase
          .from('tbl_doctor')
          .select('*,tbl_place("*",tbl_district(*))')
          .eq('doctor_id', doctorId)
          .single()
          .timeout(Duration(seconds: 10));

      if (!mounted) return;

      setState(() {
        profileData = response;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching profile: $error'),
          backgroundColor: Colors.red,
        ),
      );
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
        MaterialPageRoute(builder: (context) => Loginpage()), // Replace with your login page
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
          : RefreshIndicator(
              onRefresh: fetchProfileData,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                              backgroundColor: Colors.grey[200],
                              backgroundImage: profileData?['doctor_photo']?.isNotEmpty ?? false
                                  ? NetworkImage(profileData!['doctor_photo'])
                                  : null,
                              child: profileData?['doctor_photo']?.isNotEmpty ?? false
                                  ? null
                                  : Icon(Icons.person, size: 30, color: Colors.grey),
                            ),
                            SizedBox(height: 20),
                            Text(
                              profileData?['doctor_name'] ?? 'No Name',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 25, 83, 112),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              profileData?['doctor_gid'] ?? 'No ID',
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
                            _buildDetailCard('Email', profileData?['doctor_email'] ?? 'No Email', Icons.email),
                            _buildDetailCard('Contact', profileData?['doctor_contact'] ?? 'No Contact', Icons.phone),
                            _buildDetailCard('Address', profileData?['doctor_address'] ?? 'No Address', Icons.location_on),
                            _buildDetailCard('Gender', profileData?['doctor_gender'] ?? 'Not Specified', Icons.person),
                            _buildDetailCard('Date of Birth', profileData?['doctor_dob'] ?? 'Not Set', Icons.cake),
                            _buildDetailCard('Place', profileData?['tbl_place']?['place_name'] ?? 'Not Set', Icons.home),
                            _buildDetailCard('District', profileData?['tbl_place']?['tbl_district']?['district_name'] ?? 'Not Set', Icons.map),
                          ],
                        ),
                      ),
                    ],
                  ),
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
            color: Color.fromARGB(255, 25, 83, 112),
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
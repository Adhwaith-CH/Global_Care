import 'package:flutter/material.dart';
import 'package:loginpage/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:user/pdfviewer.dart';

class UserProfilePage extends StatefulWidget {
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> historyList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileAndHistory();
  }

  Future<void> fetchProfileAndHistory() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('User not logged in');
        return;
      }

      final userResponse = await supabase
          .from('tbl_user')
          .select('*, tbl_place(*, tbl_district(*))')
          .eq('user_id', userId)
          .maybeSingle();

      final historyResponse = await supabase.from('tbl_summary').select(
          '*, tbl_appointment(*, tbl_availability(*, tbl_doctor(*, tbl_hospitaldepartment(*, tbl_department(*)))))');

      setState(() {
        userData = userResponse ?? {};
        historyList = List<Map<String, dynamic>>.from(historyResponse);
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile & History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
              PopupMenuItem(value: 'history', child: Text('View History')),
              PopupMenuItem(value: 'password', child: Text('Change Password')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileSection(),
                  _buildDetailSection(),
                  _buildMedicalHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage: userData['user_photo']?.isNotEmpty ?? false
                ? NetworkImage(userData['user_photo']!)
                : null,
            child: userData['user_photo']?.isEmpty ?? true
                ? Icon(Icons.person, size: 80, color: Colors.grey)
                : null,
          ),
          SizedBox(height: 20),
          Text(userData['user_name'] ?? 'Unknown', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(userData['user_gid'] ?? 'Unknown', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildDetailCard('Email', userData['user_email'] ?? 'N/A', Icons.email),
          _buildDetailCard('Contact', userData['user_contact']?.toString() ?? 'N/A', Icons.phone),
          _buildDetailCard('Address', userData['user_address'] ?? 'N/A', Icons.location_on),
          _buildDetailCard('Gender', userData['user_gender'] ?? 'N/A', Icons.person),
          _buildDetailCard('Date of Birth', userData['user_dob'] ?? 'N/A', Icons.cake),
          _buildDetailCard('Place', userData['tbl_place']?['place_name'] ?? 'N/A', Icons.home),
          _buildDetailCard('District', userData['tbl_place']?['tbl_district']?['district_name'] ?? 'N/A', Icons.map),
        ],
      ),
    );
  }

  Widget _buildMedicalHistory() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: historyList.map((history) {
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 5),
            child: ExpansionTile(
              title: Text(history['summary_title'] ?? 'No Title'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(history['summary_description'] ?? 'No Description Available'),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}
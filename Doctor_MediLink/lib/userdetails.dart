import 'package:flutter/material.dart';
import 'package:loginpage/main.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfilePage extends StatefulWidget {
  final String uid;

  const UserProfilePage({super.key, required this.uid});
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
    // Fetch user profile details
    final userResponse = await supabase
        .from('tbl_user')
        .select('*, tbl_place(*, tbl_district(*))')
        .eq('user_id', widget.uid)
        .maybeSingle();

    // Fetch only the summary, documents, and doctor details for the selected user
    final historyResponse = await supabase
        .from('tbl_summary')
        .select(
            'summary_title, summary_description, summary_documents, '
            'tbl_appointment!inner(user_id, '
            'tbl_availability(tbl_doctor(doctor_name, doctor_gid, '
            'tbl_hospitaldepartment(tbl_hospital(hospital_name)))))'
        )
        .eq('tbl_appointment.user_id', widget.uid); // Ensuring only selected user's history is fetched

    setState(() {
      userData = userResponse ?? {};
      historyList = historyResponse != null ? List<Map<String, dynamic>>.from(historyResponse) : [];
      isLoading = false;
    });

    debugPrint('Fetched User Data: ${userData.toString()}');
    debugPrint('Fetched History Data: ${historyList.toString()}');
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
        // actions: [
        //   PopupMenuButton<String>(
        //     onSelected: (value) {},
        //     itemBuilder: (context) => [
        //       PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
        //       PopupMenuItem(value: 'history', child: Text('View History')),
        //       PopupMenuItem(value: 'password', child: Text('Change Password')),
        //       PopupMenuItem(value: 'logout', child: Text('Logout')),
        //     ],
        //   ),
        // ],
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
        var appointment = history['tbl_appointment'];
        var availability = appointment != null ? appointment['tbl_availability'] : null;
        var doctor = availability != null ? availability['tbl_doctor'] : null;
        var hospitalDepartment = doctor != null ? doctor['tbl_hospitaldepartment'] : null;
        var hospital = hospitalDepartment != null ? hospitalDepartment['tbl_hospital'] : null;

        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ExpansionTile(
            title: Text(history['summary_title'] ?? 'No Title'),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(doctor?['doctor_name'] ?? 'No Doctor Name'),
                    Text(doctor?['doctor_gid'] ?? 'No Doctor ID'),
                    Text(hospital?['hospital_name'] ?? 'No Hospital Name'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(history['summary_description'] ?? 'No Description Available'),
              ),
              _buildSummary(history['summary_documents'] ?? []),
            ],
          ),
        );
      }).toList(),
    ),
  );
}


  Widget _buildSummary(List summary) {
  return ListView.builder(
    itemCount: summary.length,
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemBuilder: (context, index) {
      String url = summary[index].toString();
      bool isImage = url.toLowerCase().endsWith('.jpg') || 
                     url.toLowerCase().endsWith('.jpeg') || 
                     url.toLowerCase().endsWith('.png');
      bool isPdf = url.toLowerCase().endsWith('.pdf');

      return ListTile(
        title: Text(
          Uri.decodeComponent(url.split('/').last),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            if (isImage)
              ElevatedButton(
                onPressed: () => _showImageDialog(context, url),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image),
                    SizedBox(width: 8),
                    Text('View Image'),
                  ],
                ),
              )
            else if (isPdf)
              ElevatedButton(
                onPressed: () => _launchURL(url),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text('View PDF'),
                  ],
                ),
              )
            else
              Text('Unsupported file format'),
          ],
        ),
      );
    },
  );
}

// Function to show image in a zoomable dialog
void _showImageDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: SizedBox(
          height: 700,
          width: 700,
          child: GestureDetector(
            onTap: () => Navigator.pop(context), // Close on tap outside image
            child: InteractiveViewer(
              boundaryMargin: EdgeInsets.all(20.0),
              minScale: 0.1,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(height: 8),
                      Text('Error loading image'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Function to launch URL for PDF viewing
Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Opens in external app
      );
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    print('Error launching URL: $e');
    // You might want to show a snackbar or dialog here to inform the user
  }
}

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF1A3C5A)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}
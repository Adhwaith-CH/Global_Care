import 'package:flutter/material.dart';
import 'package:user/hospitalselection.dart';
import 'package:user/history.dart';
import 'package:user/main.dart';
import 'package:user/profile.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: HomePageContent(), // Directly showing HomePageContent
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  bool isToggled = false;

  set selectedNumber(int selectedNumber) {}

  List<Map<String, dynamic>> appointmentList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchappointment();
    fetchuser();
  }

  Future<void> fetchappointment() async {
    try {
      final response = await supabase.from('tbl_appointment').select(
          '*, tbl_availability(*, tbl_doctor("doctor_name", tbl_hospitaldepartment(tbl_department("department_name"),tbl_hospital("hospital_name","hospital_photo"))))');
      // print(response);
      setState(() {
        appointmentList = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  String image = ""; // ✅ Class-level variable to store user_photo

  Future<void> fetchuser() async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select("user_photo").eq('user_id', supabase.auth.currentUser!.id)
          .single(); // ✅ Fetch single user photo
        print(response);
      if (response != null && response['user_photo'] != null) {
        setState(() {
          image = response['user_photo']; // ✅ Update `image`
        });
      } else {
        print("❌ No user photo found");
      }

      print("✅ Fetched user photo: $image"); // Debugging
    } catch (e) {
      print('❌ Exception during fetch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 247, 243, 243),
              const Color.fromARGB(255, 218, 228, 238)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(),

                  const SizedBox(height: 20),

                  // Highlight Section
                  _buildHighlightSection(),

                  const SizedBox(height: 24),

                  // Quick Links Section
                  Text(
                    'Quick Links',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 25, 83, 112),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickLinks(),

                  const SizedBox(height: 24),

                  // Insights Section
                  Text(
                    'Upcoming appointments',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 25, 83, 112),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInsightCards(),

                  const SizedBox(height: 24),

                  const SizedBox(height: 40),

                  // Footer
                  Center(
                    child: Text(
                      'Powered by MediLink © 2025',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Welcome, User!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 25, 83, 112),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Your daily dashboard is ready.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile()),
            );
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200], // ✅ Light grey background
            backgroundImage: (image.isNotEmpty)
                ? NetworkImage(image) // ✅ Load profile picture
                : null,
            child: (image.isEmpty)
                ? Icon(Icons.person,
                    size: 30, color: Colors.white) // ✅ Default icon
                : null, // Hide icon if image exists
          ),
        )
      ],
    );
  }

  Widget _buildHighlightSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.dashboard,
              size: 60, color: Color.fromARGB(255, 25, 83, 112)),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 25, 83, 112),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Monitor patients and \n appointments  in one place.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinks() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            imagePath:
                'assets/freepik__the-style-is-candid-image-photography-with-natural__37503.jpeg', // Local image
            label: 'View History',

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PatientHealthHistoryPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            imagePath:
                'assets/freepik__the-style-is-candid-image-photography-with-natural__37504.jpeg', // Another image
            label: 'Booking',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HospitalBooking()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    String? imagePath, // Image instead of Icon
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140, // Increased height for better spacing
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imagePath != null)
              Expanded(
                // Ensures the image fills the available space
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(15), // Optional rounded corners
                  child: Image.asset(
                    imagePath,
                    width: double.infinity, // Ensures full width usage
                    fit:
                        BoxFit.contain, // Adjust to fit the container perfectly
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 15, 67, 94),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCards() {
    return Column(
      children: appointmentList.map((data) {
        // final appointment = data;
        print(data);
        String doctor = data['tbl_availability']['tbl_doctor']['doctor_name'];
        String hospital = data['tbl_availability']['tbl_doctor']
            ['tbl_hospitaldepartment']['tbl_hospital']['hospital_name'];
        String photo = data['tbl_availability']['tbl_doctor']
            ['tbl_hospitaldepartment']['tbl_hospital']['hospital_photo'];
        String department = data['tbl_availability']['tbl_doctor']
            ['tbl_hospitaldepartment']['tbl_department']['department_name'];
        String date = data['appointment_date'];
        String time = data['tbl_availability']['availability_time'];
        String token = data['appointment_token'].toString();
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Hospital Logo / Avatar
              CircleAvatar(
                radius: 35,
                backgroundColor: const Color.fromARGB(255, 15, 67, 94),
                backgroundImage: NetworkImage(photo),
              ),
              const SizedBox(width: 16),

              // Hospital & Doctor Details (Left Side)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital ?? 'Unknown Hospital',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 15, 67, 94),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildDetailRow(Icons.person, doctor ?? 'Not available'),
                    _buildDetailRow(
                        Icons.medical_services, department ?? 'Not available'),
                    _buildDetailRow(
                        Icons.calendar_today, date ?? 'Not specified'),
                    _buildDetailRow(Icons.access_time, time ?? 'Not specified'),
                  ],
                ),
              ),

              // Token Number Badge (Right Side)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                decoration: BoxDecoration(
                  color:
                      Color.fromARGB(255, 15, 67, 94), // Professional dark red
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.confirmation_num,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['appointment_token'].toString() ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

// Helper Function for Cleaner Code
  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Color.fromARGB(255, 15, 67, 94)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }
}

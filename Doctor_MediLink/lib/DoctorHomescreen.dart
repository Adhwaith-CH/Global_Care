import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:loginpage/appointments.dart';
import 'package:loginpage/finduser.dart';
import 'package:loginpage/main.dart';
import 'package:loginpage/profile.dart';
import 'package:loginpage/viewpatient.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 1;
  bool isToggled = false;
  int selectedNumber = 10; // Initial value

  final List<Widget> _pages = [
    Finduser(),
    HomePageContent(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        items: const <Widget>[
          Icon(Icons.person_search, size: 30, color: Colors.white),
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.account_circle, size: 30, color: Colors.white),
        ],
        height: 60,
        color: Color.fromARGB(255, 25, 83, 112), // Emerald Green
        backgroundColor: const Color.fromARGB(255, 218, 228, 238),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 350),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  bool isToggled = false;
  String Name = "";
  String hosname = "";
  String hoscontact = "";
  String hosaddress = "";
  String hosphoto = "";

  String doctorphoto = "";

  set selectedNumber(int selectedNumber) {}

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
          .select(
              '*, tbl_place(*, tbl_district(*)), tbl_hospitaldepartment(*, tbl_hospital(*))')
          .eq('doctor_id', doctor_id) // Fetch only the logged-in doctor’s data
          .single();
      // Get only one record
      print(response);
      setState(() {
        Name = response['doctor_name'] ?? 'No Name';
        hosname = response['tbl_hospitaldepartment']['tbl_hospital']
                ['hospital_name'] ??
            'N/A';
        hoscontact = response['tbl_hospitaldepartment']['tbl_hospital']
                    ['hospital_contact']
                .toString() ??
            'N/A';
        hosaddress = response['tbl_hospitaldepartment']['tbl_hospital']
                ['hospital_address'] ??
            'N/A';
        hosphoto = response['tbl_hospitaldepartment']['tbl_hospital']
                ['hospital_photo'] ??
            'N/A';
        doctorphoto = response['doctor_photo'] ?? 'No Name';
      });
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
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
                  'Detailed Insights',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 25, 83, 112),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInsightCards(),

                const SizedBox(height: 44),

                // Settings Section

                // Footer
                Center(
                  child: Text(
                    'Powered by MediLink © 2025',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
              ],
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
              'Welcome, Doctor!',
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
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200], // Optional light background
          backgroundImage: (doctorphoto?.isNotEmpty ?? false)
              ? NetworkImage(doctorphoto!)
              : null,
          child: (doctorphoto?.isNotEmpty ?? false)
              ? null
              : const Icon(Icons.person, size: 30, color: Colors.grey),
        ),
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
            Column(
              children: [
                Image.asset(
                  'assets/Untitled_Project__4_-removebg-preview.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 4),
                Text(
                  'MEDILINK',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A3C5A),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Health Hub',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A3C5A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'MediLink keeps your patients history at your fingertips',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildQuickLinks() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
              icon: Icons.person,
              label: 'View Patients',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ConsultedPatientsListPage()),
                );
              }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            icon: Icons.schedule,
            label: 'Appointments',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TodayAppointmentsPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Color.fromARGB(255, 25, 83, 112)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 25, 83, 112),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCards() {
    return Column(
      children: [
        _buildInsightCard(
          title: hosname,
          description: hosaddress,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInsightCard({
  required String title,
  required String description,
}) {
  return Container(
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(hosphoto), // Ensure the image loads properly
        ),
        const SizedBox(width: 20),
        // Ensure the column containing text can expand within available space
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 25, 83, 112),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 16, color: Colors.grey),
                maxLines: 5, // Limits the number of lines to prevent overflow
                overflow: TextOverflow.ellipsis, // Adds "..." if text overflows
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

}

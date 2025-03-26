import 'package:flutter/material.dart';
import 'package:user/hospitalselection.dart';
import 'package:user/history.dart';
import 'package:user/main.dart';
import 'package:user/profile.dart';
import 'dart:math' as math; // For 3D transformation matrix

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
      body: HomePageContent(),
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
  List<Map<String, dynamic>> appointmentList = [];
  String image = "";

  @override
  void initState() {
    super.initState();
    fetchappointment();
    fetchuser();
  }

  Future<void> fetchappointment() async {
    try {
      final response = await supabase.from('tbl_appointment').select(
          '*, tbl_availability(*, tbl_doctor("doctor_name", tbl_hospitaldepartment(tbl_department("department_name"),tbl_hospital("hospital_name","hospital_photo"))))').eq('user_id', supabase.auth.currentUser!.id).eq('appointment_status',0);
      setState(() {
        appointmentList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  Future<void> fetchuser() async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select("user_photo")
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();
      if (response != null && response['user_photo'] != null) {
        setState(() {
          image = response['user_photo'];
        });
      }
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  // New refresh function that combines both data fetches
  Future<void> _refreshData() async {
    await Future.wait([
      fetchappointment(),
      fetchuser(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F7FA), // Softer light gray
              Color(0xFFE5ECEF), // Light blue-gray
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Color(0xFF1A3C5A), // Refresh indicator color
          backgroundColor: Colors.white,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Ensures scrollability for refresh
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildHighlightSection(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Quick Links'),
                    const SizedBox(height: 16),
                    _buildQuickLinks(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Upcoming Appointments'),
                    const SizedBox(height: 16),
                    _buildInsightCards(),
                    const SizedBox(height: 48),
                    Center(
                      child: Text(
                        'Powered by MediLink © 2025',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
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
          children: [
            Text(
              'Welcome, User!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A3C5A),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your health dashboard awaits.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
          },
          child: CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
            child: image.isEmpty
                ? Icon(Icons.person, size: 32, color: Colors.grey.shade700)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
                  letterSpacing: 1.2,
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
                  'Securely manage your health data, always accessible when you need it.',
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A3C5A),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildQuickLinks() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.history,
            label: 'View History',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PatientHealthHistoryPage()));
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            icon: Icons.book_online,
            label: 'Book Appointment',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalBooking()));
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
    bool isPressed = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) {
            setState(() => isPressed = false);
            onTap();
          },
          onTapCancel: () => setState(() => isPressed = false),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(isPressed ? 0.05 : -0.05)
              ..rotateY(isPressed ? -0.05 : 0.05),
            alignment: Alignment.center,
            child: Container(
              height: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isPressed ? 0.1 : 0.05),
                    blurRadius: isPressed ? 8 : 12,
                    offset: Offset(0, isPressed ? 2 : 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: Color(0xFF1A3C5A)),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A3C5A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightCards() {
    if (appointmentList.isEmpty) {
      return Center(
        child: Text(
          'No upcoming appointments.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }
    return Column(
      children: appointmentList.map((data) {
        String doctor = data['tbl_availability']['tbl_doctor']['doctor_name'] ?? 'Not available';
        String hospital = data['tbl_availability']['tbl_doctor']['tbl_hospitaldepartment']['tbl_hospital']['hospital_name'] ?? 'Unknown Hospital';
        String photo = data['tbl_availability']['tbl_doctor']['tbl_hospitaldepartment']['tbl_hospital']['hospital_photo'] ?? '';
        String department = data['tbl_availability']['tbl_doctor']['tbl_hospitaldepartment']['tbl_department']['department_name'] ?? 'Not available';
        String date = data['appointment_date'] ?? 'Not specified';
        String time = data['tbl_availability']['availability_time'] ?? 'Not specified';
        String token = data['appointment_token'].toString();

        return StatefulBuilder(
          builder: (context, setState) {
            bool isPressed = false;

            return GestureDetector(
              onTapDown: (_) => setState(() => isPressed = true),
              onTapUp: (_) => setState(() => isPressed = false),
              onTapCancel: () => setState(() => isPressed = false),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective for 3D effect
                  ..rotateX(isPressed ? 0.05 : -0.05) // Tilt on Y-axis
                  ..rotateY(isPressed ? -0.05 : 0.05), // Tilt on X-axis
                alignment: Alignment.center,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isPressed ? 0.1 : 0.05),
                        blurRadius: isPressed ? 8 : 12,
                        offset: Offset(0, isPressed ? 2 : 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                        child: photo.isEmpty ? Icon(Icons.local_hospital, color: Color(0xFF1A3C5A)) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hospital,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A3C5A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(Icons.person, doctor),
                            _buildDetailRow(Icons.medical_services, department),
                            _buildDetailRow(Icons.calendar_today, date),
                            _buildDetailRow(Icons.access_time, time),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A3C5A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.confirmation_num, color: Colors.white, size: 20),
                            const SizedBox(height: 4),
                            Text(
                              token,
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
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Color(0xFF1A3C5A)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
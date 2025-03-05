import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:user/booking.dart';
import 'package:user/history.dart';
import 'package:user/selectdoctor.dart';
import 'package:user/profile.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 1;
  bool isToggled = false;
  int selectedNumber = 10; // Initial value

  final List<Widget> _pages = [
    HospitalBooking(),
    HomePageContent(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: HomePageContent(), // Directly showing HomePageContent
    );
  }
}

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  bool isToggled = false;

  set selectedNumber(int selectedNumber) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade50, Colors.blueGrey.shade200],
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
                      color: Color.fromARGB(255, 0, 0, 0),
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
                      color: Color.fromARGB(255, 0, 0, 0),
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
                color: Color.fromARGB(255, 0, 0, 0),
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
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
            child: Icon(Icons.person, size: 30, color: Colors.white),
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
          Icon(Icons.dashboard, size: 60, color: Color.fromARGB(255, 0, 0, 0)),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
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
            icon: Icons.person,
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
            icon: Icons.schedule,
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
            Icon(icon, size: 40, color: Color.fromARGB(255, 0, 0, 0)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
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
        for (var hospital in _hospitalsList)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hospital Logo / Avatar
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.black,
                  child: Icon(
                    Icons.local_hospital,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),

                // Hospital & Doctor Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital['name'] ?? 'Unknown Hospital',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 18, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            hospital['doctor_name'] ?? 'Not available',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.medical_services,
                              size: 18, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            hospital['doctor_department'] ?? 'Not available',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            hospital['appointment_date'] ?? 'Not specified',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 18, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            hospital['appointment_time'] ?? 'Not specified',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }

  final List<Map<String, String>> _hospitalsList = [
    {
      'name': 'City Hospital',
      'location': 'Downtown',
      'doctor_name': 'Dr. John Smith',
      'doctor_department': 'Cardiology',
      'appointment_date': 'March 5, 2025',
      'appointment_time': '10:30 AM'
    },
    {
      'name': 'Sunrise Medical Center',
      'location': 'West End',
      'doctor_name': 'Dr. Emily Johnson',
      'doctor_department': 'Dermatology',
      'appointment_date': 'March 6, 2025',
      'appointment_time': '2:00 PM'
    },
    {
      'name': 'Green Valley Hospital',
      'location': 'East Side',
      'doctor_name': 'Dr. Robert Williams',
      'doctor_department': 'Orthopedics',
      'appointment_date': 'March 7, 2025',
      'appointment_time': '11:15 AM'
    },
    {
      'name': 'Grand Care Hospital',
      'location': 'North District',
      'doctor_name': 'Dr. Sophia Martinez',
      'doctor_department': 'Neurology',
      'appointment_date': 'March 8, 2025',
      'appointment_time': '9:45 AM'
    },
  ];

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
        children: [
          Icon(Icons.bar_chart, size: 50, color: Color.fromARGB(255, 0, 0, 0)),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String description,
  }) {
    return Container(
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
      child: Row(
        children: [
          Icon(Icons.settings, size: 40, color: Color.fromARGB(255, 0, 0, 0)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

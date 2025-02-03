import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:loginpage/ViewAppointment.dart';
import 'package:loginpage/finduser.dart';
import 'package:loginpage/profile.dart';

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
      appBar: AppBar(
        title: const Text(
          '',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 37, 99, 160), // Emerald Green for professionalism
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        items: const <Widget>[
          Icon(Icons.person_search, size: 30, color: Colors.white),
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.account_circle, size: 30, color: Colors.white),
        ],
        height: 60,
        color: Color.fromARGB(255, 37, 99, 160), // Emerald Green
        backgroundColor: Colors.white,
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

  set selectedNumber(int selectedNumber) {}

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade50],
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
                      color: Color.fromARGB(255, 37, 99, 160),
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
                      color: Color.fromARGB(255, 37, 99, 160),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInsightCards(),

                  const SizedBox(height: 24),

                  // Settings Section
                  Text(
                    'Settings',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 37, 99, 160),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsCards(),

                  const SizedBox(height: 40),

                  // Footer
                  Center(
                    child: Text(
                      'Powered by MediLink © 2025',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 14),
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
              'Welcome, Doctor!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 37, 99, 160),
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
          backgroundColor: Color.fromARGB(255, 37, 99, 160),
          child: Icon(Icons.person, size: 30, color: Colors.white),
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
          Icon(Icons.dashboard, size: 60, color: Color.fromARGB(255, 37, 99, 160)),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 37, 99, 160),
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
            label: 'View Patients',
            onTap: () {
              // Navigate to View Patients Page
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            icon: Icons.schedule,
            label: 'Appointments',
            onTap: () {
              // Navigate to Appointments Page
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
            Icon(icon, size: 40, color: Color.fromARGB(255, 37, 99, 160)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 37, 99, 160),
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
          title: 'Today’s Overview',
          description: 'Check your daily patient count \n and appointments.',
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          title: 'Pending Tasks',
          description: 'Review 5 pending patient reports.',
        ),
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
        children: [
          Icon(Icons.bar_chart, size: 50, color: Color.fromARGB(255, 37, 99, 160)),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 37, 99, 160),
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

  Widget _buildSettingsCards() {
    return Column(
      children: [
        _buildSettingsCard(
          title: 'Connection Settings',
          description: 'Connect your profile with a hospital.',
        ),
        const SizedBox(height: 16),
        _buildSettingsCard(
          title: 'Support',
          description: 'Contact support for help and guidance.',
        ),
      ],
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
          Icon(Icons.settings, size: 40, color: Color.fromARGB(255, 37, 99, 160)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 37, 99, 160),
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
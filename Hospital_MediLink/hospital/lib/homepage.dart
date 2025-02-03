import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hospital/adddepartment.dart';
import 'package:hospital/adddoctor.dart';
import 'package:hospital/appointments.dart';
import 'package:hospital/findperson.dart';
import 'package:hospital/managestaff.dart';
import 'package:hospital/attendence.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isHeaderVisible) {
          setState(() {
            _isHeaderVisible = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isHeaderVisible) {
          setState(() {
            _isHeaderVisible = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }




  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.only(top: 210), // Space for header
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Section
                    Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: _buildStatsCard("Doctors", "120", Icons.person_add),
    ),
    SizedBox(width: 10), // Space between cards
    Expanded(
      child: _buildStatsCard("Appointments", "450", Icons.calendar_today),
    ),
    SizedBox(width: 10), // Space between cards
    Expanded(
      child: _buildStatsCard("Departments", "15", Icons.apartment),
    ),
  ],
),

                    SizedBox(height: 40),

                    // Dashboard Title
                    Text(
                      "Dashboard Overview",
                      style: TextStyle(
                        color: Color(0xFF0D47A1),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Choose an action to proceed:",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 30),

                    // Grid of Options
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.4,
                      children: [
                        _buildGridCard(
                          context,
                          "Add Doctor",
                          Icons.medical_services,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Adddoctor()),
                            );
                          },
                        ),
                        _buildGridCard(
                          context,
                          "Add Department",
                          Icons.apartment,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Adddepartment()),
                            );
                          },
                        ),
                        _buildGridCard(context, "Manage Staff", Icons.group, () {
                          // Navigate to Manage Staff screen
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HospitalStaffManagementPage()),
                            );
                        }),
                        _buildGridCard(
                            context, "Attendence Reports", Icons.insert_chart, () {
                          // Navigate to View Reports screen
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StaffAttendancePage()),
                            );
                        }),
                        _buildGridCard(
                            context, "Appointments", Icons.event, () {
                          // Navigate to Appointments screen
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CounterStaffDashboard()),
                            );
                        }),
                        _buildGridCard(context, "Find Person",
                            Icons.person_search, () {
                          // Navigate to Hospital Settings screen
                           Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchOptionScreen()),
                            );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Header with Pop Down/Up Effect
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            top: _isHeaderVisible ? 0 : -210, // Move header out of view
            left: 0,
            right: 0,
            child: _buildHeader(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 210,
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ), // Adding gradient for a modern look
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Hospital Logo
          Column(
            children: [
              Image.asset(
                'assets/medilink.png', // Your hospital logo
                height: 90,
                width: 90,
              ),
              Text(
                "MediLink",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Right side: Tagline or description
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Hospital Management Dashboard",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Manage departments, staff, and patients with ease.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, String count, IconData icon) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          Icon(icon, size: 40, color: Color(0xFF0D47A1)),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 5),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
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
            Icon(icon, size: 40, color: Color(0xFF0D47A1)),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  // Function to build Stats Cards (doctor, appointments, etc.)
  Widget _buildStatsCard(String title, String value, IconData icon) {
    return Container(
      width: 240,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF0D47A1), size: 40),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build each option as a grid item
  Widget _buildGridCard(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Color(0xFF0D47A1), size: 40),
              SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

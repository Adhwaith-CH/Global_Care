import 'package:adminglobalcare/components/appbar.dart';
import 'package:adminglobalcare/dashboard.dart';
import 'package:adminglobalcare/department.dart';
import 'package:adminglobalcare/district.dart';
import 'package:adminglobalcare/hospitallist.dart';
import 'package:adminglobalcare/place.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;
  bool _isCollapsed = false;
  String heading = "Dashboard";

  final List<Widget> _pages = [
    Dashboard(),
    Department(),
    District(),
    Place(),
   Hospitallist(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Side Navigation Menu
          Expanded(
            flex: 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isCollapsed ? 70 : 300,
              color: Color(0xFF035140),
              child: Column(
                children: [
                  // Toggle Button
                  // Align(
                  //   alignment:
                  //       _isCollapsed ? Alignment.center : Alignment.centerRight,
                  //   child: IconButton(
                  //     icon: Icon(
                  //       _isCollapsed ? Icons.menu : Icons.close,
                  //       color: Colors.white,
                  //     ),
                  //     onPressed: () {
                  //       setState(() {
                  //         _isCollapsed = !_isCollapsed;
                  //       });
                  //     },
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(top: 9.0),
                    child: Text(
                      'MediLink',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontStyle: FontStyle.normal, // Normal text
                        fontWeight: FontWeight.bold, // Bold text
                        fontFamily: 'Poppins', // Your font family name
                      ),
                    ),
                  ),
                  const Divider(color: Color.fromARGB(255, 9, 3, 3)),
            
                  // Navigation Items
                  _buildNavItem(Icons.dashboard, "Dashboard", 0),
                  _buildNavItem(Icons.business, "Find Department", 1),
                  _buildNavItem(Icons.category, "District", 2),
                  _buildNavItem(Icons.place_outlined, "Place", 3),
                  _buildNavItem(Icons.medical_information, "Hospitals List", 4),
                ],
              ),
            ),
          ),
          // Main Content
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppHeader(heading: heading,),
                _pages[_selectedIndex],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          heading=title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? const Color(0xFFFFFFFF) // Highlight selected item (Darker Blue)
              : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Row(
          children: [
            Icon(icon,
                size: 30,
                color: _selectedIndex == index
                    ? const Color(
                        0xFF035140) // Highlight selected item (Darker Blue)
                    : Color(0xFFFFFFFF)),
            if (!_isCollapsed) const SizedBox(width: 10),
            if (!_isCollapsed)
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      color: _selectedIndex == index
                          ? const Color(
                              0xFF035140) // Highlight selected item (Darker Blue)
                          : Color(0xFFFFFFFF),
                      fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

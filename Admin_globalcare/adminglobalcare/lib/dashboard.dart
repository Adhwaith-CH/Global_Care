import 'package:adminglobalcare/components/appbar.dart';
import 'package:adminglobalcare/department.dart';
import 'package:adminglobalcare/district.dart';
import 'package:adminglobalcare/place.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  bool _isCollapsed = false;

  final List<Widget> _pages = [
    Center(
        child: Text('Dashboard Page',
            style: TextStyle(
              fontSize: 20,
            ))),
    Department(),
    District(),
    Place(),
    Center(child: Text('Hospitals List Page', style: TextStyle(fontSize: 20))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Side Navigation Menu
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isCollapsed ? 70 : 300,
            color: Color(0xFF035140),
            child: Column(
              children: [
                // Toggle Button
                Align(
                  alignment:
                      _isCollapsed ? Alignment.center : Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      _isCollapsed ? Icons.menu : Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isCollapsed = !_isCollapsed;
                      });
                    },
                  ),
                ),
                Text(
                  'MedX',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontStyle: FontStyle.normal, // Normal text
                    fontWeight: FontWeight.bold, // Bold text
                    fontFamily: 'Poppins', // Your font family name
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
          // Main Content
          Expanded(
            child: Column(
              children: [
                AppHeader(),
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
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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

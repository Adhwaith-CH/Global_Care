import 'package:flutter/material.dart';

class Finduser extends StatefulWidget {
  const Finduser({super.key});

  @override
  State<Finduser> createState() => _FinduserState();
}

class _FinduserState extends State<Finduser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Search Bar Container
              Container(
                color: const Color(0xFFE3F2FD), // Light blue background
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF0D47A1), // Dark blue icon
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(
                        Icons.filter_list,
                        color: Color(0xFF0D47A1), // Dark blue icon
                      ),
                      onPressed: () {
                        // Add filter functionality here
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // User List Container
              Container(
                width: double.infinity,
                height: 130,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1), // Dark blue for the container
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 4), // Subtle shadow effect
                    ),
                  ],
                ),
                child: Center(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white, // White background
                      child: Icon(
                        Icons.person, // Default profile icon
                        size: 40,
                        color: Color(0xFF0D47A1), // Matches container theme
                      ),
                    ),
                    title: const Text(
                      "Adwaith",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text
                      ),
                    ),
                    subtitle: const Text(
                      "GBL00055",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70, // Slightly dimmed white
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        "Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2), // Lighter blue
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Additional User List Container (if needed)
              // Repeat the above Container for additional users or use a ListView.builder
            ],
          ),
        ),
      ),
    );
  }
}

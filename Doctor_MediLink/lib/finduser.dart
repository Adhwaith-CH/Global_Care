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
      // appBar: AppBar(
      //   backgroundColor: Colors.blue.shade200,
      //   title: Text("Find User", style: TextStyle(color: Colors.white)),
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Search Bar Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
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
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color:Color.fromARGB(255, 37, 99, 160),
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
                          color:Color.fromARGB(255, 37, 99, 160),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 40,
                        backgroundColor: Color.fromARGB(255, 37, 99, 160),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      title: const Text(
                        "Adwaith",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 37, 99, 160),
                        ),
                      ),
                      subtitle: const Text(
                        "GBL00055",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 37, 99, 160),
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        child: const Text(
                          "Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:Color.fromARGB(255, 37, 99, 160),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Repeat the above Container for more user list items if needed.
              ],
            ),
          ),
        ),
      ),
    );
  }
}

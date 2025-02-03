import 'package:flutter/material.dart';
import 'package:hospital/fingerprint.dart';

class SearchOptionScreen extends StatelessWidget {
  const SearchOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Heading Text
                Text(
                  "Search Method Selection",
                  style: TextStyle(
                    fontSize: 32, // Larger font size for heading
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 37, 99, 160),
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.2), offset: Offset(2, 2), blurRadius: 4)
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60), // Space between heading and buttons

                // Row for two large square containers
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Global ID Search Container
                    GestureDetector(
                      onTap: () {
                        // Navigate to Finduser page (using Global ID)
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Finduser(searchMethod: 'Global ID')),
                        );
                      },
                      child: Container(
                        height: 250, // Square-like container
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: 70,
                              color: Color.fromARGB(255, 37, 99, 160),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Global ID Search",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 37, 99, 160),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Space between the containers

                    // Fingerprint Search Container
                    GestureDetector(
                      onTap: () {
                        // Navigate to Finduser page (using Fingerprints)
                         Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FingerprintRecognitionScreen()),
                            );
                      },
                      child: Container(
                        height: 250,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fingerprint,
                              size: 70,
                              color: Color.fromARGB(255, 37, 99, 160),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Fingerprint Search",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 37, 99, 160),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40), // Space below the containers

                // New content addition: Custom description or image
                
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Optional: Any additional action or screen transition
        },
        child: Icon(Icons.help_outline),
        backgroundColor: Color.fromARGB(255, 37, 99, 160),
      ),
    );
  }
}

class Finduser extends StatelessWidget {
  final String searchMethod;

  const Finduser({super.key, required this.searchMethod});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade200,
        title: Text("Find User - $searchMethod", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Text('Searching user by: $searchMethod'),
      ),
    );
  }
}

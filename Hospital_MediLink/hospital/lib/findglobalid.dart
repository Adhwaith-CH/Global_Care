import 'package:flutter/material.dart';

class GlobalIDSearch extends StatefulWidget {
  const GlobalIDSearch({super.key});

  @override
  _GlobalIDSearchState createState() => _GlobalIDSearchState();
}

class _GlobalIDSearchState extends State<GlobalIDSearch> {
  final TextEditingController _searchController = TextEditingController();
  String? _searchResult;

  // Sample List of Patients
  final List<Map<String, String>> patients = [
    {
      "name": "John Doe",
      "globalId": "GID001",
      "photo": "https://via.placeholder.com/100"
    },
    {
      "name": "Jane Smith",
      "globalId": "GID002",
      "photo": "https://via.placeholder.com/100"
    },
    {
      "name": "Michael Johnson",
      "globalId": "GID003",
      "photo": "https://via.placeholder.com/100"
    },
    {
      "name": "Emily Davis",
      "globalId": "GID004",
      "photo": "https://via.placeholder.com/100"
    },
    {
      "name": "John Doe",
      "globalId": "GID001",
      "photo": "https://via.placeholder.com/100"
    },
    {
      "name": "Jane Smith",
      "globalId": "GID002",
      "photo": "https://via.placeholder.com/100"
    },
    {
      "name": "Michael Johnson",
      "globalId": "GID003",
      "photo": "https://via.placeholder.com/100"
    },
    {
      "name": "Emily Davis",
      "globalId": "GID004",
      "photo": "https://via.placeholder.com/100"
    },
  ];

  void _searchUser() {
    String globalId = _searchController.text.trim();
    if (globalId.isNotEmpty) {
      setState(() {
        _searchResult = "🔍 Searching for user with Global ID: $globalId";
      });
      // Implement actual search logic here
    } else {
      setState(() {
        _searchResult = "⚠️ Please enter a valid Global ID.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Card: Search Box
              Container(
                width: 400,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "🔍 Search User",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0277BD),
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: "Enter Global ID",
                        labelStyle: TextStyle(color: Color(0xFF0277BD)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.person_search, color: Color(0xFF0277BD)),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear, color: Colors.redAccent),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResult = null;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _searchUser,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [Colors.blueAccent, Colors.blue[700]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          "🔎 Search",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_searchResult != null)
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 400),
                        opacity: _searchResult != null ? 1 : 0,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            _searchResult!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(width: 30), // Space between two cards

              // Second Card: Grid of Patients
              Container(
                width: 1000,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📋 Patient List",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0277BD),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Patient Grid
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 columns
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 3.4, // Adjust height-width ratio
                        ),
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          final patient = patients[index];
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(patient["photo"]!),
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    children: [
                                      Text(
                                        patient["name"]!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "ID: ${patient["globalId"]!}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
  }
}

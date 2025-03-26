import 'package:flutter/material.dart';
import 'package:hospital/main.dart';
import 'package:hospital/userprofile.dart';

class GlobalIDSearch extends StatefulWidget {
  const GlobalIDSearch({super.key});

  @override
  _GlobalIDSearchState createState() => _GlobalIDSearchState();
}

class _GlobalIDSearchState extends State<GlobalIDSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients =
      []; // Add filtered patients list

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await supabase.from('tbl_user').select();
      List<Map<String, dynamic>> users = [];
      for (var data in response) {
        users.add({
          'id': data['user_id'],
          'name': data['user_name'],
          'globalId': data['user_gid'],
          "photo": data['user_photo'] ?? "",
        });
      }
      setState(() {
        patients = users;
        filteredPatients = users; // Initially show all patients
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _searchUser() {
    String searchQuery = _searchController.text.trim();

    setState(() {
      if (searchQuery.isEmpty) {
        filteredPatients = patients; // Show all patients when search is empty
      } else {
        filteredPatients = patients
            .where((patient) =>
                patient['globalId'].toString().contains(searchQuery))
            .toList();
      }
    });
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
                        prefixIcon:
                            Icon(Icons.person_search, color: Color(0xFF0277BD)),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear, color: Colors.redAccent),
                          onPressed: () {
                            _searchController.clear();
                            _searchUser(); // Update filtered list when cleared
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
                  ],
                ),
              ),

              SizedBox(width: 30),

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
                    Expanded(
                      child: filteredPatients.isEmpty
                          ? Center(
                              child: Text(
                                "No matching patients found",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 3.4,
                              ),
                              itemCount: filteredPatients.length,
                              itemBuilder: (context, index) {
                                final patient = filteredPatients[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(id: patient['id']),));
                                  },
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage:
                                                NetworkImage(patient["photo"]!),
                                          ),
                                          SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20, top: 20),
                                            child: Column(
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
                                          ),
                                        ],
                                      ),
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

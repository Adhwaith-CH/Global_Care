import 'package:flutter/material.dart';

class GlobalIDSearch extends StatefulWidget {
  const GlobalIDSearch({super.key});

  @override
  _GlobalIDSearchState createState() => _GlobalIDSearchState();
}

class _GlobalIDSearchState extends State<GlobalIDSearch> {
  final TextEditingController _searchController = TextEditingController();
  String? _searchResult;

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
        child: Container(
          width:500,
          height: double.infinity,
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                 
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Enter Global ID",
                    labelStyle: TextStyle(color: Color(0xFF0277BD)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.person_search, color:  Color(0xFF0277BD)),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: Colors.redAccent),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  ),
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
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
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _searchResult!,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:adminglobalcare/loginpage.dart';
import 'package:adminglobalcare/main.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String heading;
  const AppHeader({super.key, required this.heading});

  

  @override
  Widget build(BuildContext context) {
    Future<void> logOut() async {
    try {
      await supabase.auth.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Loginpage(),));
    } catch (e) {
      print("Error Loging out: $e");
    }
  }
    return Container(
      color: Color(0xFFF5F5F7),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: "Admin/",
                style: TextStyle(
                  fontSize: 24.0, // Premium size
                  fontWeight: FontWeight.w600, // Semi-bold
                  color: Colors.blueGrey, // Base color for "Admin/"
                  fontFamily: "Roboto", // Use a premium font
                ),
                children: [
                  TextSpan(
                    text: "$heading",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight:
                          FontWeight.bold, // Strong emphasis for heading
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.purple
                          ], // Gradient for heading
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(onPressed: () {
              logOut();
            }, label: Text("Log out"), 
            iconAlignment: IconAlignment.end,
            icon: Icon(
              Icons.logout_outlined,
              color: Colors.blueGrey.shade800, // Premium icon color
              size: 30.0, // Icon size
              shadows: [
                Shadow(
                  offset: Offset(2.0, 2.0), // Shadow offset
                  blurRadius: 4.0, // Smooth shadow
                  color: Colors.black26, // Subtle shadow color
                ),
              ],
            ),)
          ],
        ),
      ),
    );
  }
}

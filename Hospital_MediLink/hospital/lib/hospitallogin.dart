import 'package:flutter/material.dart';
import 'package:hospital/homepage.dart';
import 'package:hospital/hospitalregisteration.dart';
import 'package:hospital/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Hospitallogin extends StatefulWidget {
  const Hospitallogin({super.key});

  @override
  State<Hospitallogin> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Hospitallogin> {
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController =
      TextEditingController();

  Future<void> signIn() async {
    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: _emailEditingController.text,
      password: _passwordEditingController.text,
    );

    final User? user = res.user;
    if (user?.id != "") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Homepage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Panel: Branding and Message
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xFF0D47A1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/medilink.png', // Your hospital logo
                    height: 300,
                    width: 300,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    "Welcome Back to MediLink",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Log in to continue managing your healthcare needs.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right Panel: Login Form
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Please enter your email and password to continue.",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildLoginForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(_emailEditingController, 'Email', Icons.email),
        SizedBox(height: 20),
        _buildInputField(_passwordEditingController, 'Password', Icons.lock,
            obscureText: true),
        SizedBox(height: 40),
        Center(
          child: ElevatedButton(
            onPressed: () {
             signIn();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              backgroundColor: Color(0xFF0D47A1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Registration()),
                );
              },
              child: Text(
                "Sign Up",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF0D47A1)),
        hintText: hintText,
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}

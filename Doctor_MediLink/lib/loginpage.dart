import 'package:flutter/material.dart';
import 'package:loginpage/DoctorHomescreen.dart';
import 'package:loginpage/registration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final supabase = Supabase.instance.client;
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
          context,
          MaterialPageRoute(
              builder: (context) => const DoctorHomeScreen()));
    }
  }




  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ const Color.fromARGB(255, 93, 133, 153), Colors.blue.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
        
            // Decorative Elements
            Positioned(
              top: -60,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [const Color.fromARGB(255, 93, 133, 153), const Color.fromARGB(255, 93, 133, 153)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 93, 133, 153),
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -70,
              right: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, const Color.fromARGB(255, 93, 133, 153)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade50,
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
        
            // Login Form
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Login Heading
                        Text(
                          "It’s Time to Log In!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 93, 133, 153),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Log in to your account to continue",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 30),
        
                        // Email Field
                        TextFormField(
                          controller: _emailEditingController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color:const Color.fromARGB(255, 93, 133, 153)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            prefixIcon: Icon(Icons.email, color: const Color.fromARGB(255, 93, 133, 153)),
                            contentPadding: EdgeInsets.fromLTRB(
                                20.0, 15.0, 20.0, 15.0),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: const Color.fromARGB(255, 93, 133, 153)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
        
                        // Password Field
                        TextFormField(
                          controller: _passwordEditingController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: const Color.fromARGB(255, 93, 133, 153)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            prefixIcon: Icon(Icons.lock, color:const Color.fromARGB(255, 93, 133, 153)),
                            contentPadding: EdgeInsets.fromLTRB(
                                20.0, 15.0, 20.0, 15.0),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: Colors.teal),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
        
                        // Forgot Password Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Register()),
                              );
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: const Color.fromARGB(255, 93, 133, 153)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
        
                        // Submit Button
                        ElevatedButton(
                          onPressed: () {
                            signIn();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 93, 133, 153),
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                            shadowColor: const Color.fromARGB(255, 93, 133, 153),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
        
                        // Create Account Section
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
                                  MaterialPageRoute(
                                      builder: (context) => Register()),
                                );
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(color:const Color.fromARGB(255, 93, 133, 153)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

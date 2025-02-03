import 'package:adminglobalcare/home.dart';
import 'package:adminglobalcare/main.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool _isLoading = false;

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Play sound when the page loads
   // playSound();

    // Navigate to the login screen after the animation and audio are complete
   
  }

  void playSound() async {
    try {
      print("Attempting to play sound...");
      await audioPlayer.play(
        UrlSource('assets/mixkit-correct-answer-tone-2870.wav'), // Replace with your actual URL
      ); 
      print("Audio played successfully!");
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  Future<void> stopSound() async {
    try {
      print("Stopping sound...");
      await audioPlayer.stop();
      print("Audio stopped successfully!");
    } catch (e) {
      print("Error stopping sound: $e");
    }
  }

  Future<void> signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Attempt to sign in the user
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailEditingController.text,
        password: _passwordEditingController.text,
      );

      final User? admin = res.user;

      // If login is successful and the user exists in the database
      if (admin?.id != null && admin!.id.isNotEmpty) {
        String adminId = admin.id;

        try {
          final adminData =
              await supabase.from("tbl_admin").select().eq('admin_id', adminId);
          if (adminData.isNotEmpty) {
            playSound();
            Future.delayed(Duration(seconds: 8), () async {
      await stopSound();
    });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminHome()),
            ); 
            
          } else {
            // Admin data is not found in the database
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Invalid email or password.")),
            );
          }
        } catch (e) {
          // Error fetching admin data
          setState(() {
            _isLoading = false;
          });
          print("Error fetching admin data: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Something went wrong!", style: TextStyle(color: Colors.white),),backgroundColor: Colors.red,),
          );
        }
      } else {
        // If login failed due to wrong email or password
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid email or password.")),
        );
      }
    } catch (e) {
      // General error (e.g., network error, server down)
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
      print("Login Error: $e");
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
                  colors: [Colors.teal.shade400, Color.fromARGB(255, 33, 112, 95)],
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
                    colors: [Colors.teal.shade300, Color.fromARGB(255, 33, 112, 95)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.shade700.withOpacity(0.5),
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
                    colors: [Colors.teal.shade600, Color.fromARGB(255, 33, 112, 95)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.shade900.withOpacity(0.5),
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
                    width: 500,
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Add the image
                          Image.asset(
                            'assets/demo1-X-Design-removebg-preview.png', // Replace with your image path
                            height: 150, // Adjust the height
                            width: 150, // Adjust the width
                          ),
                          SizedBox(height: 5),

                          // Login Heading
                          Text(
                            "Welcome Back! Admin",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 33, 112, 95),
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
                          SizedBox(height: 40),

                          // Email Field
                          Center(
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your email.";
                                }
                                String pattern =
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                                RegExp regex = RegExp(pattern);
                                if (!regex.hasMatch(value)) {
                                  return "Please enter a valid email.";
                                }
                                return null;
                              },
                              controller: _emailEditingController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Color.fromARGB(255, 33, 112, 95)),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(30.0)),
                                prefixIcon:
                                    Icon(Icons.email, color: Color.fromARGB(255, 33, 112, 95)),
                                contentPadding: EdgeInsets.fromLTRB(
                                    20.0, 15.0, 20.0, 15.0),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password.";
                              }
                              if (value.length < 8) {
                                return "Password must be at least 6 characters long.";
                              }
                              return null;
                            },
                            controller: _passwordEditingController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Color.fromARGB(255, 33, 112, 95)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                              prefixIcon:
                                  Icon(Icons.lock, color: Color.fromARGB(255, 33, 112, 95)),
                              contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(color: Colors.teal),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          _isLoading
                              ? LoadingAnimationWidget.staggeredDotsWave(
                                  size: 42,
                        
                                  color: Color.fromARGB(255, 33, 112, 95),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      signIn();
                                    }
                                  },
                                  child: Text(
                                    "Login",
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 33, 112, 95)),
                                )
                        ],
                      ),
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

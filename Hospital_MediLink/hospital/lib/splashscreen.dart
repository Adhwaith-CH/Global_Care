
import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:hospital/hospitallogin.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  
  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Play sound when the page loads
    playSound();

    // Navigate to the login screen after the animation and audio are complete
    Future.delayed(Duration(seconds: 8), () async {
      await stopSound();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Hospitallogin()),
      );
    });
  }

  void playSound() async {
    try {
      print("Attempting to play sound...");
      await _audioPlayer.play(
        UrlSource('assets/short-logo-108964.mp3'),
      ); // Replace with your actual URL
      print("Audio played successfully!");
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  Future<void> stopSound() async {
    try {
      print("Stopping sound...");
      await _audioPlayer.stop();
      print("Audio stopped successfully!");
    } catch (e) {
      print("Error stopping sound: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 9, 55, 173), Color(0xFF0D47A1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Logo & App Name
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with Animation
                ScaleTransition(
                  scale: _animation,
                  child: FadeTransition(
                    opacity: _animation,
                    child: Image.asset(
                      'assets/medilink.png', // Your logo path
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
                SizedBox(height: 20), // Space between logo and text
                // App Name
                FadeTransition(
                  opacity: _animation,
                  child: Text(
                    "MediLink",
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.5,
                      fontFamily: "Roboto",
                      shadows: [
                        Shadow(
                          offset: Offset(3.0, 3.0),
                          blurRadius: 6.0,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30), // Space between text and loader
                // Loader
                FadeTransition(
                  opacity: _animation,
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    size: 42,
                    color: const Color.fromARGB(255, 250, 253, 253),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

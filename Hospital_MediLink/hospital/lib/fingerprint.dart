import 'package:flutter/material.dart';
import 'dart:async'; // for the timer
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart'; // For haptic feedback
import 'package:vibration/vibration.dart'; // For vibration feedback (add vibration package)

class FingerprintRecognitionScreen extends StatefulWidget {
  const FingerprintRecognitionScreen({super.key});

  @override
  _FingerprintRecognitionScreenState createState() =>
      _FingerprintRecognitionScreenState();
}

class _FingerprintRecognitionScreenState
    extends State<FingerprintRecognitionScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  int _seconds = 30;  // Timer duration
  FlutterTts flutterTts = FlutterTts();
  bool _isScanning = false;
  bool _isSuccess = false; // Success flag
  bool _isFailure = false; // Failure flag
  bool _isRetryVisible = false; // Retry button visibility

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _startTimer();
    _speak("Please place your finger on the scanner.");
  }

  void _startTimer() {
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_seconds == 0) {
        timer.cancel();
        _speak("Time's up!");
        setState(() {
          _isFailure = true;
          _isRetryVisible = true;
        });
        _vibrate(); // Add vibration feedback
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  void _speak(String message) async {
    await flutterTts.speak(message);
  }

  void _vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 500); // Vibration for 500 ms
    }
  }

  void _onScanSuccess() {
    setState(() {
      _isScanning = false;
      _isSuccess = true;
      _isFailure = false;
      _isRetryVisible = false;
    });
    _speak("Fingerprint recognized successfully.");
    _vibrate();
  }

  void _onScanFailure() {
    setState(() {
      _isScanning = false;
      _isSuccess = false;
      _isFailure = true;
      _isRetryVisible = true;
    });
    _speak("Fingerprint recognition failed. Please try again.");
    _vibrate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        child: Stack(
          children: [
            // Center animated fingerprint
            Center(
              child: RotationTransition(
                turns: _controller,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade400, width: 5),
                  ),
                  child: ClipOval(
                    child: Icon(
                      Icons.fingerprint,
                      size: 100,
                      color: Colors.blue.shade400,
                    ),
                  ),
                ),
              ),
            ),

            // Scanning status
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  _isScanning ? "Scanning..." : _isSuccess
                      ? "Success"
                      : _isFailure
                          ? "Failed"
                          : "Place your finger on the scanner",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Timer Text
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  'Time remaining: $_seconds s',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Retry Button (if failed)
            if (_isRetryVisible)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isScanning = true;
                        _isSuccess = false;
                        _isFailure = false;
                        _seconds = 30;
                        _startTimer();
                        _speak("Please place your finger on the scanner.");
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text("Retry"),
                  ),
                ),
              ),

            // Instruction Footer
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  "Please place your finger on the scanner to begin the recognition process.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

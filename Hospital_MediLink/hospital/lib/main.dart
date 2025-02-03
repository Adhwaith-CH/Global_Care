import 'package:flutter/material.dart';
import 'package:hospital/adddepartment.dart';
import 'package:hospital/adddoctor.dart';
import 'package:hospital/homepage.dart';
import 'package:hospital/hospitallogin.dart';
import 'package:hospital/hospitalregisteration.dart';
import 'package:hospital/splashscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://hiawmoajxswkgviugrxh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpYXdtb2FqeHN3a2d2aXVncnhoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ2MDY4NjksImV4cCI6MjA1MDE4Mjg2OX0.E2WIp8hFL9XI37mfskmS0EFM6YbZMGDLotTpidL-1V0',
  );
  runApp(const MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen()
    );
  }
}


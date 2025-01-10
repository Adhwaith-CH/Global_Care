import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
     color:  Color(0xFFF5F5F7),
     child: Padding(
       padding: const EdgeInsets.only(left: 1100),
       child: Icon(
          Icons.account_circle,
          color: Color(0xFF333333),
          size: 70.0, // Specify the size here
        ),
     ),
    );
  }
}
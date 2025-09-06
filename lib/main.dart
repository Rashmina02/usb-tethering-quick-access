import 'package:flutter/material.dart';

void main() {
  runApp(const TetheringApp());
}

class TetheringApp extends StatelessWidget {
  const TetheringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        // Just an empty container - app will close instantly
        color: Colors.black,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:calc_meth_od/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numerical Methods Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Changed theme color for distinction
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true, // Optional: use Material 3
      ),
      home: const HomeScreen(title: 'Navigation'),
    );
  }
}


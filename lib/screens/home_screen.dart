import 'package:flutter/material.dart';
import 'lab11_screen.dart';
import 'lab12_screen.dart';
import 'lab2_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  final String lab11 = "Лабораторная работа 1.1";
  final String lab12 = "Лабораторная работа 1.2";
  final String lab2 = "Лабораторная работа 2";
  final String lab3 = "Лабораторная работа 3";
  final String lab4 = "Лабораторная работа 4";
  final String lab5 = "Лабораторная работа 5";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              child: Text(lab11),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Lab11Screen(title: lab11)),
                );
              },
            ),
            ElevatedButton(
              child: Text(lab12),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Lab12Screen(title: lab12)),
                );
              },
            ),
            ElevatedButton(
              child: Text(lab2),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Lab2Screen(title: lab2)),
                );
              },
            ),
            ElevatedButton(
              child: Text(lab3),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Lab11Screen(title: lab3)),
                );
              },
            ),
            ElevatedButton(
              child: Text(lab4),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Lab11Screen(title: lab4)),
                );
              },
            ),
            ElevatedButton(
              child: Text(lab5),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Lab11Screen(title: lab5)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

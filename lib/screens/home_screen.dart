import 'package:flutter/material.dart';
import 'lab11_screen.dart';
import 'lab12_screen.dart';
import 'lab2_screen.dart';
import 'lab3_screen.dart';
import 'lab4_screen.dart';
import 'lab5_screen.dart';
import 'lab6_screen.dart';

// A data class to hold information about each lab for the grid.
class _LabInfo {
  final String title;
  final Widget screen;
  final IconData icon;
  final Color color;

  const _LabInfo({
    required this.title,
    required this.screen,
    required this.icon,
    required this.color,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // A list of all the labs to display in the grid.
    final List<_LabInfo> labs = [
      _LabInfo(
        title: "Лабораторная работа 1.1",
        screen: Lab11Screen(title: "Лабораторная работа 1.1"),
        icon: Icons.analytics_outlined,
        color: Colors.blue,
      ),
      _LabInfo(
        title: "Лабораторная работа 1.2",
        screen: Lab12Screen(title: "Лабораторная работа 1.2"),
        icon: Icons.multiline_chart_outlined,
        color: Colors.green,
      ),
      _LabInfo(
        title: "Лабораторная работа 2",
        screen: Lab2Screen(title: "Лабораторная работа 2"),
        icon: Icons.functions_outlined,
        color: Colors.orange,
      ),
      _LabInfo(
        title: "Лабораторная работа 3",
        screen: const Lab3Screen(),
        icon: Icons.mediation_outlined,
        color: Colors.purple,
      ),
      _LabInfo(
        title: "Лабораторная работа 4",
        screen: Lab4Screen(),
        icon: Icons.legend_toggle_outlined,
        color: Colors.red,
      ),
      _LabInfo(
        title: "Лабораторная работа 5",
        screen: Lab5Screen(),
        icon: Icons.all_inclusive_outlined,
        color: Colors.teal,
      ),
      _LabInfo(
        title: "Лабораторная работа 6",
        screen: Lab6Screen(),
        icon: Icons.all_inclusive_outlined,
        color: Colors.teal,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemCount: labs.length,
        itemBuilder: (context, index) {
          final lab = labs[index];
          return _LabCard(
            title: lab.title,
            icon: lab.icon,
            color: lab.color,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => lab.screen),
              );
            },
          );
        },
      ),
    );
  }
}

// A custom card widget for the lab buttons.
class _LabCard extends StatelessWidget {
  const _LabCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withAlpha(128),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50.0,
                color: Colors.white,
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

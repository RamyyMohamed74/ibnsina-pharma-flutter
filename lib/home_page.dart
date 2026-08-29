import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String name;

  const HomePage({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ibn Sina Pharma'),
      ),
      body: Center(
        child: Text(
          'Welcome, $name!',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
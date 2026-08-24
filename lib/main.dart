import 'package:flutter/material.dart';
import 'first_page.dart';

void main() {
  runApp(const IbnSinaPharmaApp());
}

class IbnSinaPharmaApp extends StatelessWidget {
  const IbnSinaPharmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ibn Sina Pharma',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
      ),
      home: const LoginPage(),
    );
  }
}


import 'package:flutter/material.dart';
import 'welcome_page.dart';

void main() {
  runApp(const IbnSinaPharmaApp());
}

class IbnSinaPharmaApp extends StatefulWidget {
  const IbnSinaPharmaApp({super.key});

  @override
  State<IbnSinaPharmaApp> createState() => _IbnSinaPharmaAppState();
}

class _IbnSinaPharmaAppState extends State<IbnSinaPharmaApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ibn Sina Pharma',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 76, 175, 172),
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor : const Color.fromARGB(255, 76, 175, 167), 
          brightness: Brightness.dark,
          ),
      ),

      themeMode: _isDarkMode
        ? ThemeMode.dark
        : ThemeMode.light,
      
      home: WelcomePage(
      onToggleTheme: _toggleTheme,
      isDarkMode: _isDarkMode,
        ),
    );
  }
}


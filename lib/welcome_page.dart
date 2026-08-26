import 'dart:async';
import 'package:flutter/material.dart';
import 'first_page.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  const WelcomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;   //TIME
  late Animation<double> _fadeAnimation;  //TRANSPARENCY
  late Animation<double> _scaleAnimation; //SIZE

  @override
  void initState() {
    super.initState();

    // Animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Start animation
    _controller.forward();

    // Navigate to Login after 5 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) { //Page still actiev? 
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              onToggleTheme: widget.onToggleTheme,
              isDarkMode: widget.isDarkMode,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/ibnsina-pharma-logo.png',
                  height: 400,
                  width: 400,
                  fit: BoxFit.contain,
                ),

                Transform.translate(
                   offset: const Offset(0, -70),
                  child: const Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}